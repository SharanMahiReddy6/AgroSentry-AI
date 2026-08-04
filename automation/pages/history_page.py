from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class HistoryPage(BasePage):
    HISTORY_ROWS = (By.CSS_SELECTOR, "table tbody tr, .card")
    SEARCH_INPUT = (By.CSS_SELECTOR, "input[type='text'], input[placeholder*='Search' i]")
    FILTER_SEVERITY = (By.CSS_SELECTOR, "select, [role='combobox']")
    EXPORT_BUTTON = (By.XPATH, "//button[contains(text(), 'Export') or contains(text(), 'Download')]")

    def __init__(self, driver):
        super().__init__(driver, "history/")

    def get_history_rows_count(self) -> int:
        return len(self.find_all(self.HISTORY_ROWS))
