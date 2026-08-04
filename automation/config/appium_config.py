import os
from pathlib import Path
from automation.config.config import (
    PROJECT_ROOT, AUTOMATION_DIR,
    SCREENSHOTS_DIR, SCREENSHOT_RESULTS_DIR, LOGS_RESULTS_DIR,
    PASS_PERCENT_THRESHOLD, MAX_CRITICAL_FAILURE_PERCENT,
    RETRY_COUNT, SCREENSHOT_ON_FAILURE,
    TEST_RESULTS_DIR, EXCEL_RESULTS_DIR, HTML_RESULTS_DIR,
    JSON_RESULTS_DIR, SUMMARY_RESULTS_DIR,
)

# ── Local derived paths ────────────────────────────────────────────────────
REPORTS_DIR = AUTOMATION_DIR / "reports"
LOGS_DIR    = AUTOMATION_DIR / "logs"
DATA_DIR    = AUTOMATION_DIR / "data"

REPORTS_DIR.mkdir(parents=True, exist_ok=True)
LOGS_DIR.mkdir(parents=True, exist_ok=True)
DATA_DIR.mkdir(parents=True, exist_ok=True)

# ── Appium Server ──────────────────────────────────────────────────────────
APPIUM_HOST       = os.environ.get("APPIUM_HOST", "127.0.0.1")
APPIUM_PORT       = int(os.environ.get("APPIUM_PORT", "4723"))
APPIUM_SERVER_URL = os.environ.get("APPIUM_SERVER_URL", f"http://{APPIUM_HOST}:{APPIUM_PORT}")

# ── Android Device ─────────────────────────────────────────────────────────
DEVICE_NAME      = os.environ.get("DEVICE_NAME", "Android Emulator")
UDID             = os.environ.get("UDID", "emulator-5554")
PLATFORM_NAME    = os.environ.get("PLATFORM_NAME", "Android")
PLATFORM_VERSION = os.environ.get("PLATFORM_VERSION", "13.0")
AUTOMATION_NAME  = os.environ.get("AUTOMATION_NAME", "UiAutomator2")

# ── App Configuration ──────────────────────────────────────────────────────
APP_PACKAGE      = os.environ.get("APP_PACKAGE", "com.agrosentry.mobile")
APP_ACTIVITY     = os.environ.get("APP_ACTIVITY", ".MainActivity")
APP_WAIT_ACTIVITY= os.environ.get("APP_WAIT_ACTIVITY", "com.agrosentry.mobile.*,.MainActivity")

_default_apk = PROJECT_ROOT / "mobile" / "build" / "app" / "outputs" / "flutter-apk" / "app-debug.apk"
APP_APK_PATH = os.environ.get("APP_APK_PATH", str(_default_apk) if _default_apk.exists() else "")

# ── Timeouts ───────────────────────────────────────────────────────────────
IMPLICIT_WAIT           = int(os.environ.get("APPIUM_IMPLICIT_WAIT", "10"))
EXPLICIT_WAIT           = int(os.environ.get("APPIUM_EXPLICIT_WAIT", "15"))
COMMAND_TIMEOUT         = int(os.environ.get("NEW_COMMAND_TIMEOUT", "300"))
UIAUTOMATOR2_SERVER_TIMEOUT = int(os.environ.get("UIAUTOMATOR2_SERVER_TIMEOUT", "60000"))
ADB_EXEC_TIMEOUT        = int(os.environ.get("ADB_EXEC_TIMEOUT", "60000"))

# ── App Behaviour ──────────────────────────────────────────────────────────
NO_RESET             = os.environ.get("NO_RESET", "true").lower() in ("true", "1", "yes")
AUTO_GRANT_PERMISSIONS = os.environ.get("AUTO_GRANT_PERMISSIONS", "true").lower() in ("true", "1", "yes")
MOCK_EMULATION_MODE  = os.environ.get("MOCK_EMULATION_MODE", "auto").lower()  # auto | true | false


def get_desired_capabilities() -> dict:
    """Builds Appium UiAutomator2 desired capabilities dictionary."""
    caps = {
        "platformName":                          PLATFORM_NAME,
        "appium:platformVersion":                PLATFORM_VERSION,
        "appium:deviceName":                     DEVICE_NAME,
        "appium:udid":                           UDID,
        "appium:automationName":                 AUTOMATION_NAME,
        "appium:appPackage":                     APP_PACKAGE,
        "appium:appActivity":                    APP_ACTIVITY,
        "appium:appWaitActivity":                APP_WAIT_ACTIVITY,
        "appium:noReset":                        NO_RESET,
        "appium:autoGrantPermissions":           AUTO_GRANT_PERMISSIONS,
        "appium:newCommandTimeout":              COMMAND_TIMEOUT,
        "appium:uiautomator2ServerLaunchTimeout": UIAUTOMATOR2_SERVER_TIMEOUT,
        "appium:adbExecTimeout":                 ADB_EXEC_TIMEOUT,
        "appium:ensureWebviewsHavePages":        True,
        "appium:nativeWebScreenshot":            True,
        "appium:connectHardwareKeyboard":        True,
    }
    if APP_APK_PATH and Path(APP_APK_PATH).exists():
        caps["appium:app"] = APP_APK_PATH
    return caps
