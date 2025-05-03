# app/main_streamlit.py
import streamlit as st
import logging
import sys
from pathlib import Path
import pandas as pd
import time # <<< Import the time module

# --- Add project root to path to allow imports ---
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))
# -------------------------------------------------

from config.logging_config import setup_logging
# --- Placeholder imports for other modules ---
from graph_logic.graphs import run_nl2sql_graph
from storage.db_handler import log_result, save_feedback, fetch_run_history
# -----------------------------------------------


# --- Add project root to path ---
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))
# ----------------------------------


# --- Initialize Session State ---
# Initialize all keys we will use to persist state across reruns
if 'show_feedback' not in st.session_state:
    st.session_state.show_feedback = False
if 'current_query_context' not in st.session_state:
    st.session_state.current_query_context = {}
if 'results_ready' not in st.session_state: # Flag to know if results area should be shown
    st.session_state.results_ready = False
if 'last_prompt' not in st.session_state:
    st.session_state.last_prompt = None
if 'last_sql' not in st.session_state:
    st.session_state.last_sql = None
if 'last_em_score' not in st.session_state:
    st.session_state.last_em_score = "N/A"
if 'last_exec_acc_score' not in st.session_state:
    st.session_state.last_exec_acc_score = "N/A"
if 'last_duration' not in st.session_state:
    st.session_state.last_duration = 0.0
# Initialize feedback widget states if needed (might help consistency)
if 'feedback_rating_slider' not in st.session_state:
    st.session_state.feedback_rating_slider = "OK"
if 'feedback_issues_multi' not in st.session_state:
    st.session_state.feedback_issues_multi = []
if 'feedback_comment_combo' not in st.session_state:
    st.session_state.feedback_comment_combo = ""
if 'ground_truth_input' not in st.session_state:
    st.session_state.ground_truth_input = ""
# Initialize session history for Session State
if 'history_data' not in st.session_state:
    st.session_state.history_data = None # Store the fetched history (as DataFrame)
if 'history_loaded' not in st.session_state:
    st.session_state.history_loaded = False # Flag to track initial load
# --------------------------------
# --- Setup Logging ---
setup_logging()
logger = logging.getLogger(__name__)
# ---------------------


# --- Streamlit App Layout ---
st.set_page_config(layout="wide")
st.title("NL2SQL Prompt Engineering Analyzer")


# logger.info("="*20 + " Streamlit App Started/Refreshed " + "="*20) # Clear marker for app start/rerun

# --- Sidebar for Global Configuration ---
with st.sidebar:
    st.header("Configuration")
    available_datasets = ["Spider_Dev", "WikiSQL_Test", "RealWorld_SalesDB"]
    available_prompt_types = ["Zero-Shot", "Few-Shot", "Structured/Domain-Specific"]
    available_llms = ["GPT-4 (Placeholder)", "LLaMA-2 (Placeholder)"]

    selected_dataset = st.selectbox("Select Dataset:", available_datasets)
    selected_prompt_type = st.selectbox("Select Prompt Technique:", available_prompt_types)
    selected_llm = st.selectbox("Select LLM:", available_llms)
    st.divider()

# --- Main Area with Tabs ---
tab1, tab2, tab3 = st.tabs(["📊 NL Query Test", "📈 Evaluation Analytics", "📜 Run History"])

