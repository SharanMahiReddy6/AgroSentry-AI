from selenium.webdriver.common.by import By
try:
    from appium.webdriver.common.appiumby import AppiumBy
except ImportError:
    class AppiumBy:
        ACCESSIBILITY_ID = "accessibility id"
        XPATH = "xpath"
        ID = "id"

from automation.pages.appium_base_page import AppiumBasePage

class AppiumAuthPage(AppiumBasePage):
    """Mobile Authentication Page Object for AgroSentry Android App."""

    # Locators (Accessibility IDs & UiAutomator2 resource IDs)
    EMAIL_INPUT = (AppiumBy.ACCESSIBILITY_ID, "login_email_input")
    PASSWORD_INPUT = (AppiumBy.ACCESSIBILITY_ID, "login_password_input")
    SIGN_IN_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "login_submit_button")
    FORGOT_PASSWORD_LINK = (AppiumBy.ACCESSIBILITY_ID, "login_forgot_password_btn")
    CREATE_ACCOUNT_LINK = (AppiumBy.ACCESSIBILITY_ID, "login_create_account_btn")
    GOOGLE_SIGN_IN_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "login_google_btn")
    APP_BRAND_LOGO = (AppiumBy.ACCESSIBILITY_ID, "agrosentry_brand_logo")
    ERROR_BANNER = (AppiumBy.ACCESSIBILITY_ID, "auth_error_banner")
    PASSWORD_TOGGLE_VISIBILITY = (AppiumBy.ACCESSIBILITY_ID, "password_visibility_toggle")
    
    # Registration locators
    REG_FULL_NAME = (AppiumBy.ACCESSIBILITY_ID, "register_fullname_input")
    REG_EMAIL = (AppiumBy.ACCESSIBILITY_ID, "register_email_input")
    REG_PASSWORD = (AppiumBy.ACCESSIBILITY_ID, "register_password_input")
    REG_CONFIRM_PASSWORD = (AppiumBy.ACCESSIBILITY_ID, "register_confirm_password_input")
    REG_TERMS_CHECKBOX = (AppiumBy.ACCESSIBILITY_ID, "register_terms_checkbox")
    REG_SUBMIT_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "register_submit_button")

    # Forgot Password / OTP locators
    FP_EMAIL_INPUT = (AppiumBy.ACCESSIBILITY_ID, "forgot_password_email_input")
    FP_SUBMIT_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "forgot_password_send_otp_btn")
    OTP_INPUT_1 = (AppiumBy.ACCESSIBILITY_ID, "otp_input_digit_1")
    OTP_INPUT_2 = (AppiumBy.ACCESSIBILITY_ID, "otp_input_digit_2")
    OTP_INPUT_3 = (AppiumBy.ACCESSIBILITY_ID, "otp_input_digit_3")
    OTP_INPUT_4 = (AppiumBy.ACCESSIBILITY_ID, "otp_input_digit_4")
    OTP_VERIFY_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "otp_verify_button")
    NEW_PASSWORD_INPUT = (AppiumBy.ACCESSIBILITY_ID, "reset_new_password_input")
    CONFIRM_NEW_PASSWORD_INPUT = (AppiumBy.ACCESSIBILITY_ID, "reset_confirm_password_input")
    RESET_PASSWORD_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "reset_password_submit_btn")

    def enter_email(self, email: str):
        self.type_text(self.EMAIL_INPUT, email)
        return self

    def enter_password(self, password: str):
        self.type_text(self.PASSWORD_INPUT, password)
        return self

    def tap_sign_in(self):
        self.click(self.SIGN_IN_BUTTON)
        return self

    def login(self, email: str, password: str):
        self.enter_email(email)
        self.enter_password(password)
        self.tap_sign_in()
        return self

    def tap_forgot_password(self):
        self.click(self.FORGOT_PASSWORD_LINK)
        return self

    def tap_create_account(self):
        self.click(self.CREATE_ACCOUNT_LINK)
        return self

    def is_login_screen_visible(self) -> bool:
        return self.is_displayed(self.SIGN_IN_BUTTON) or self.is_displayed(self.EMAIL_INPUT)

    def is_error_displayed(self) -> bool:
        return self.is_displayed(self.ERROR_BANNER)
