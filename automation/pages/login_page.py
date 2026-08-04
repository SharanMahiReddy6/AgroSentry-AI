from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class LoginPage(BasePage):
    EMAIL_INPUT = (By.CSS_SELECTOR, "input[type='email']")
    PASSWORD_INPUT = (By.CSS_SELECTOR, "input[type='password']")
    SUBMIT_BUTTON = (By.CSS_SELECTOR, "button[type='submit']")
    FORGOT_PASSWORD_LINK = (By.CSS_SELECTOR, "a[href*='forgot-password']")
    REGISTER_LINK = (By.CSS_SELECTOR, "a[href*='register']")
    TITLE_HEADING = (By.CSS_SELECTOR, "h1")
    FORM = (By.CSS_SELECTOR, "form")

    def __init__(self, driver):
        super().__init__(driver, "login/")

    def enter_email(self, email: str):
        self.type_text(self.EMAIL_INPUT, email)

    def enter_password(self, password: str):
        self.type_text(self.PASSWORD_INPUT, password)

    def submit_login(self):
        self.click(self.SUBMIT_BUTTON)

    def login(self, email: str, password: str):
        self.enter_email(email)
        self.enter_password(password)
        self.submit_login()

    def click_forgot_password(self):
        self.click(self.FORGOT_PASSWORD_LINK)

    def click_register(self):
        self.click(self.REGISTER_LINK)

    def is_login_form_present(self) -> bool:
        return self.is_displayed(self.EMAIL_INPUT) and self.is_displayed(self.PASSWORD_INPUT) and self.is_displayed(self.SUBMIT_BUTTON)
