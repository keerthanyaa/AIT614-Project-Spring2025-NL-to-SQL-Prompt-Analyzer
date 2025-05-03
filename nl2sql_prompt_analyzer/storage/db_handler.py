# storage/db_handler.py
import os
import logging
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, OperationFailure
from datetime import datetime, timezone
from typing import Dict, Any, Optional, List
from bson import ObjectId
from pathlib import Path
from dotenv import load_dotenv
import certifi

# --- Logger Setup ---
if not logging.getLogger().hasHandlers():
     logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)
# --------------------

# --- Configuration ---
# --- Load .env file ---
env_path = Path(__file__).parent.parent / 'config' / '.env'
if env_path.is_file():
    logger.info(f"Loading environment variables from: {env_path}")
    load_dotenv(dotenv_path=env_path, override=True)
else:
    logger.warning(f".env file not found at {env_path}. Relying on system environment variables.")
# ---------------------

MONGODB_URI = os.environ.get("MONGODB_CONNECTION_URL")
DATABASE_NAME = "nl2sql_analyzer"
RUNS_COLLECTION = "experiment_runs"
FEEDBACK_COLLECTION = "run_feedback"

# --- Global Client Variable ---
_mongo_client: Optional[MongoClient] = None

# --- Connection Function ---
def get_mongo_client() -> Optional[MongoClient]:
    """
    Establishes and returns a MongoDB client connection.
    Uses certifi for TLS CA verification.
    """
    global _mongo_client
    if _mongo_client:
        try:
            _mongo_client.admin.command('ping')
            return _mongo_client
        except ConnectionFailure:
            logger.warning("Existing MongoDB client connection failed ping test. Reconnecting.")
            _mongo_client = None

    if not MONGODB_URI:
        logger.error("MONGODB_CONNECTION_URL not found in environment variables or .env file. Cannot connect to database.")
        return None

    try:
        ca_path = certifi.where()
        logger.info(f"Using certifi CA bundle path: {ca_path}")
        logger.info(f"Attempting to connect to MongoDB (URI loaded, starts with: {MONGODB_URI[:20]}...)")
        client = MongoClient(
            MONGODB_URI,
            tls=True,
            tlsCAFile=ca_path,
            serverSelectionTimeoutMS=5000
        )
        client.admin.command('ping')
        logger.info("MongoDB connection successful.")
        _mongo_client = client
        return _mongo_client
    except ConnectionFailure as e:
        logger.error(f"MongoDB connection failed: {e}", exc_info=True)
        _mongo_client = None
        return None
    except Exception as e:
        logger.error(f"An unexpected error occurred during MongoDB connection: {e}", exc_info=True)
        _mongo_client = None
        return None

# --- get_database remains the same ---
def get_database():
    client = get_mongo_client()
    if client: # Client object *can* be checked implicitly or use 'is not None'
        try: return client[DATABASE_NAME]
        except Exception as e: logger.error(f"Failed to get database '{DATABASE_NAME}': {e}", exc_info=True); return None
    return None

# --- Corrected Checks in Collection Getters ---
def get_runs_collection():
    """Gets the collection for storing experiment runs."""
    db = get_database()
    # --- Use explicit None check for database object ---
    if db is not None:
        try:
            print("[DEBUG] - collection", db[RUNS_COLLECTION])
            return db[RUNS_COLLECTION]
        except Exception as e:
            logger.error(f"Failed to get collection '{RUNS_COLLECTION}': {e}", exc_info=True)
            return None
    else: # Handle case where get_database() returned None
        logger.error("Cannot get runs collection: Database connection failed.")
        return None

def get_feedback_collection():
    """Gets the collection for storing feedback (if using separate collection)."""
    db = get_database()
    # --- Use explicit None check for database object ---
    if db is not None:
        try:
            return db[FEEDBACK_COLLECTION]
        except Exception as e:
            logger.error(f"Failed to get collection '{FEEDBACK_COLLECTION}': {e}", exc_info=True)
            return None
    else: # Handle case where get_database() returned None
        logger.error("Cannot get feedback collection: Database connection failed.")
        return None
