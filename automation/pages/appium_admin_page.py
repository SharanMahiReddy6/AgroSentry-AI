try:
    from appium.webdriver.common.appiumby import AppiumBy
except ImportError:
    class AppiumBy:
        ACCESSIBILITY_ID = "accessibility id"
        XPATH = "xpath"
        ID = "id"

from automation.pages.appium_base_page import AppiumBasePage

class AppiumAdminPage(AppiumBasePage):
    """Mobile Admin Portal Page Object."""

    ADMIN_TITLE = (AppiumBy.ACCESSIBILITY_ID, "admin_dashboard_title")
    METRICS_USERS_COUNT = (AppiumBy.ACCESSIBILITY_ID, "admin_total_users_count")
    METRICS_SCANS_COUNT = (AppiumBy.ACCESSIBILITY_ID, "admin_total_scans_count")
    METRICS_AI_ACCURACY = (AppiumBy.ACCESSIBILITY_ID, "admin_ai_model_accuracy_rate")
    RETRAIN_MODEL_BTN = (AppiumBy.ACCESSIBILITY_ID, "admin_retrain_model_btn")
    AUDIT_LOGS_LIST = (AppiumBy.ACCESSIBILITY_ID, "admin_audit_logs_list")
    SYSTEM_HEALTH_BADGE = (AppiumBy.ACCESSIBILITY_ID, "admin_system_health_badge")

    def tap_retrain_model(self):
        self.click(self.RETRAIN_MODEL_BTN)
        return self

    def is_admin_screen_visible(self) -> bool:
        return self.is_displayed(self.ADMIN_TITLE) or self.is_displayed(self.METRICS_USERS_COUNT)
