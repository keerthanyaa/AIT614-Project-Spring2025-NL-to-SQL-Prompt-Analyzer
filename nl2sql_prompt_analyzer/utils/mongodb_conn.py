# utils/mongodb_conn.py
import os
from pathlib import Path
from dotenv import load_dotenv
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

# --- Load Environment Variables ---
# Construct the path to the .env file relative to this script
# This script is in 'utils/', .env is in 'config/' relative to the project root.
# Go up one level from 'utils/' to the project root, then down into 'config/'
try:
    current_dir = Path(__file__).parent
    project_root = current_dir.parent # Go up one level
    dotenv_path = project_root / 'config' / '.env'

    if dotenv_path.is_file():
        load_dotenv(dotenv_path=dotenv_path, verbose=True) # verbose=True prints feedback
        print(f"Loaded .env file from: {dotenv_path}")
    else:
        print(f"Warning: .env file not found at {dotenv_path}")

except Exception as e:
    print(f"Error determining .env path or loading .env file: {e}")
# ---------------------------------

# --- Get URI from Environment ---
uri = os.getenv("MONGODB_CONNECTION_URL")

if not uri:
    print("Error: MONGODB_CONNECTION_URL not found in environment variables.")
    print("Please ensure it is set in the config/.env file and the file is loaded.")
    # Optionally raise an exception or exit
    # raise ValueError("MONGODB_CONNECTION_URL not configured")
    exit() # Exit if URI is essential for the script to run
# -----------------------------

# Replace placeholder password if needed (though ideally it's in the URI already)
# Be very careful with password handling. Best practice is the full URI in .env
# uri = uri.replace("<db_password>", os.getenv("MONGO_PASSWORD", "YOUR_DEFAULT_PW_IF_ANY"))

print("Attempting to connect using URI from environment...")

# Create a new client and connect to the server
# Note: Handle potential errors during client creation itself
try:
    client = MongoClient(uri, server_api=ServerApi('1'))

    # Send a ping to confirm a successful connection
    client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")

except Exception as e:
    print(f"An unexpected error occurred: {e}")

finally:
    # It's good practice to close the client connection if this is just a test script
    # In a real app, you might manage the client lifecycle differently
    if 'client' in locals() and client:
        client.close()
        print("MongoDB connection closed.")