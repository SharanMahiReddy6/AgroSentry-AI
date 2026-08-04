import os
from pathlib import Path

# Base directories
BASE_DIR = Path(__file__).resolve().parent.parent
REPORTS_DIR = BASE_DIR / "reports"
SCREENSHOTS_DIR = BASE_DIR / "screenshots"
LOGS_DIR = BASE_DIR / "logs"
DATA_DIR = BASE_DIR / "data"

# Test Results destination (for CI/CD and artifact upload)
TEST_RESULTS_DIR = BASE_DIR.parent / "Test Results"
EXCEL_RESULTS_DIR = TEST_RESULTS_DIR / "Excel"
HTML_RESULTS_DIR = TEST_RESULTS_DIR / "HTML"
SCREENSHOT_RESULTS_DIR = TEST_RESULTS_DIR / "Screenshots"
LOGS_RESULTS_DIR = TEST_RESULTS_DIR / "Logs"
JSON_RESULTS_DIR = TEST_RESULTS_DIR / "JSON"
SUMMARY_RESULTS_DIR = TEST_RESULTS_DIR / "Summary"

# Ensure all result directories exist
for dir_path in [
    REPORTS_DIR, SCREENSHOTS_DIR, LOGS_DIR,
    TEST_RESULTS_DIR, EXCEL_RESULTS_DIR, HTML_RESULTS_DIR,
    SCREENSHOT_RESULTS_DIR, LOGS_RESULTS_DIR, JSON_RESULTS_DIR, SUMMARY_RESULTS_DIR
]:
    dir_path.mkdir(parents=True, exist_ok=True)

# Application URL Configuration
# MANDATORY: BASE_URL must be configurable via environment variable
DEFAULT_BASE_URL = "https://sharanmahireddy6.github.io/AgroSentry-AI/"
BASE_URL = os.environ.get("BASE_URL", DEFAULT_BASE_URL).rstrip("/") + "/"

# Browser & Driver Configuration
BROWSER = os.environ.get("BROWSER", "chrome").lower()
HEADLESS = os.environ.get("HEADLESS", "true").lower() in ("true", "1", "yes")
IMPLICIT_WAIT = int(os.environ.get("IMPLICIT_WAIT", "10"))
PAGE_LOAD_TIMEOUT = int(os.environ.get("PAGE_LOAD_TIMEOUT", "30"))
EXPLICIT_WAIT = int(os.environ.get("EXPLICIT_WAIT", "15"))

# Test Execution Configuration
RETRY_COUNT = int(os.environ.get("RETRY_COUNT", "1"))
SCREENSHOT_ON_FAILURE = os.environ.get("SCREENSHOT_ON_FAILURE", "true").lower() in ("true", "1", "yes")
LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO")
PARALLEL_WORKERS = int(os.environ.get("PARALLEL_WORKERS", "4"))
PASS_PERCENT_THRESHOLD = float(os.environ.get("PASS_PERCENT_THRESHOLD", "95.0"))
MAX_CRITICAL_FAILURE_PERCENT = float(os.environ.get("MAX_CRITICAL_FAILURE_PERCENT", "5.0"))