# --- Tab 1: Live NL Query Testing ---
# --- Tab 1: Live NL Query Testing ---
with tab1:
    st.header("Test NL Query to SQL Generation")
    st.write("Enter a natural language query and select parameters to generate and evaluate SQL.")

    # Input area for the natural language query
    nl_query = st.text_area("Your question:", height=100, placeholder="e.g., Show me the total sales per region for 'Electronics'.", key="nl_query_input")

    # Button to trigger the main process
    if st.button("Run Generation & Evaluation", key="generate_sql_button"):
        # Reset relevant session state variables for a new run
        st.session_state.results_ready = False
        st.session_state.show_feedback = False
        st.session_state.last_em_score = "N/A"
        st.session_state.last_exec_acc_score = "N/A"
        st.session_state.last_prompt = None
        st.session_state.last_sql = None
        st.session_state.current_query_context = {} # Clear previous context

        # Check if the user provided a query
        if not nl_query:
            st.warning("Please enter a natural language query.")
        else:
            # Log the start of the process and parameters
            logger.info("--- Begin Generate User Query ---")
            logger.info(f"Parameters: Dataset='{selected_dataset}', PromptType='{selected_prompt_type}', LLM='{selected_llm}'")
            logger.info(f"NL Query: '{nl_query}'")
            # Get ground truth SQL if provided by the user
            current_ground_truth = st.session_state.ground_truth_input
            if current_ground_truth: logger.info("Ground Truth SQL provided for evaluation.")

            start_time = time.perf_counter() # Start timing the operation

            try:
                # --- Call the backend LangGraph workflow ---
                with st.spinner("Running NL2SQL generation graph..."):
                    logger.info("Invoking backend graph...")
                    # Call the main entry point function defined in graph_logic/graph.py
                    graph_result_state = run_nl2sql_graph(
                        nl_query=nl_query,
                        prompt_strategy=selected_prompt_type,
                        selected_llm=selected_llm
                    )
                    logger.info("Backend graph execution attempt complete.")

                    # Extract results from the graph's final state
                    generated_sql = graph_result_state.get("generated_sql")
                    prompt = graph_result_state.get("final_prompt", "Prompt not captured by graph state.")
                    graph_error = graph_result_state.get("error")

                    # Handle potential errors reported by the graph execution
                    if graph_error: raise Exception(f"Backend graph execution failed: {graph_error}")
                    if not generated_sql: raise Exception("Graph execution finished but no SQL was generated.")

                # --- Placeholder for Evaluation Logic ---
                # Initialize evaluation scores
                em_score = "N/A"
                exec_acc_score = "N/A"
                # If ground truth was provided, run placeholder evaluation
                if current_ground_truth:
                    logger.info("Proceeding to placeholder evaluation.")
                    # TODO: Replace with actual call to evaluator.py functions
                    em_score = "0.0 (Eval Placeholder)"
                    exec_acc_score = "0.0 (Eval Placeholder)"
                else:
                    logger.info("No ground truth provided, skipping evaluation step.")
                # ------------------------------------------

                end_time = time.perf_counter() # Stop timing
                duration = end_time - start_time
                st.success(f"Processing complete in {duration:.3f} seconds!")

                # --- Store results in session state for UI display and feedback ---
                st.session_state.last_prompt = prompt
                st.session_state.last_sql = generated_sql
                st.session_state.last_em_score = em_score
                st.session_state.last_exec_acc_score = exec_acc_score
                st.session_state.last_duration = duration

                # Prepare the context dictionary to be logged to MongoDB
                run_context_for_log = {
                    "nl_query": nl_query,
                    "dataset": selected_dataset,
                    "prompt_type": selected_prompt_type,
                    "llm": selected_llm,
                    "generated_sql": generated_sql,
                    "prompt": prompt,
                    "ground_truth_sql": current_ground_truth,
                    "em_score": em_score, # Use actual score variables
                    "exec_acc_score": exec_acc_score,
                    "duration_sec": duration,
                    "graph_error": graph_error # Log any error from the graph itself
                }
                # Store this context in session state as well (needed for feedback linking)
                st.session_state.current_query_context = run_context_for_log.copy()

                # --- Log Results to MongoDB ---
                logger.info("Logging results to database...")
                # Call the log_result function from db_handler.py
                result_id = log_result(run_context_for_log)
                if result_id:
                    # Store the returned MongoDB document ID in session state context
                    st.session_state.current_query_context['mongodb_id'] = result_id
                    st.info(f"Results logged to DB (ID: {result_id}).")
                    logger.info(f"Successfully logged run with MongoDB ID: {result_id}")
                else:
                    # Handle logging failure
                    st.warning("Failed to log results to database.")
                    logger.error("Failed to get result ID from log_result.")
                # --- End Logging ---

                # Set flags to display the results and feedback sections
                st.session_state.results_ready = True
                st.session_state.show_feedback = True


            except Exception as e:
                # Handle any exceptions during the process
                st.session_state.results_ready = False
                st.session_state.show_feedback = False
                end_time = time.perf_counter()
                duration = end_time - start_time # Duration before error
                logger.error(f"An error occurred in 'Run Generation & Evaluation': {e}", exc_info=True)
                st.error(f"An error occurred: {e}")
                st.caption(f"Processing time before error: {duration:.3f} seconds")
            finally:
                 # Log the end of the attempt regardless of success/failure
                 logger.info("--- End Generate User Query Attempt ---")


    # --- Display Results Area ---
    # This section is displayed only if results are ready (flag set in session state)
    if st.session_state.get('results_ready', False):
        st.markdown("---") # Separator
        st.subheader("Generated Output & Evaluation")
        # Display the prompt used
        st.text("Generated Prompt:")
        st.code(st.session_state.last_prompt or "N/A", language='text')
        # Display the generated SQL
        st.text("Generated SQL:")
        st.code(st.session_state.last_sql or "N/A", language='sql')
        # Display the ground truth SQL if it was provided
        gt_sql_context = st.session_state.current_query_context.get("ground_truth_sql")
        if gt_sql_context:
             st.text("Ground Truth SQL (Used for Eval):")
             st.code(gt_sql_context, language='sql')
        # Display evaluation scores (currently placeholders)
        st.markdown(f"**Evaluation Scores (Placeholders):**")
        st.metric("Exact Match (EM) Score", st.session_state.last_em_score)
        st.metric("Execution Accuracy (ExecAcc) Score", st.session_state.last_exec_acc_score)
        # Display processing time
        st.caption(f"Total processing time: {st.session_state.last_duration:.3f} seconds")


    # --- Feedback Section ---
    # This section is displayed only if feedback should be shown (flag set in session state)
    if st.session_state.get('show_feedback', False):
        st.divider() # Separator
        st.subheader("Feedback on Generated SQL")

        # Feedback input widgets (rating, issues, comment)
        rating_options = ["Very Bad", "Bad", "OK", "Good", "Very Good"]
        feedback_rating = st.select_slider("Overall rating:", options=rating_options, key="feedback_rating_slider")
        selected_issues = []
        # Show issue selection only if rating is not "Very Good"
        if st.session_state.feedback_rating_slider != "Very Good":
            issue_categories = ["Incorrect Table(s)", "Incorrect Column(s)", "Wrong Aggregation", "Incorrect Filter/WHERE", "Syntax Error", "Doesn't Answer Question", "Other"]
            selected_issues = st.multiselect("Select issue categories (optional):", options=issue_categories, key="feedback_issues_multi")
        feedback_comment = st.text_area("Optional comments:", key="feedback_comment_combo", height=100)

        # Button to submit feedback
        if st.button("Submit Feedback", key="submit_feedback_button_combo"):
            # Get feedback values from session state (linked to widgets)
            rating_value = st.session_state.feedback_rating_slider
            issues_value = st.session_state.feedback_issues_multi
            comment_value = st.session_state.feedback_comment_combo

            # Log feedback details
            logger.info(f"Feedback received: Rating='{rating_value}', Issues='{issues_value}', Comment='{comment_value}'")
            logger.info(f"Feedback context: {st.session_state.current_query_context}")

            # --- Save Feedback to MongoDB ---
            # Retrieve the MongoDB ID of the run we are giving feedback for
            run_id_to_update = st.session_state.current_query_context.get('mongodb_id')

            if run_id_to_update:
                logger.info(f"Attempting to save feedback for MongoDB ID: {run_id_to_update}")
                try:
                    # Call the save_feedback function from db_handler.py
                    success = save_feedback(
                        run_id=run_id_to_update,
                        rating=rating_value,
                        issues=issues_value,
                        comment=comment_value
                    )
                    if success:
                        # If save successful, show success message and reset UI
                        st.success("Thank you for your feedback! (Saved to DB)")
                        st.session_state.show_feedback = False # Hide form
                        st.session_state.results_ready = False # Hide results
                        # Reset feedback widgets to defaults
                        st.session_state.feedback_rating_slider = "OK"
                        st.session_state.feedback_issues_multi = []
                        st.session_state.feedback_comment_combo = ""
                        logger.info(f"Successfully saved feedback for run {run_id_to_update}.")
                        st.rerun() # Force a UI refresh to reflect state changes
                    else:
                        # Handle save failure reported by db_handler
                        st.error("Sorry, there was an issue saving your feedback to the database.")
                        logger.error(f"save_feedback function returned False for run {run_id_to_update}.")

                except Exception as e:
                    # Handle unexpected errors during save attempt
                    logger.error(f"Failed to save feedback to DB for run {run_id_to_update}: {e}", exc_info=True)
                    st.error("Sorry, an unexpected error occurred while saving your feedback.")
            else:
                # Handle case where the run ID wasn't found (e.g., user refreshed page before feedback)
                st.error("Cannot save feedback: Missing the Run ID for the previous query. Please generate SQL again.")
                logger.error("Cannot save feedback: 'mongodb_id' not found in current_query_context.")
            # --- End Save Feedback ---

