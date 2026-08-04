import time
from typing import Callable, Any
from selenium.webdriver.remote.webdriver import WebDriver
from selenium.webdriver.remote.webelement import WebElement
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from automation.config.config import EXPLICIT_WAIT
from automation.utils.logger import get_logger

logger = get_logger("WaitHelpers")

class WaitHelper:
    def __init__(self, driver: WebDriver, timeout: int = EXPLICIT_WAIT):
        self.driver = driver
        self.wait = WebDriverWait(driver, timeout)

    def wait_for_visibility(self, locator: tuple[By, str]) -> WebElement:
        return self.wait.until(EC.visibility_of_element_located(locator))

    def wait_for_presence(self, locator: tuple[By, str]) -> WebElement:
        return self.wait.until(EC.presence_of_element_located(locator))

    def wait_for_clickable(self, locator: tuple[By, str]) -> WebElement:
        return self.wait.until(EC.element_to_be_clickable(locator))

    def wait_for_invisibility(self, locator: tuple[By, str]) -> bool:
        return self.wait.until(EC.invisibility_of_element_located(locator))

    def wait_for_url_contains(self, text: str) -> bool:
        return self.wait.until(EC.url_contains(text))

    def wait_for_title_contains(self, text: str) -> bool:
        return self.wait.until(EC.title_contains(text))

    def wait_for_dom_ready(self, timeout: int = 15) -> bool:
        """Waits until document.readyState is 'complete'."""
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                state = self.driver.execute_script("return document.readyState")
                if state == "complete":
                    return True
            except Exception:
                pass
            time.sleep(0.2)
        return False
