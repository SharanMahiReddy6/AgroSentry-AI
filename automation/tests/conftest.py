import pytest
import time
from automation.drivers.driver_factory import DriverFactory
from automation.utils.screenshot_helper import ScreenshotHelper
from automation.config import config

@pytest.fixture(scope="session")
def base_url():
    return config.BASE_URL

@pytest.fixture(scope="function")
def driver():
    """Provides a fresh headless Chrome WebDriver instance for a test."""
    drv = DriverFactory.create_driver()
    yield drv
    try:
        drv.quit()
    except Exception:
        pass

@pytest.fixture(scope="session")
def shared_driver():
    """Provides a shared WebDriver session for high-speed batch execution."""
    drv = DriverFactory.create_driver()
    yield drv
    try:
        drv.quit()
    except Exception:
        pass
