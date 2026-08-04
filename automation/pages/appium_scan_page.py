try:
    from appium.webdriver.common.appiumby import AppiumBy
except ImportError:
    class AppiumBy:
        ACCESSIBILITY_ID = "accessibility id"
        XPATH = "xpath"
        ID = "id"

from automation.pages.appium_base_page import AppiumBasePage

class AppiumScanPage(AppiumBasePage):
    """Mobile AI Disease Scanner Page Object."""

    CAMERA_PREVIEW = (AppiumBy.ACCESSIBILITY_ID, "scan_camera_preview")
    CAPTURE_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "scan_capture_btn")
    GALLERY_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "scan_gallery_pick_btn")
    FLASHLIGHT_TOGGLE = (AppiumBy.ACCESSIBILITY_ID, "scan_flashlight_toggle")
    CROP_SELECTOR = (AppiumBy.ACCESSIBILITY_ID, "scan_crop_selector_dropdown")
    SCAN_FRAME = (AppiumBy.ACCESSIBILITY_ID, "scan_leaf_guide_frame")
    PROCESSING_INDICATOR = (AppiumBy.ACCESSIBILITY_ID, "scan_ai_processing_indicator")
    
    # Diagnosis Result Screen
    RESULT_CONTAINER = (AppiumBy.ACCESSIBILITY_ID, "diagnosis_result_container")
    DISEASE_NAME = (AppiumBy.ACCESSIBILITY_ID, "diagnosis_disease_name")
    CONFIDENCE_SCORE = (AppiumBy.ACCESSIBILITY_ID, "diagnosis_confidence_score")
    SEVERITY_BADGE = (AppiumBy.ACCESSIBILITY_ID, "diagnosis_severity_badge")
    TREATMENT_TABS = (AppiumBy.ACCESSIBILITY_ID, "diagnosis_treatment_tabs")
    ORGANIC_TREATMENT = (AppiumBy.ACCESSIBILITY_ID, "diagnosis_organic_treatment_text")
    CHEMICAL_TREATMENT = (AppiumBy.ACCESSIBILITY_ID, "diagnosis_chemical_treatment_text")
    SAVE_RESULT_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "diagnosis_save_record_btn")
    RETRY_SCAN_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "diagnosis_scan_again_btn")

    def tap_capture(self):
        self.click(self.CAPTURE_BUTTON)
        return self

    def tap_gallery_picker(self):
        self.click(self.GALLERY_BUTTON)
        return self

    def is_scanner_active(self) -> bool:
        return self.is_displayed(self.CAPTURE_BUTTON) or self.is_displayed(self.CAMERA_PREVIEW)

    def is_result_displayed(self) -> bool:
        return self.is_displayed(self.RESULT_CONTAINER) or self.is_displayed(self.DISEASE_NAME)
