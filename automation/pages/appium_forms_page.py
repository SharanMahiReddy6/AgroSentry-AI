try:
    from appium.webdriver.common.appiumby import AppiumBy
except ImportError:
    class AppiumBy:
        ACCESSIBILITY_ID = "accessibility id"
        XPATH = "xpath"
        ID = "id"

from automation.pages.appium_base_page import AppiumBasePage

class AppiumFormsPage(AppiumBasePage):
    """Mobile Form Controls and CRUD Input Page Object."""

    FIELD_PLOT_NAME = (AppiumBy.ACCESSIBILITY_ID, "form_plot_name_input")
    FIELD_CROP_TYPE = (AppiumBy.ACCESSIBILITY_ID, "form_crop_type_dropdown")
    FIELD_ACREAGE = (AppiumBy.ACCESSIBILITY_ID, "form_acreage_input")
    FIELD_SOIL_PH = (AppiumBy.ACCESSIBILITY_ID, "form_soil_ph_slider")
    FIELD_SOWING_DATE = (AppiumBy.ACCESSIBILITY_ID, "form_sowing_date_picker")
    RADIO_IRRIGATION_DRIP = (AppiumBy.ACCESSIBILITY_ID, "form_irrigation_drip_radio")
    RADIO_IRRIGATION_SPRINKLER = (AppiumBy.ACCESSIBILITY_ID, "form_irrigation_sprinkler_radio")
    FIELD_NOTES = (AppiumBy.ACCESSIBILITY_ID, "form_notes_textarea")
    SUBMIT_FORM_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "form_submit_btn")
    RESET_FORM_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "form_reset_btn")
    VALIDATION_ERROR_MSG = (AppiumBy.ACCESSIBILITY_ID, "form_validation_error")

    def fill_plot_form(self, name: str, crop: str, acreage: str):
        self.type_text(self.FIELD_PLOT_NAME, name)
        self.type_text(self.FIELD_ACREAGE, acreage)
        return self

    def submit_form(self):
        self.click(self.SUBMIT_FORM_BUTTON)
        return self

    def is_form_rendered(self) -> bool:
        return self.is_displayed(self.FIELD_PLOT_NAME) or self.is_displayed(self.SUBMIT_FORM_BUTTON)
