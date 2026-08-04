from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class LibraryPage(BasePage):
    SEARCH_INPUT = (By.CSS_SELECTOR, "input[type='text'], input[placeholder*='Search' i]")
    DISEASE_CARDS = (By.CSS_SELECTOR, ".card, [data-disease-card]")
    CROP_FILTER_BUTTONS = (By.CSS_SELECTOR, "button, .filter-btn")
    MODAL_CLOSE_BUTTON = (By.CSS_SELECTOR, "[aria-label='Close'], .close-btn, button")

    def __init__(self, driver):
        super().__init__(driver, "library/")

    def search_disease(self, keyword: str):
        self.type_text(self.SEARCH_INPUT, keyword)

    def get_disease_cards_count(self) -> int:
        return len(self.find_all(self.DISEASE_CARDS))