# --- Tab 2: Evaluation Analytics ---
# with tab2:
#     st.header("Analyze Experiment Results")
#     st.write("View aggregated metrics and comparisons from completed experiment runs.")
#     st.info("This section will display analytics once experiment data is logged in the database.")

#     st.subheader("Overall Performance Metrics (Placeholder)")
#     st.write("Average EM/ExecAcc scores per prompt type, dataset, etc. will be shown here.")
#     # Placeholder for fetching and displaying aggregated data...

#     st.subheader("Performance Comparison Charts (Placeholder)")
#     st.write("Bar charts comparing prompt techniques or performance across datasets will be displayed here.")
#     # Placeholder for creating charts...


# --- Tab 3: Run History ---
with tab3:
    st.header("Detailed Run History")
    st.write("Browse and search through the logs of individual query runs.")

    # --- Filtering Widgets ---
    st.subheader("Filter History")
    col1, col2, col3 = st.columns(3)
    with col1:
        # Use a key to easily access the value later
        filter_run_id = st.text_input("Filter by Run ID:", key="filter_run_id_input")
    with col2:
        filter_dataset = st.selectbox("Filter by Dataset:", ["All"] + available_datasets, key="hist_dataset_filter")
    with col3:
        filter_prompt_type = st.selectbox("Filter by Prompt Type:", ["All"] + available_prompt_types, key="hist_prompt_filter")
    # ------------------------

    # --- Trigger Fetching ---
    fetch_now = False
    # Check if the search button was clicked
    if st.button("Search History", key="search_history_button"):
        fetch_now = True
        st.session_state.history_loaded = True # Mark that a search was performed
        logger.info(f"Search button clicked. Fetching history with filters: RunID='{st.session_state.filter_run_id_input}', Dataset='{st.session_state.hist_dataset_filter}', Prompt='{st.session_state.hist_prompt_filter}'")
    # Check if history hasn't been loaded yet for the initial view
    elif not st.session_state.history_loaded:
        fetch_now = True
        st.session_state.history_loaded = True # Mark that initial load is happening
        logger.info("Tab 3 first view. Fetching initial history (no filters).")
    # ----------------------

    # --- Fetch Data Logic ---
    if fetch_now:
        with st.spinner("Fetching history..."):
            try:
                # Prepare filter arguments based on whether search was clicked or initial load
                # Use session state keys to get current widget values
                run_id_filter_arg = None
                dataset_filter_arg = None
                prompt_filter_arg = None

                # Only apply filters if the search button was the trigger
                if st.session_state.get("search_history_button"): # Check if button was clicked
                    dataset_filter_arg = None if st.session_state.hist_dataset_filter == "All" else st.session_state.hist_dataset_filter
                    prompt_filter_arg = None if st.session_state.hist_prompt_filter == "All" else st.session_state.hist_prompt_filter
                    run_id_filter_arg = None if not st.session_state.filter_run_id_input else st.session_state.filter_run_id_input

                # Call the actual backend function
                history_list = fetch_run_history(
                    run_id=run_id_filter_arg,
                    dataset=dataset_filter_arg,
                    prompt_type=prompt_filter_arg
                    # limit=50 # Keep the default limit from db_handler
                )

                # Store results (or empty list) in session state
                if history_list:
                    # Convert list of dicts to DataFrame for display
                    st.session_state.history_data = pd.DataFrame(history_list)
                    logger.info(f"Successfully fetched {len(st.session_state.history_data)} history records.")
                else:
                    st.session_state.history_data = pd.DataFrame() # Store empty DataFrame
                    logger.info("No history records found matching the criteria.")

            except Exception as e:
                logger.error(f"Error fetching or processing history: {e}", exc_info=True)
                st.error(f"An error occurred while fetching history: {e}")
                st.session_state.history_data = pd.DataFrame() # Ensure it's an empty DF on error
    # --- End Fetch Data Logic ---

    # --- Display History Data ---
    st.subheader("History Results")
    if st.session_state.history_data is not None:
        if not st.session_state.history_data.empty:
            # Define columns to display initially (adjust as needed)
            display_columns = [
                "_id", "timestamp", "dataset", "prompt_type", "llm",
                "nl_query", "generated_sql", "em_score", "exec_acc_score",
                "duration_sec" # Add other relevant columns from your logged context
            ]
            # Filter DataFrame to only include existing columns among the desired ones
            columns_to_show = [col for col in display_columns if col in st.session_state.history_data.columns]

            st.dataframe(st.session_state.history_data[columns_to_show])
        else:
            # Show message if DataFrame exists but is empty (e.g., after filtering)
             st.write("No matching run history found for the selected criteria.")
    else:
        # Initial state before any loading attempt
        st.write("History will be loaded here. Click 'Search History' or view on initial load.")
    # --- End Display History Data ---