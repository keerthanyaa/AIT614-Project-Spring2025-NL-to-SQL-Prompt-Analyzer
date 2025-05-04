# graph_logic/sql_gen.py
import logging
import time
from typing import Protocol, Dict, Type, Optional, Tuple # Ensure Tuple is imported
import os
import re

# --- Relative Import ---
from .state import GraphState

# --- Imports needed for REAL LLM calls ---
try:
    from openai import OpenAI, OpenAIError, APIConnectionError, RateLimitError, APIStatusError
except ImportError:
    OpenAI = None
    OpenAIError = None
    # Define dummy error classes if openai is not installed to avoid NameErrors later
    class APIConnectionError(Exception): pass
    class RateLimitError(Exception): pass
    class APIStatusError(Exception): pass
    print("Warning: openai library not installed. pip install openai")
try:
    import google.generativeai as genai
    import google.generativeai.types as genai_types
except ImportError:
    genai = None
    genai_types = None
    print("Warning: google-generativeai library not installed. pip install google-generativeai")

# --- Pydantic for basic validation ---
try:
    from pydantic import BaseModel, field_validator, ValidationError
except ImportError:
    BaseModel = None
    field_validator = None
    ValidationError = None
    print("Warning: pydantic library not installed. pip install pydantic")
# -----------------------------------

# --- Load .env file ---
from pathlib import Path
from dotenv import load_dotenv
env_path = Path(__file__).parent.parent / 'config' / '.env'
if env_path.is_file():
    load_dotenv(dotenv_path=env_path, override=True)
    # Logging might not be configured yet at import time
    # logging.info(f"Loaded environment variables from {env_path}")
else:
    # Use print here as logger might not be ready
    print(f"Warning: .env file not found at {env_path}. Relying on system environment variables.")
# --------------------

# --- Logger Setup ---
# Basic config in case this module is used before main app setup
if not logging.getLogger().hasHandlers():
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)
# --------------------

# --- Define Usage Dictionary Type ---
TokenUsage = Optional[Dict[str, Optional[int]]] # Type hint for token usage dict

# --- Updated LLM Client Interface Definition ---
class LLMClient(Protocol):
    """Defines the interface for LLM clients."""
    def __init__(self, config: Optional[Dict] = None): ...
    # Methods return a tuple: (response_text, token_usage_dict)
    def generate_sql(self, prompt: str) -> Tuple[str, TokenUsage]: ...
    def predict_tables(self, prompt: str) -> Tuple[str, TokenUsage]: ...
# ---------------------------------------------------

# --- Pydantic Model for Basic SQL Validation ---
class SQLQueryValidator(BaseModel):
    """Basic validator to check if a string looks like a SQL query."""
    query: str
    @field_validator('query')
    @classmethod
    def check_sql_start(cls, v: str) -> str:
        if BaseModel is None: # Skip if pydantic not installed
             return v
        v_stripped = v.strip()
        # Updated regex to include SHOW
        sql_starters = r'^(SELECT|INSERT|UPDATE|DELETE|CREATE|ALTER|DROP|WITH|SHOW)\b'
        # Allow specific SQLite master table query (might not be needed for PostgreSQL)
        sqlite_master_query = r'^SELECT\s+name\s+FROM\s+sqlite_master\s+WHERE\s+type\s*=\s*\'table\''
        if not re.match(sql_starters, v_stripped, re.IGNORECASE) and \
           not re.match(sqlite_master_query, v_stripped, re.IGNORECASE):
            raise ValueError('Query does not start with a common SQL keyword (SELECT, INSERT, SHOW etc.) or match SQLite table list query.')
        return v

# --- Concrete LLM Client Class Implementations ---

class MockLLMClient:
    """A mock client for testing without real API calls."""
    def __init__(self, config: Optional[Dict] = None):
        logger.info("Init MockLLMClient")
        self.config = config or {}

    def generate_sql(self, prompt: str) -> Tuple[str, TokenUsage]:
        logger.info("MockLLMClient: Generating Mock SQL")
        time.sleep(0.5)
        sql = f"SELECT mock_col FROM mock_table WHERE input LIKE '%{prompt[-20:]}%';"
        usage = {"prompt_tokens": 10, "completion_tokens": 5, "total_tokens": 15}
        return sql, usage

    def predict_tables(self, prompt: str) -> Tuple[str, TokenUsage]:
        logger.info("MockLLMClient: Predicting Mock Tables")
        time.sleep(0.5)
        tables = "prod_catalog" # Default mock prediction
        if "customer" in prompt.lower(): tables = "client_registry, sales_hdrs"
        elif "product" in prompt.lower(): tables = "prod_catalog, sales_lines"
        usage = {"prompt_tokens": 20, "completion_tokens": 3, "total_tokens": 23}
        return tables, usage

