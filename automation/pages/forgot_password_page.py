from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class ForgotPasswordPage(BasePage):
    EMAIL_INPUT = (By.CSS_SELECTOR, "input[type='email']")
    SUBMIT_BUTTON = (By.CSS_SELECTOR, "button[type='submit']")
    BACK_TO_LOGIN_LINK = (By.CSS_SELECTOR, "a[href*='login']")
    OTP_INPUT = (By.CSS_SELECTOR, "input[name='otp'], input[placeholder*='OTP' i]")

    def __init__(self, driver):
        super().__init__(driver, "forgot-password/")

    def request_reset(self, email: str):
        self.type_text(self.EMAIL_INPUT, email)
        self.click(self.SUBMIT_BUTTON)

    def click_back_to_login(self):
        self.click(self.BACK_TO_LOGIN_LINK)
