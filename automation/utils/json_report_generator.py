import json
from pathlib import Path
from automation.config.config import JSON_RESULTS_DIR, REPORTS_DIR
from automation.utils.logger import get_logger

logger = get_logger("JSONReportGenerator")

class JSONReportGenerator:
    def __init__(self, test_results: list[dict], summary_metrics: dict):
        self.results = test_results
        self.metrics = summary_metrics

    def generate_json_report(self) -> Path:
        payload = {
            "summary": self.metrics,
            "results": self.results
        }
        
        out_file_1 = JSON_RESULTS_DIR / "execution-results.json"
        out_file_2 = REPORTS_DIR / "execution-results.json"
        
        with open(out_file_1, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2)
        with open(out_file_2, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2)
            
        logger.info(f"Generated JSON report: {out_file_1}")
        return out_file_1
