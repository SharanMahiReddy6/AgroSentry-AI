from urllib.parse import urljoin
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException, StaleElementReferenceException
from automation.config.config import BASE_URL, EXPLICIT_WAIT
from automation.utils.logger import get_logger
from automation.utils.screenshot_helper import ScreenshotHelper

logger = get_logger("BasePage")

class BasePage:
    def __init__(self, driver: WebDriver, path: str = ""):
        self.driver = driver
        self.base_url = BASE_URL.rstrip("/") + "/"
        self.path = path.lstrip("/")
        self.url = urljoin(self.base_url, self.path) if self.path else self.base_url
        self.wait = WebDriverWait(driver, EXPLICIT_WAIT)

    def open(self, custom_path: str = None) -> "BasePage":
        target = urljoin(self.base_url, custom_path.lstrip("/")) if custom_path else self.url
        logger.info(f"Navigating to page: {target}")
        self.driver.get(target)
        self.wait_for_ready_state()
        return self

    def wait_for_ready_state(self, timeout: int = 15):
        try:
            WebDriverWait(self.driver, timeout).until(
                lambda d: d.execute_script("return document.readyState") == "complete"
            )
        except Exception:
            pass

    def find(self, locator: tuple[By, str], timeout: int = EXPLICIT_WAIT) -> WebElement:
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located(locator)
        )

    def find_visible(self, locator: tuple[By, str], timeout: int = EXPLICIT_WAIT) -> WebElement:
        return WebDriverWait(self.driver, timeout).until(
            EC.visibility_of_element_located(locator)
        )

    def find_all(self, locator: tuple[By, str], timeout: int = EXPLICIT_WAIT) -> list[WebElement]:
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.presence_of_all_elements_located(locator)
            )
            return self.driver.find_elements(*locator)
        except TimeoutException:
            return []

    def click(self, locator: tuple[By, str], timeout: int = EXPLICIT_WAIT):
        element = WebDriverWait(self.driver, timeout).until(
            EC.element_to_be_clickable(locator)
        )
        try:
            element.click()
        except Exception:
            # Fallback to JavaScript click if intercepted
            self.driver.execute_script("arguments[0].click();", element)

    def type_text(self, locator: tuple[By, str], text: str, clear_first: bool = True, timeout: int = EXPLICIT_WAIT):
        element = self.find_visible(locator, timeout)
        if clear_first:
            element.clear()
        element.send_keys(text)

    def get_text(self, locator: tuple[By, str], timeout: int = EXPLICIT_WAIT) -> str:
        try:
            element = self.find_visible(locator, timeout)
            return element.text.strip()
        except Exception:
            return ""

    def get_attribute(self, locator: tuple[By, str], attribute: str, timeout: int = EXPLICIT_WAIT) -> str:
        try:
            element = self.find(locator, timeout)
            return element.get_attribute(attribute) or ""
        except Exception:
            return ""

    def is_displayed(self, locator: tuple[By, str], timeout: int = 5) -> bool:
        try:
            element = WebDriverWait(self.driver, timeout).until(
                EC.visibility_of_element_located(locator)
            )
            return element.is_displayed()
        except Exception:
            return False

    def is_present(self, locator: tuple[By, str], timeout: int = 5) -> bool:
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located(locator)
            )
            return True
        except Exception:
            return False

    def is_enabled(self, locator: tuple[By, str], timeout: int = 5) -> bool:
        try:
            element = self.find(locator, timeout)
            return element.is_enabled()
        except Exception:
            return False

    def get_current_url(self) -> str:
        return self.driver.current_url

    def get_title(self) -> str:
        return self.driver.title

    def execute_script(self, script: str, *args):
        return self.driver.execute_script(script, *args)

    def capture_screenshot(self, test_id: str, suffix: str = "capture") -> str:
        return ScreenshotHelper.capture_screenshot(self.driver, test_id, suffix)

    def get_console_logs(self) -> list[str]:
        return ScreenshotHelper.get_browser_logs(self.driver)
