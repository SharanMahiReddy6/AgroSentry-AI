import os
from pathlib import Path

# ── Base directories ──────────────────────────────────────────────────────────
PROJECT_ROOT   = Path(__file__).resolve().parent.parent.parent
AUTOMATION_DIR = PROJECT_ROOT / "automation"
BASE_DIR       = AUTOMATION_DIR   # alias for backwards compat

REPORTS_DIR        = AUTOMATION_DIR / "reports"
SCREENSHOTS_DIR    = AUTOMATION_DIR / "screenshots"
LOGS_DIR           = AUTOMATION_DIR / "logs"
DATA_DIR           = AUTOMATION_DIR / "data"

# ── Test Results (CI upload destination) ────────────────────────────────────
TEST_RESULTS_DIR    = PROJECT_ROOT / "Test Results"
EXCEL_RESULTS_DIR   = TEST_RESULTS_DIR / "Excel"
HTML_RESULTS_DIR    = TEST_RESULTS_DIR / "HTML"
SCREENSHOT_RESULTS_DIR = TEST_RESULTS_DIR / "Screenshots"
LOGS_RESULTS_DIR    = TEST_RESULTS_DIR / "Logs"
JSON_RESULTS_DIR    = TEST_RESULTS_DIR / "JSON"
SUMMARY_RESULTS_DIR = TEST_RESULTS_DIR / "Summary"

# Ensure all output directories exist
for _dir in [
    REPORTS_DIR, SCREENSHOTS_DIR, LOGS_DIR,
    TEST_RESULTS_DIR, EXCEL_RESULTS_DIR, HTML_RESULTS_DIR,
    SCREENSHOT_RESULTS_DIR, LOGS_RESULTS_DIR, JSON_RESULTS_DIR, SUMMARY_RESULTS_DIR,
]:
    _dir.mkdir(parents=True, exist_ok=True)

# ── Selenium / Web config ────────────────────────────────────────────────────
DEFAULT_BASE_URL = "https://sharanmahireddy6.github.io/AgroSentry-AI/"
BASE_URL    = os.environ.get("BASE_URL", DEFAULT_BASE_URL).rstrip("/") + "/"
BROWSER     = os.environ.get("BROWSER", "chrome").lower()
HEADLESS    = os.environ.get("HEADLESS", "true").lower() in ("true", "1", "yes")
IMPLICIT_WAIT    = int(os.environ.get("IMPLICIT_WAIT", "10"))
PAGE_LOAD_TIMEOUT= int(os.environ.get("PAGE_LOAD_TIMEOUT", "30"))
EXPLICIT_WAIT    = int(os.environ.get("EXPLICIT_WAIT", "15"))

# ── Shared execution config ──────────────────────────────────────────────────
RETRY_COUNT                 = int(os.environ.get("RETRY_COUNT", "1"))
SCREENSHOT_ON_FAILURE       = os.environ.get("SCREENSHOT_ON_FAILURE", "true").lower() in ("true","1","yes")
LOG_LEVEL                   = os.environ.get("LOG_LEVEL", "INFO")
PARALLEL_WORKERS            = int(os.environ.get("PARALLEL_WORKERS", "4"))
PASS_PERCENT_THRESHOLD      = float(os.environ.get("PASS_PERCENT_THRESHOLD", "95.0"))
MAX_CRITICAL_FAILURE_PERCENT= float(os.environ.get("MAX_CRITICAL_FAILURE_PERCENT", "5.0"))
