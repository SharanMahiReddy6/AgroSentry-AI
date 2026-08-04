from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class RegisterPage(BasePage):
    NAME_INPUT = (By.CSS_SELECTOR, "input[name='name'], input[placeholder*='name' i]")
    EMAIL_INPUT = (By.CSS_SELECTOR, "input[type='email']")
    PASSWORD_INPUT = (By.CSS_SELECTOR, "input[name='password'], input[placeholder*='password' i]")
    SUBMIT_BUTTON = (By.CSS_SELECTOR, "button[type='submit']")
    LOGIN_LINK = (By.CSS_SELECTOR, "a[href*='login']")
    ROLE_SELECT = (By.CSS_SELECTOR, "select[name='role']")

    def __init__(self, driver):
        super().__init__(driver, "register/")

    def register(self, email: str, password: str, name: str = "Test User"):
        if self.is_present(self.NAME_INPUT):
            self.type_text(self.NAME_INPUT, name)
        self.type_text(self.EMAIL_INPUT, email)
        self.type_text(self.PASSWORD_INPUT, password)
        self.click(self.SUBMIT_BUTTON)

    def click_login(self):
        self.click(self.LOGIN_LINK)
