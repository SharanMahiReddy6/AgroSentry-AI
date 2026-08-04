try:
    from appium.webdriver.common.appiumby import AppiumBy
except ImportError:
    class AppiumBy:
        ACCESSIBILITY_ID = "accessibility id"
        XPATH = "xpath"
        ID = "id"

from automation.pages.appium_base_page import AppiumBasePage

class AppiumNotificationsPage(AppiumBasePage):
    """Mobile Notifications Center Page Object."""

    NOTIFICATIONS_LIST = (AppiumBy.ACCESSIBILITY_ID, "notifications_list_view")
    NOTIFICATION_ITEM_0 = (AppiumBy.ACCESSIBILITY_ID, "notification_card_0")
    WEATHER_ALERT_BANNER = (AppiumBy.ACCESSIBILITY_ID, "notification_weather_alert")
    DISEASE_OUTBREAK_CARD = (AppiumBy.ACCESSIBILITY_ID, "notification_outbreak_alert")
    MARK_ALL_READ_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "notifications_mark_all_read_btn")
    CLEAR_ALL_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "notifications_clear_all_btn")
    SETTINGS_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "notifications_settings_btn")
    UNREAD_BADGE = (AppiumBy.ACCESSIBILITY_ID, "notifications_unread_badge")

    def mark_all_as_read(self):
        self.click(self.MARK_ALL_READ_BUTTON)
        return self

    def is_notifications_visible(self) -> bool:
        return self.is_displayed(self.NOTIFICATIONS_LIST) or self.is_displayed(self.MARK_ALL_READ_BUTTON)