class OpenAIClient:
    """Client for interacting with OpenAI models (e.g., gpt-4o-mini)."""
    def __init__(self, config: Optional[Dict] = None):
        logger.info("Initializing OpenAIClient...")
        self.config = config or {}
        self.model_name = self.config.get("model", "gpt-4o-mini")

        if OpenAI is None:
            raise ImportError("openai library is required for OpenAIClient.")

        try:
            # OpenAI() implicitly reads the OPENAI_API_KEY environment variable
            self.client = OpenAI()
            self.client.models.list() # Simple call to check authentication
            logger.info(f"OpenAI client initialized successfully for model {self.model_name}.")
        except (OpenAIError, APIConnectionError) as e:
            logger.error(f"Failed to initialize or authenticate OpenAI client: {e}", exc_info=False)
            self.client = None
            raise ConnectionError(f"Failed to connect/authenticate OpenAI: {e}")
        except Exception as e:
            logger.error(f"An unexpected error occurred during OpenAI client initialization: {e}", exc_info=True)
            self.client = None
            raise ConnectionError(f"Unexpected error initializing OpenAI: {e}")

    def _call_openai(self, system_prompt: str, user_prompt: str) -> Tuple[str, TokenUsage]:
        """Internal helper to make the ChatCompletion call and handle common logic."""
        if not self.client:
            return "-- ERROR: OpenAI client not initialized.", None

        logger.debug(f"Sending to OpenAI model '{self.model_name}':\nSystem: {system_prompt}\nUser: {user_prompt[:200]}...") # Log truncated user prompt
        usage_info: TokenUsage = None
        try:
            response = self.client.chat.completions.create(
                model=self.model_name,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=0.1 # Low temperature for deterministic outputs
            )

            # Extract Token Usage
            if response.usage:
                usage_info = {
                    "prompt_tokens": response.usage.prompt_tokens,
                    "completion_tokens": response.usage.completion_tokens,
                    "total_tokens": response.usage.total_tokens
                }
                logger.info(f"OpenAI API Usage: {usage_info}")
            else:
                logger.warning("Token usage information not available in OpenAI response.")

            # Extract Response Text
            if response.choices:
                raw_text = response.choices[0].message.content.strip()
                logger.debug(f"Raw response from OpenAI: {raw_text}")
                # Clean markdown fences
                if raw_text.lower().startswith("```sql"): raw_text = raw_text[6:]
                if raw_text.lower().startswith("```"): raw_text = raw_text[3:]
                if raw_text.endswith("```"): raw_text = raw_text[:-3]
                cleaned_text = raw_text.strip()
                logger.info("Successfully received response from OpenAI.")
                return cleaned_text, usage_info
            else:
                finish_reason = response.choices[0].finish_reason if response.choices else 'N/A'
                logger.warning(f"OpenAI response contained no choices. Finish reason: {finish_reason}")
                return f"-- WARNING: OpenAI returned no response choices (Reason: {finish_reason}).", usage_info

        # Error Handling
        except RateLimitError as e:
            logger.error(f"OpenAI API rate limit exceeded: {e}", exc_info=False)
            return f"-- ERROR: OpenAI API Rate Limit Exceeded. Please try again later.", None
        except APIConnectionError as e:
            logger.error(f"OpenAI API connection error: {e}", exc_info=False)
            return f"-- ERROR: OpenAI API Connection Error: {e}", None
        except APIStatusError as e:
            logger.error(f"OpenAI API status error (e.g., 4xx, 5xx): {e}", exc_info=False)
            return f"-- ERROR: OpenAI API Status Error: Status={e.status_code}, Message={e.message}", None
        except OpenAIError as e:
            logger.error(f"OpenAI API error during call: {e}", exc_info=True)
            return f"-- ERROR: OpenAI API Error: {e}", None
        except Exception as e:
            logger.error(f"Unexpected error during OpenAI call: {e}", exc_info=True)
            return f"-- ERROR: Unexpected error during OpenAI call: {e}", None

    def generate_sql(self, prompt: str) -> Tuple[str, TokenUsage]:
        """Generates SQL using OpenAI model. Returns (text, usage) tuple."""
        logger.info(f"Calling OpenAI model '{self.model_name}' for SQL generation.")
        system_prompt = "You are an expert SQL generator. Generate only the syntactically correct SQL query for PostgreSQL based on the user's request and provided schema (if any). Do not add explanations or markdown formatting like ```sql."
        return self._call_openai(system_prompt=system_prompt, user_prompt=prompt)

    def predict_tables(self, prompt: str) -> Tuple[str, TokenUsage]:
        """Predicts relevant tables using OpenAI model. Returns (text, usage) tuple."""
        logger.info(f"Calling OpenAI model '{self.model_name}' for table prediction.")
        system_prompt = "You are an assistant that identifies relevant database tables based on a user query and table descriptions. List only the names of the relevant tables, separated by commas. If no tables seem relevant, output 'None'."
        return self._call_openai(system_prompt=system_prompt, user_prompt=prompt)