# --- End Corrected Checks ---

# --- Updated Checks in Logging/Fetching Functions ---
def log_result(run_context: Dict[str, Any]) -> Optional[str]:
    """Logs the details of a completed NL2SQL run to the database."""
    collection = get_runs_collection()
    # --- Use explicit None check for collection object ---
    if collection is None:
        logger.error("Cannot log result: Failed to get runs collection.")
        return None
    # ---
    log_entry = {"timestamp": datetime.now(timezone.utc), **run_context}
    log_entry.setdefault("em_score", None)
    log_entry.setdefault("exec_acc_score", None)
    log_entry.setdefault("feedback", None)
    try:
        logger.info(f"Log entry (before insertion) : {log_entry}")
        insert_result = collection.insert_one(log_entry)
        inserted_id = insert_result.inserted_id
        logger.info(f"Inserted data : {insert_result}")
        logger.info(f"Successfully logged run result with ID: {inserted_id}")
        return str(inserted_id)
    except OperationFailure as e: logger.error(f"Failed to log run result (OperationFailure): {e.details}", exc_info=True); return None
    except Exception as e: logger.error(f"An unexpected error occurred during result logging: {e}", exc_info=True); return None

def save_feedback(run_id: str, rating: str, issues: List[str], comment: str) -> bool:
    """Saves user feedback, associating it with a specific run record."""
    collection = get_runs_collection()
    # --- Use explicit None check for collection object ---
    if collection is None:
        logger.error("Cannot save feedback: Failed to get runs collection.")
        return False
    # ---
    try: object_id = ObjectId(run_id)
    except Exception: logger.error(f"Invalid run_id format: '{run_id}'."); return False
    feedback_data = {"rating": rating, "issues": issues, "comment": comment, "timestamp": datetime.now(timezone.utc)}
    try:
        update_result = collection.update_one({"_id": object_id}, {"$set": {"feedback": feedback_data}})
        if update_result.matched_count == 0: logger.error(f"Feedback save failed: No run found with ID: {run_id}"); return False
        if update_result.modified_count == 0 and update_result.matched_count == 1: logger.warning(f"Feedback for run ID {run_id} submitted, but no modification (identical?)."); return True
        logger.info(f"Successfully saved feedback for run ID: {run_id}")
        return True
    except OperationFailure as e: logger.error(f"Failed to save feedback (OperationFailure) for run ID {run_id}: {e.details}", exc_info=True); return False
    except Exception as e: logger.error(f"An unexpected error occurred during feedback saving for run ID {run_id}: {e}", exc_info=True); return False

def fetch_run_history(run_id: Optional[str] = None, dataset: Optional[str] = None, prompt_type: Optional[str] = None, limit: int = 50) -> List[Dict[str, Any]]:
    """ Fetches run history from the database based on optional filters. """
    collection = get_runs_collection()
    # --- Use explicit None check for collection object ---
    if collection is None:
        logger.error("Cannot fetch history: Failed to get runs collection.")
        return []
    # ---
    query_filter = {}
    if run_id:
        try: query_filter["_id"] = ObjectId(run_id)
        except Exception: logger.warning(f"Invalid run_id format: '{run_id}'. Ignoring filter.")
    if dataset: query_filter["dataset"] = dataset
    if prompt_type: query_filter["prompt_type"] = prompt_type
    try:
        logger.info(f"Fetching run history with filter: {query_filter}, limit: {limit}")
        cursor = collection.find(query_filter).sort("timestamp", -1).limit(limit)
        results = []
        for doc in cursor:
            doc["_id"] = str(doc["_id"])
            results.append(doc)
        logger.info(f"Found {len(results)} history records.")
        return results
    except OperationFailure as e: logger.error(f"Failed to fetch run history (OperationFailure): {e.details}", exc_info=True); return []
    except Exception as e: logger.error(f"An unexpected error occurred during history fetching: {e}", exc_info=True); return []
# --- End Updated Checks ---
