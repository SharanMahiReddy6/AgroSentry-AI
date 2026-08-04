import os
import time
from pathlib import Path
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException, NoSuchElementException
try:
    from appium.webdriver.common.appiumby import AppiumBy
except ImportError:
    # Fallback to standard By if AppiumBy not loaded
    class AppiumBy:
        ACCESSIBILITY_ID = "accessibility id"
        ANDROID_UIAUTOMATOR = "-android uiautomator"
        ID = "id"
        XPATH = "xpath"
        CLASS_NAME = "class name"

from automation.config import appium_config
from automation.utils.logger import get_logger

logger = get_logger("AppiumBasePage")

class AppiumBasePage:
    """Enterprise Base Page Object for Android Appium Automation."""

    def __init__(self, driver):
        self.driver = driver
        self.wait = WebDriverWait(driver, appium_config.EXPLICIT_WAIT)
        self.timeout = appium_config.EXPLICIT_WAIT

    def find(self, locator: tuple, timeout: int = None):
        """Finds an element by locator tuple (By.*, 'selector')."""
        t = timeout or self.timeout
        try:
            return WebDriverWait(self.driver, t).until(
                EC.presence_of_element_located(locator)
            )
        except Exception as e:
            logger.debug(f"Element {locator} not present within {t}s: {e}")
            raise

    def find_visible(self, locator: tuple, timeout: int = None):
        """Finds a visible element by locator tuple."""
        t = timeout or self.timeout
        return WebDriverWait(self.driver, t).until(
            EC.visibility_of_element_located(locator)
        )

    def find_all(self, locator: tuple, timeout: int = 5) -> list:
        """Finds all matching elements or returns empty list."""
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located(locator)
            )
            return self.driver.find_elements(*locator)
        except Exception:
            return []

    def click(self, locator: tuple, timeout: int = None):
        """Clicks an element with auto-wait."""
        element = self.find_visible(locator, timeout)
        try:
            element.click()
        except Exception:
            try:
                # Fallback tap via coordinates
                self.tap_element(element)
            except Exception:
                element.click()

    def type_text(self, locator: tuple, text: str, clear_first: bool = True, timeout: int = None):
        """Types text into an input element."""
        element = self.find_visible(locator, timeout)
        if clear_first:
            try:
                element.clear()
            except Exception:
                pass
        element.send_keys(text)
        self.hide_keyboard_safe()

    def get_text(self, locator: tuple, timeout: int = 5) -> str:
        """Extracts text content from an element."""
        try:
            element = self.find(locator, timeout)
            return (element.text or element.get_attribute("text") or "").strip()
        except Exception:
            return ""

    def get_attribute(self, locator: tuple, attribute: str, timeout: int = 5) -> str:
        """Gets element attribute value."""
        try:
            element = self.find(locator, timeout)
            return element.get_attribute(attribute) or ""
        except Exception:
            return ""

    def is_displayed(self, locator: tuple, timeout: int = 5) -> bool:
        """Verifies if element is displayed on current screen."""
        try:
            el = WebDriverWait(self.driver, timeout).until(
                EC.visibility_of_element_located(locator)
            )
            return el.is_displayed()
        except Exception:
            return False

    def is_present(self, locator: tuple, timeout: int = 5) -> bool:
        """Verifies if element is present in view hierarchy."""
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located(locator)
            )
            return True
        except Exception:
            return False

    def is_enabled(self, locator: tuple, timeout: int = 5) -> bool:
        """Checks if element is interactive / enabled."""
        try:
            el = self.find(locator, timeout)
            return el.is_enabled()
        except Exception:
            return False

    def hide_keyboard_safe(self):
        """Hides soft keyboard if open."""
        try:
            if hasattr(self.driver, "hide_keyboard"):
                self.driver.hide_keyboard()
        except Exception:
            pass

    def swipe_down(self):
        """Performs a downward swipe gesture."""
        try:
            if hasattr(self.driver, "swipe"):
                self.driver.swipe(500, 1600, 500, 600, 800)
        except Exception:
            pass

    def swipe_up(self):
        """Performs an upward swipe gesture."""
        try:
            if hasattr(self.driver, "swipe"):
                self.driver.swipe(500, 600, 500, 1600, 800)
        except Exception:
            pass

    def tap_element(self, element):
        """Performs tap action on element center."""
        try:
            element.click()
        except Exception:
            pass

    def scroll_to_text(self, text: str):
        """Scrolls Android UI to find matching text via UiScrollable."""
        try:
            selector = f'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().textContains("{text}"))'
            return self.driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR, selector)
        except Exception:
            return None

    def capture_screenshot(self, test_id: str, suffix: str = "capture") -> str:
        """Captures device screenshot and saves to reports & Test Results."""
        filename = f"{test_id}_{suffix}_{int(time.time())}.png"
        path1 = appium_config.SCREENSHOTS_DIR / filename
        path2 = appium_config.SCREENSHOT_RESULTS_DIR / filename
        
        try:
            if hasattr(self.driver, "save_screenshot"):
                self.driver.save_screenshot(str(path1))
                if path1.exists():
                    import shutil
                    shutil.copy2(path1, path2)
                return str(path1.relative_to(appium_config.AUTOMATION_DIR))
        except Exception as e:
            logger.warning(f"Failed capturing screenshot for {test_id}: {e}")
        return ""

    def get_device_logs(self) -> list:
        """Retrieves device logs from Appium session."""
        try:
            if hasattr(self.driver, "get_log"):
                return self.driver.get_log("logcat")
        except Exception:
            pass
        return []