class GeminiClient:
    """Client for interacting with Google Gemini models (e.g., gemini-1.5-flash-latest)."""
    def __init__(self, config: Optional[Dict] = None):
        logger.info("Initializing GeminiClient...")
        self.config = config or {}
        self.model_name = self.config.get("model", "gemini-1.5-flash-latest")

        if genai is None:
            raise ImportError("google-generativeai library is required for GeminiClient.")

        try:
            api_key = os.environ.get('GOOGLE_API_KEY')
            if not api_key:
                raise ValueError("GOOGLE_API_KEY not found in environment variables or .env file.")
            genai.configure(api_key=api_key)
            self.model = genai.GenerativeModel(self.model_name)
            logger.info(f"Gemini client initialized successfully for model {self.model_name}.")
        except ValueError as e:
            logger.error(f"Gemini configuration error (likely API key issue): {e}", exc_info=False)
            self.model = None
            raise ConnectionError(f"Gemini configuration error: {e}")
        except Exception as e:
            logger.error(f"An unexpected error occurred during Gemini client initialization: {e}", exc_info=True)
            self.model = None
            raise ConnectionError(f"Unexpected error initializing Gemini: {e}")

    def _call_gemini(self, full_prompt: str) -> Tuple[str, TokenUsage]:
        """Internal helper to make the Gemini API call."""
        if not self.model:
            return "-- ERROR: Gemini model not initialized.", None

        logger.debug(f"Sending to Gemini model '{self.model_name}':\n{full_prompt[:300]}...") # Log truncated prompt
        generation_config = genai.types.GenerationConfig(temperature=0.1)
        safety_settings = {} # Use default safety settings
        response = None
        usage_info: TokenUsage = None
        try:
            response = self.model.generate_content(
                full_prompt,
                generation_config=generation_config,
                safety_settings=safety_settings
            )

            # Log Token Usage
            if hasattr(response, 'usage_metadata') and response.usage_metadata:
                 usage_info = {
                      "prompt_tokens": response.usage_metadata.prompt_token_count,
                      "completion_tokens": response.usage_metadata.candidates_token_count,
                      "total_tokens": response.usage_metadata.total_token_count
                 }
                 logger.info(f"Gemini API Usage: {usage_info}")
            else:
                 logger.warning("Token usage metadata not available in Gemini response.")

            # Safely access text
            raw_text = response.text.strip()
            logger.debug(f"Raw response from Gemini: {raw_text}")
            # Clean markdown
            if raw_text.lower().startswith("```sql"): raw_text = raw_text[6:]
            if raw_text.lower().startswith("```"): raw_text = raw_text[3:]
            if raw_text.endswith("```"): raw_text = raw_text[:-3]
            cleaned_text = raw_text.strip()
            logger.info("Successfully received response from Gemini.")
            return cleaned_text, usage_info

        except genai_types.BlockedPromptException as e:
            logger.error(f"Gemini prompt was blocked: {e}")
            try: # Attempt to log feedback if available
                if response and response.prompt_feedback:
                     logger.error(f"Gemini Block Feedback: {response.prompt_feedback}")
            except Exception: pass
            return f"-- ERROR: Gemini prompt blocked.", usage_info
        except genai_types.StopCandidateException as e:
             logger.error(f"Gemini generation stopped unexpectedly: {e}")
             return f"-- WARNING: Gemini generation stopped unexpectedly (StopCandidateException).", usage_info
        except Exception as e:
            logger.error(f"An unexpected error occurred during Gemini call: {e}", exc_info=True)
            return f"-- ERROR: Unexpected Gemini call error.", usage_info

    def generate_sql(self, prompt: str) -> Tuple[str, TokenUsage]:
        """Generates SQL using Gemini model. Returns (text, usage) tuple."""
        logger.info(f"Calling Gemini model '{self.model_name}' for SQL generation.")
        # Construct prompt specific to SQL generation task
        full_prompt = f"""**Task:** Generate a syntactically correct SQL query for PostgreSQL based on the provided schema and user question.
**Output Requirements:** ONLY output the SQL query. Do not include explanations, markdown formatting (like ```sql), or any other text.

**Schema:**
{prompt}

**SQL Query:**"""
        return self._call_gemini(full_prompt)

    def predict_tables(self, prompt: str) -> Tuple[str, TokenUsage]:
        """Predicts relevant tables using Gemini model. Returns (text, usage) tuple."""
        logger.info(f"Calling Gemini model '{self.model_name}' for table prediction.")
        # The prompt received here is already formatted by generate_table_prediction_prompt
        full_prompt = prompt
        return self._call_gemini(full_prompt)

