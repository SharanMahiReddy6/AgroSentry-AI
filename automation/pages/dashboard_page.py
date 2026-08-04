from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class DashboardPage(BasePage):
    WELCOME_BANNER = (By.CSS_SELECTOR, "h1")
    NEW_SCAN_BUTTON = (By.CSS_SELECTOR, "a[href*='scan']")
    STATS_CARDS = (By.CSS_SELECTOR, ".grid .card, .card")
    RECENT_SCANS_SECTION = (By.XPATH, "//*[contains(text(), 'Recent Scans')]")
    EXPERT_TIPS_SECTION = (By.XPATH, "//*[contains(text(), 'Expert Tips')]")
    LIBRARY_LINK = (By.CSS_SELECTOR, "a[href*='library']")
    HISTORY_LINK = (By.CSS_SELECTOR, "a[href*='history']")
    SIDEBAR = (By.CSS_SELECTOR, "aside, nav, .sidebar")
    PROFILE_LINK = (By.CSS_SELECTOR, "a[href*='profile']")
    LOGOUT_BUTTON = (By.XPATH, "//button[contains(text(), 'Logout') or contains(text(), 'Sign Out')]")

    def __init__(self, driver):
        super().__init__(driver, "")

    def click_new_scan(self):
        self.click(self.NEW_SCAN_BUTTON)

    def click_library(self):
        self.click(self.LIBRARY_LINK)

    def click_history(self):
        self.click(self.HISTORY_LINK)

    def click_profile(self):
        self.click(self.PROFILE_LINK)

    def get_stats_count(self) -> int:
        return len(self.find_all(self.STATS_CARDS))
