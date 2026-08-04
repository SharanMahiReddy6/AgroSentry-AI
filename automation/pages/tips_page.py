from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class TipsPage(BasePage):
    TIP_CARDS = (By.CSS_SELECTOR, ".card, [data-tip-card]")
    SEARCH_INPUT = (By.CSS_SELECTOR, "input[type='text'], input[placeholder*='Search' i]")
    CATEGORY_TAGS = (By.CSS_SELECTOR, ".badge, [data-category]")

    def __init__(self, driver):
        super().__init__(driver, "tips/")

    def get_tips_count(self) -> int:
        return len(self.find_all(self.TIP_CARDS))
