try:
    from appium.webdriver.common.appiumby import AppiumBy
except ImportError:
    class AppiumBy:
        ACCESSIBILITY_ID = "accessibility id"
        XPATH = "xpath"
        ID = "id"

from automation.pages.appium_base_page import AppiumBasePage

class AppiumNavigationPage(AppiumBasePage):
    """Mobile Navigation Page Object (Bottom Navigation, Drawer, App Bar)."""

    # Bottom Navigation Bar Items
    NAV_HOME = (AppiumBy.ACCESSIBILITY_ID, "nav_bottom_home_tab")
    NAV_SCAN = (AppiumBy.ACCESSIBILITY_ID, "nav_bottom_scan_tab")
    NAV_HISTORY = (AppiumBy.ACCESSIBILITY_ID, "nav_bottom_history_tab")
    NAV_LIBRARY = (AppiumBy.ACCESSIBILITY_ID, "nav_bottom_library_tab")
    NAV_PROFILE = (AppiumBy.ACCESSIBILITY_ID, "nav_bottom_profile_tab")

    # App Bar Elements
    APP_BAR_TITLE = (AppiumBy.ACCESSIBILITY_ID, "app_bar_title_text")
    APP_BAR_DRAWER_BTN = (AppiumBy.ACCESSIBILITY_ID, "app_bar_drawer_toggle")
    APP_BAR_BACK_BTN = (AppiumBy.ACCESSIBILITY_ID, "app_bar_back_button")
    DRAWER_ADMIN_PANEL = (AppiumBy.ACCESSIBILITY_ID, "drawer_item_admin_panel")
    DRAWER_SETTINGS = (AppiumBy.ACCESSIBILITY_ID, "drawer_item_settings")
    DRAWER_HELP_SUPPORT = (AppiumBy.ACCESSIBILITY_ID, "drawer_item_help")

    def go_to_home(self):
        self.click(self.NAV_HOME)
        return self

    def go_to_scan(self):
        self.click(self.NAV_SCAN)
        return self

    def go_to_history(self):
        self.click(self.NAV_HISTORY)
        return self

    def go_to_library(self):
        self.click(self.NAV_LIBRARY)
        return self

    def go_to_profile(self):
        self.click(self.NAV_PROFILE)
        return self

    def tap_back(self):
        self.click(self.APP_BAR_BACK_BTN)
        return self
