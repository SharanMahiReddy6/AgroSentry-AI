from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class AdminPage(BasePage):
    USER_TABLE = (By.CSS_SELECTOR, "table")
    STATS_SUMMARY = (By.CSS_SELECTOR, ".grid, .card")
    ADD_DISEASE_BTN = (By.XPATH, "//button[contains(text(), 'Add Disease') or contains(text(), 'New')]")
    ADD_TIP_BTN = (By.XPATH, "//button[contains(text(), 'Add Tip') or contains(text(), 'New')]")

    def __init__(self, driver):
        super().__init__(driver, "admin/")
