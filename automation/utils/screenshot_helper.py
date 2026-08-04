import os
import time
from datetime import datetime
from selenium import webdriver
from automation.config.config import SCREENSHOTS_DIR, SCREENSHOT_RESULTS_DIR
from automation.utils.logger import get_logger

logger = get_logger("ScreenshotHelper")

class ScreenshotHelper:
    @staticmethod
    def capture_screenshot(driver: webdriver.Remote, test_id: str, suffix: str = "failure") -> str:
        """Captures and saves a full page screenshot to both local and test results folders."""
        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"{test_id}_{suffix}_{timestamp}.png"
            
            local_path = SCREENSHOTS_DIR / filename
            results_path = SCREENSHOT_RESULTS_DIR / filename
            
            driver.save_screenshot(str(local_path))
            driver.save_screenshot(str(results_path))
            
            logger.info(f"Captured screenshot for {test_id}: {filename}")
            return filename
        except Exception as e:
            logger.error(f"Failed to capture screenshot for {test_id}: {e}")
            return ""

    @staticmethod
    def get_browser_logs(driver: webdriver.Remote) -> list:
        """Extracts browser console logs if supported by the driver."""
        try:
            logs = driver.get_log("browser")
            return [f"[{log.get('level')}] {log.get('message')}" for log in logs]
        except Exception:
            return []
