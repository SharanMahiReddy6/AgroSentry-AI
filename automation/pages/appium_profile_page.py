try:
    from appium.webdriver.common.appiumby import AppiumBy
except ImportError:
    class AppiumBy:
        ACCESSIBILITY_ID = "accessibility id"
        XPATH = "xpath"
        ID = "id"

from automation.pages.appium_base_page import AppiumBasePage

class AppiumProfilePage(AppiumBasePage):
    """Mobile Profile Management Page Object."""

    PROFILE_AVATAR = (AppiumBy.ACCESSIBILITY_ID, "profile_avatar_image")
    FARMER_NAME_TEXT = (AppiumBy.ACCESSIBILITY_ID, "profile_farmer_name")
    FARMER_EMAIL_TEXT = (AppiumBy.ACCESSIBILITY_ID, "profile_farmer_email")
    EDIT_PROFILE_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "profile_edit_btn")
    FARM_LOCATION_INPUT = (AppiumBy.ACCESSIBILITY_ID, "profile_farm_location_input")
    FARM_SIZE_INPUT = (AppiumBy.ACCESSIBILITY_ID, "profile_farm_size_input")
    PRIMARY_CROPS_MULTISELECT = (AppiumBy.ACCESSIBILITY_ID, "profile_crops_multiselect")
    LANGUAGE_SELECTOR = (AppiumBy.ACCESSIBILITY_ID, "profile_language_selector")
    THEME_TOGGLE = (AppiumBy.ACCESSIBILITY_ID, "profile_dark_mode_switch")
    OFFLINE_SYNC_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "profile_sync_offline_data_btn")
    LOGOUT_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "profile_logout_btn")
    CONFIRM_LOGOUT_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "confirm_logout_dialog_btn")

    def tap_logout(self):
        self.click(self.LOGOUT_BUTTON)
        self.click(self.CONFIRM_LOGOUT_BUTTON)
        return self

    def select_language(self, lang_code: str):
        self.click(self.LANGUAGE_SELECTOR)
        lang_item = (AppiumBy.ACCESSIBILITY_ID, f"lang_option_{lang_code}")
        self.click(lang_item)
        return self

    def is_profile_screen_visible(self) -> bool:
        return self.is_displayed(self.FARMER_NAME_TEXT) or self.is_displayed(self.LOGOUT_BUTTON)
