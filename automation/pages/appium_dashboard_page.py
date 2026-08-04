try:
    from appium.webdriver.common.appiumby import AppiumBy
except ImportError:
    class AppiumBy:
        ACCESSIBILITY_ID = "accessibility id"
        XPATH = "xpath"
        ID = "id"

from automation.pages.appium_base_page import AppiumBasePage

class AppiumDashboardPage(AppiumBasePage):
    """Mobile Dashboard Page Object."""

    FARMER_GREETING = (AppiumBy.ACCESSIBILITY_ID, "dashboard_farmer_greeting")
    WEATHER_CARD = (AppiumBy.ACCESSIBILITY_ID, "dashboard_weather_card")
    TEMPERATURE_TEXT = (AppiumBy.ACCESSIBILITY_ID, "weather_temp_value")
    HUMIDITY_TEXT = (AppiumBy.ACCESSIBILITY_ID, "weather_humidity_value")
    QUICK_SCAN_CARD = (AppiumBy.ACCESSIBILITY_ID, "dashboard_quick_scan_card")
    SCAN_FAB_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "dashboard_scan_fab")
    RECENT_SCANS_SECTION = (AppiumBy.ACCESSIBILITY_ID, "dashboard_recent_scans_list")
    RECENT_SCAN_ITEM_1 = (AppiumBy.ACCESSIBILITY_ID, "recent_scan_item_0")
    DISEASE_ALERT_BANNER = (AppiumBy.ACCESSIBILITY_ID, "dashboard_disease_alert_banner")
    ACTIVE_CROPS_COUNTER = (AppiumBy.ACCESSIBILITY_ID, "dashboard_active_crops_count")
    HEALTHY_CROPS_PERCENT = (AppiumBy.ACCESSIBILITY_ID, "dashboard_healthy_crops_percent")
    NOTIFICATIONS_ICON = (AppiumBy.ACCESSIBILITY_ID, "dashboard_notifications_icon")
    SYNC_STATUS_BADGE = (AppiumBy.ACCESSIBILITY_ID, "dashboard_sync_status_badge")

    def tap_quick_scan(self):
        self.click(self.SCAN_FAB_BUTTON)
        return self

    def tap_notifications(self):
        self.click(self.NOTIFICATIONS_ICON)
        return self

    def is_dashboard_visible(self) -> bool:
        return self.is_displayed(self.FARMER_GREETING) or self.is_displayed(self.QUICK_SCAN_CARD) or self.is_displayed(self.SCAN_FAB_BUTTON)

    def get_greeting_text(self) -> str:
        return self.get_text(self.FARMER_GREETING)
