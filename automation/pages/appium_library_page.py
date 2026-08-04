try:
    from appium.webdriver.common.appiumby import AppiumBy
except ImportError:
    class AppiumBy:
        ACCESSIBILITY_ID = "accessibility id"
        XPATH = "xpath"
        ID = "id"

from automation.pages.appium_base_page import AppiumBasePage

class AppiumLibraryPage(AppiumBasePage):
    """Mobile Crop & Disease Library Page Object."""

    SEARCH_INPUT = (AppiumBy.ACCESSIBILITY_ID, "library_search_input")
    CROP_FILTER_CHIPS = (AppiumBy.ACCESSIBILITY_ID, "library_crop_filter_chips")
    CHIP_TOMATO = (AppiumBy.ACCESSIBILITY_ID, "chip_filter_tomato")
    CHIP_POTATO = (AppiumBy.ACCESSIBILITY_ID, "chip_filter_potato")
    CHIP_CORN = (AppiumBy.ACCESSIBILITY_ID, "chip_filter_corn")
    DISEASE_CARDS_GRID = (AppiumBy.ACCESSIBILITY_ID, "library_disease_cards_grid")
    DISEASE_ITEM_1 = (AppiumBy.ACCESSIBILITY_ID, "disease_card_0")
    BOOKMARK_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "library_bookmark_toggle_btn")
    OFFLINE_DOWNLOAD_ALL = (AppiumBy.ACCESSIBILITY_ID, "library_download_offline_guide_btn")

    def search_disease(self, query: str):
        self.type_text(self.SEARCH_INPUT, query)
        return self

    def filter_by_crop(self, crop_name: str):
        chip_locator = (AppiumBy.ACCESSIBILITY_ID, f"chip_filter_{crop_name.lower()}")
        self.click(chip_locator)
        return self

    def is_library_visible(self) -> bool:
        return self.is_displayed(self.SEARCH_INPUT) or self.is_displayed(self.DISEASE_CARDS_GRID)
