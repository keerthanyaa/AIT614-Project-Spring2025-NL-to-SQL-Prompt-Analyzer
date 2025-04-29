# config/logging_config.py
import logging
import logging.handlers
import sys
from pathlib import Path

# Flag to ensure setup runs only once per Python process/Streamlit session
_logging_configured = False

def setup_logging(log_level=logging.INFO, log_dir="logs", log_file_basename="nl2sql_analyzer"):
    """Configures rotating file logging and console logging idempotently (runs once)."""
    global _logging_configured
    # --- Check if already configured in this process ---
    if _logging_configured:
        return # Exit function if logging is already set up
    # --------------------------------------------------

    log_path_dir = Path(log_dir)
    log_path_dir.mkdir(parents=True, exist_ok=True)
    log_file_path = log_path_dir / f"{log_file_basename}.log"

    log_formatter = logging.Formatter(
        "%(asctime)s [%(levelname)-5.5s] [%(name)s] %(message)s"
    )
    root_logger = logging.getLogger()

    # --- Clear any potential handlers first (belt-and-suspenders for the first run) ---
    if root_logger.hasHandlers():
        for handler in list(root_logger.handlers):
             root_logger.removeHandler(handler)
             handler.close()
    # --------------------------------------------------------------------------------

    root_logger.setLevel(log_level) # Set root level

    handlers_added = False # Track if setup is successful
    # --- Add Timed Rotating File Handler ---
    try:
        file_handler = logging.handlers.TimedRotatingFileHandler(
            filename=log_file_path, when='D', interval=1, backupCount=7, encoding='utf-8', delay=False
        )
        file_handler.setFormatter(log_formatter)
        file_handler.setLevel(log_level)
        root_logger.addHandler(file_handler)
        handlers_added = True
    except Exception as e:
        print(f"CRITICAL: Error setting up file logger: {e}", file=sys.stderr) # Use print for setup errors
    # ------------------------------------

    # --- Add Console Handler ---
    try:
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setFormatter(log_formatter)
        console_handler.setLevel(logging.INFO) # Keep console potentially less verbose
        root_logger.addHandler(console_handler)
        handlers_added = True
    except Exception as e:
        print(f"CRITICAL: Error setting up console logger: {e}", file=sys.stderr)
    # ------------------------

    # --- Log confirmation ONLY ONCE after attempting setup ---
    # if handlers_added:
    #     # Use a specific logger or root logger for this one-time message
    #     logging.getLogger(__name__).info("Logging configured. Target file: %s", log_file_path)
    # else:
    #     # This print will also only happen once if setup fails
    #     print("CRITICAL: No logging handlers could be configured.", file=sys.stderr)

    _logging_configured = True # <<< Set the flag so this function won't run again