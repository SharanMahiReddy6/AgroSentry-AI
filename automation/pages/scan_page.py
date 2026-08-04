from selenium.webdriver.common.by import By
from automation.pages.base_page import BasePage

class ScanPage(BasePage):
    FILE_INPUT = (By.CSS_SELECTOR, "input[type='file']")
    CROP_TYPE_SELECT = (By.CSS_SELECTOR, "select, [role='combobox']")
    SUBMIT_SCAN_BTN = (By.CSS_SELECTOR, "button[type='submit'], .btn-primary")
    DROP_ZONE = (By.CSS_SELECTOR, "[data-dropzone], .border-dashed, input[type='file']")
    RESULT_CONTAINER = (By.CSS_SELECTOR, ".card, [data-result]")
    PREDICTION_TITLE = (By.CSS_SELECTOR, "h2, h3, h4")
    TREATMENT_SECTION = (By.XPATH, "//*[contains(text(), 'Treatment') or contains(text(), 'Action Plan')]")

    def __init__(self, driver):
        super().__init__(driver, "scan/")

    def upload_file(self, file_path: str):
        file_input = self.find(self.FILE_INPUT)
        file_input.send_keys(file_path)

    def trigger_scan(self):
        self.click(self.SUBMIT_SCAN_BTN)
