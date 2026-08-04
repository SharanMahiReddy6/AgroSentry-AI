import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.edge.options import Options as EdgeOptions
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from automation.config.config import BROWSER, HEADLESS, IMPLICIT_WAIT, PAGE_LOAD_TIMEOUT
from automation.utils.logger import get_logger

logger = get_logger("DriverFactory")

class DriverFactory:
    @staticmethod
    def create_driver(browser_name: str = None, headless: bool = None) -> webdriver.Remote:
        """Initializes and returns a configured Selenium WebDriver instance."""
        target_browser = (browser_name or BROWSER).lower()
        is_headless = HEADLESS if headless is None else headless

        logger.info(f"Initializing WebDriver for browser: '{target_browser}', Headless: {is_headless}")

        driver = None

        if target_browser == "chrome":
            options = ChromeOptions()
            options.page_load_strategy = "eager"
            if is_headless:
                options.add_argument("--headless=new")
            options.add_argument("--no-sandbox")
            options.add_argument("--disable-dev-shm-usage")
            options.add_argument("--disable-gpu")
            options.add_argument("--window-size=1920,1080")
            options.add_argument("--disable-extensions")
            options.add_argument("--disable-popup-blocking")
            options.add_argument("--ignore-certificate-errors")
            options.add_argument("--allow-running-insecure-content")
            options.add_argument("--remote-allow-origins=*")
            options.add_argument("--disable-background-timer-throttling")
            options.add_argument("--disable-backgrounding-occluded-windows")
            options.add_argument("--disable-renderer-backgrounding")
            options.add_argument("--user-agent=AgroSentry-Selenium-E2E-Automation/1.0")

            # Enable browser console logging
            options.set_capability("goog:loggingPrefs", {"browser": "ALL", "performance": "ALL"})

            try:
                # Use selenium 4 built-in manager
                driver = webdriver.Chrome(options=options)
            except Exception as e:
                logger.warning(f"Default Chrome init failed: {e}. Trying webdriver-manager...")
                try:
                    from webdriver_manager.chrome import ChromeDriverManager
                    service = ChromeService(ChromeDriverManager().install())
                    driver = webdriver.Chrome(service=service, options=options)
                except Exception as inner_e:
                    logger.error(f"Failed to initialize Chrome driver with manager: {inner_e}")
                    raise

        elif target_browser == "edge":
            options = EdgeOptions()
            if is_headless:
                options.add_argument("--headless=new")
            options.add_argument("--no-sandbox")
            options.add_argument("--disable-dev-shm-usage")
            options.add_argument("--window-size=1920,1080")
            driver = webdriver.Edge(options=options)

        elif target_browser == "firefox":
            options = FirefoxOptions()
            if is_headless:
                options.add_argument("-headless")
            options.add_argument("--width=1920")
            options.add_argument("--height=1080")
            driver = webdriver.Firefox(options=options)

        else:
            raise ValueError(f"Unsupported browser type: {target_browser}")

        driver.implicitly_wait(IMPLICIT_WAIT)
        driver.set_page_load_timeout(PAGE_LOAD_TIMEOUT)
        logger.info(f"WebDriver successfully initialized ({driver.session_id})")
        return driver
