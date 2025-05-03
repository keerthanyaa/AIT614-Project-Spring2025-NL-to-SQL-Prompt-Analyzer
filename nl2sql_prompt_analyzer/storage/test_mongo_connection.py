# test_mongo_connection.py
import sys
import os
from pathlib import Path
import logging

# --- Add project root to Python path ---
# This allows importing from 'storage' and 'config'
project_root = Path(__file__).resolve().parent
if str(project_root) not in sys.path:
    sys.path.insert(0, str(project_root))
    print(f"Added project root to sys.path: {project_root}")
# ----------------------------------------

# --- Basic Logging Setup for the Test ---
# Configure logging to see output from db_handler
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)
# ----------------------------------------

# --- Import the function to test ---
try:
    from storage.db_handler import get_mongo_client
except ImportError as e:
    logger.error(f"Failed to import get_mongo_client: {e}")
    logger.error("Ensure you are running this script from the project root directory (`nl2sql_prompt_analyzer/`).")
    sys.exit(1) # Exit if import fails
# -----------------------------------

def main():
    """
    Main function to test the MongoDB connection.
    """
    logger.info("--- Starting MongoDB Connection Test ---")

    # Attempt to get the MongoDB client using the function from db_handler
    # This will trigger the .env loading and connection attempt within db_handler
    client = get_mongo_client()

    if client:
        logger.info("Successfully obtained MongoDB client object.")
        try:
            # Perform a simple operation to confirm connectivity
            db_names = client.list_database_names()
            logger.info(f"Successfully listed database names (found {len(db_names)}). Connection confirmed.")
            print("\n✅ MongoDB Connection Successful!")
            print(f"   Databases found (sample): {db_names[:]}{'...' if len(db_names) > 5 else ''}") 
        except Exception as e:
            logger.error(f"Obtained client, but failed to execute command (list_database_names): {e}", exc_info=True)
            print("\n⚠️ MongoDB Connection Warning: Obtained client, but command failed. Check permissions or network.")
        finally:
            # Good practice to close the client when done in a standalone script
            # Note: db_handler uses a global client, so closing here might affect
            # subsequent calls if this script were part of a larger process.
            # For a simple connection test, closing is fine.
            if client:
                 logger.info("Closing MongoDB client connection.")
                 client.close()
    else:
        logger.error("Failed to obtain MongoDB client object.")
        print("\n❌ MongoDB Connection Failed.")
        print("   Check logs above for details.")
        print(f"   Verify MONGODB_CONNECTION_URL in config/.env is correct and accessible.")

    logger.info("--- MongoDB Connection Test Finished ---")

if __name__ == "__main__":
    # Ensure the MONGODB_CONNECTION_URL is set (either in system env or config/.env)
    # The loading happens inside db_handler, but we check here for user guidance
    if not os.environ.get("MONGODB_CONNECTION_URL"):
         # Check if it might be loaded from .env later
         env_path_check = project_root / 'config' / '.env'
         if not env_path_check.is_file():
              print("Warning: MONGODB_CONNECTION_URL environment variable not found,")
              print(f"         and config/.env file does not exist at {env_path_check}.")
              print("         Connection will likely fail.")
         else:
              print("Info: MONGODB_CONNECTION_URL not found in initial environment.")
              print(f"      Attempting to load from {env_path_check} via db_handler.")


    main()