# --- Factory Function / Registry ---
LLM_CLIENT_REGISTRY: Dict[str, Type[LLMClient]] = {
    "MockLLM": MockLLMClient,
    "GPT-4o Mini": OpenAIClient,
    "Gemini 1.5 Flash": GeminiClient,
}

# --- get_llm_client function ---
def get_llm_client(llm_name: str, config: Optional[Dict] = None) -> Optional[LLMClient]:
    """Factory function to get an instance of the appropriate LLM client."""
    client_class = LLM_CLIENT_REGISTRY.get(llm_name)
    if not client_class:
        logger.warning(f"LLM client for '{llm_name}' not found in registry. Falling back to MockLLMClient.")
        client_class = MockLLMClient
    try:
        client_instance = client_class(config=config)
        return client_instance
    except Exception as e:
        logger.error(f"Failed to instantiate LLM client '{llm_name}': {e}", exc_info=True)
        logger.warning("Falling back to MockLLMClient due to instantiation error.")
        return MockLLMClient(config=config) # Return mock on error

# --- LangGraph Node Function (Validation Added Here) ---
def call_llm_node(state: GraphState) -> GraphState:
    """
    Takes the final prompt, calls the main SQL generation LLM's generate_sql method,
    captures token usage, validates the output, and returns the result.
    """
    logger.debug(f"Entering call_llm_node (Final SQL Generation).")
    final_prompt = state.get('final_prompt')
    selected_llm_name = state.get('llm_config')
    if not final_prompt: logger.error("No final_prompt found."); return {"generated_sql": None, "error": "Final prompt generation failed."}
    if not selected_llm_name: logger.error("No LLM specified."); return {"generated_sql": None, "error": "LLM configuration missing."}

    # Check if Pydantic is available
    if BaseModel is None:
         logger.error("Pydantic not installed, cannot validate SQL output.")
         validation_error_msg = "Skipped SQL validation (Pydantic not installed)."
    else:
         validation_error_msg = None

    # Initialize update dictionary
    update_dict: Dict[str, Any] = {
        "generated_sql": None,
        "error": None,
        "generation_prompt_tokens": None,
        "generation_completion_tokens": None,
        "generation_total_tokens": None
    }

    try:
        llm_client = get_llm_client(selected_llm_name)
        if llm_client is None: raise ValueError("LLM Client instantiation failed.")

        logger.info(f"Using {llm_client.__class__.__name__} for FINAL SQL generation.")
        # Capture text AND usage from generate_sql
        generated_sql_text, usage_info = llm_client.generate_sql(final_prompt)

        # Store token usage in update_dict
        if usage_info:
            update_dict["generation_prompt_tokens"] = usage_info.get("prompt_tokens")
            update_dict["generation_completion_tokens"] = usage_info.get("completion_tokens")
            update_dict["generation_total_tokens"] = usage_info.get("total_tokens")
        logger.info(f"LLM Client {llm_client.__class__.__name__} finished generating SQL text.")

        # Check if client returned an error string
        if generated_sql_text.startswith("-- ERROR:") or generated_sql_text.startswith("-- WARNING:"):
             logger.error(f"SQL Gen LLM client returned an error/warning: {generated_sql_text}")
             update_dict["error"] = generated_sql_text # Store error
             return update_dict # Return state update with error

        # Perform SQL Validation Here
        if validation_error_msg:
            logger.warning(validation_error_msg)
            update_dict["generated_sql"] = generated_sql_text
            update_dict["error"] = validation_error_msg # Store warning as error for now
            return update_dict
        else:
            try:
                SQLQueryValidator(query=generated_sql_text) # Validate the text
                logger.info("Final generated SQL passed basic validation.")
                update_dict["generated_sql"] = generated_sql_text # Store valid SQL
                return update_dict # Validation passed
            except ValidationError as val_err:
                logger.error(f"Final generated text failed SQL validation: {val_err}")
                logger.error(f"Invalid SQL received: {generated_sql_text}")
                error_msg = f"Final generated text failed SQL validation: {val_err}. Output was: {generated_sql_text}"
                update_dict["error"] = error_msg # Store validation error
                return update_dict # Validation failed

    except Exception as e:
        logger.error(f"Error during FINAL SQL LLM node execution ({selected_llm_name}): {e}", exc_info=True)
        update_dict["error"] = f"Final SQL LLM Node Error: {e}"
        return update_dict # Return state update with error

