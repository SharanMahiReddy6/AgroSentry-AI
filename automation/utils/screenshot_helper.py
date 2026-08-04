import os
import time
import shutil
from datetime import datetime
from automation.config.config import SCREENSHOTS_DIR, SCREENSHOT_RESULTS_DIR
from automation.utils.logger import get_logger

logger = get_logger("ScreenshotHelper")

class ScreenshotHelper:
    @staticmethod
    def capture_screenshot(driver, test_id: str, suffix: str = "failure") -> str:
        """Captures and saves a screenshot for both Selenium/WebDriver and Appium drivers."""
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"{test_id}_{suffix}_{timestamp}.png"
            local_path = SCREENSHOTS_DIR / filename
            results_path = SCREENSHOT_RESULTS_DIR / filename

            if hasattr(driver, "save_screenshot"):
                driver.save_screenshot(str(local_path))
            elif hasattr(driver, "get_screenshot_as_file"):
                driver.get_screenshot_as_file(str(local_path))

            if local_path.exists():
                shutil.copy2(local_path, results_path)

            logger.info(f"Screenshot captured for {test_id}: {filename}")
            return filename
        except Exception as e:
            logger.error(f"Failed to capture screenshot for {test_id}: {e}")
            return ""

    @staticmethod
    def get_browser_logs(driver) -> list:
        """Extracts logs from Selenium browser or Appium device logcat."""
        try:
            # Appium logcat
            if hasattr(driver, "get_log"):
                logs = driver.get_log("logcat")
                return [f"[{l.get('level')}] {l.get('message')}" for l in logs[:50]]
        except Exception:
            pass
        return []

