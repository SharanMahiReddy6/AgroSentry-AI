from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class ProfilePage(BasePage):
    NAME_INPUT = (By.CSS_SELECTOR, "input[name='name'], input[placeholder*='name' i]")
    EMAIL_INPUT = (By.CSS_SELECTOR, "input[type='email']")
    THEME_TOGGLE = (By.CSS_SELECTOR, "[data-theme-toggle], button:has(svg)")
    LANGUAGE_SELECT = (By.CSS_SELECTOR, "select[name='language'], select")
    SAVE_BUTTON = (By.CSS_SELECTOR, "button[type='submit'], .btn-primary")

    def __init__(self, driver):
        super().__init__(driver, "profile/")
