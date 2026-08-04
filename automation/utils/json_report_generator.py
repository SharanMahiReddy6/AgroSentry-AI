import os
import json
from datetime import datetime
from pathlib import Path
from automation.config.config import JSON_RESULTS_DIR, REPORTS_DIR
from automation.utils.logger import get_logger

logger = get_logger("JSONReportGenerator")

class JSONReportGenerator:
    def __init__(self, test_results: list, summary_metrics: dict):
        self.results = test_results
        self.metrics = summary_metrics

    def generate_json_report(self) -> Path:
        payload = {
            "report_metadata": {
                "generated_at": datetime.utcnow().isoformat() + "Z",
                "framework": "AgroSentry Appium E2E Automation v2.0",
                "platform": self.metrics.get("platform", "Android"),
                "device": self.metrics.get("device_name", "Android Emulator"),
                "appium_server": self.metrics.get("appium_server", ""),
                "git_commit": self.metrics.get("git_commit", ""),
                "build_number": self.metrics.get("build_number", ""),
            },
            "summary": {
                "total": self.metrics.get("total", 0),
                "executed": self.metrics.get("executed", 0),
                "passed": self.metrics.get("passed", 0),
                "failed": self.metrics.get("failed", 0),
                "skipped": self.metrics.get("skipped", 0),
                "pass_rate": round(self.metrics.get("pass_rate", 0.0), 2),
                "fail_rate": round(self.metrics.get("fail_rate", 0.0), 2),
                "duration_sec": round(self.metrics.get("duration_sec", 0.0), 2),
                "critical_failed": self.metrics.get("critical_failed", 0),
            },
            "test_results": self.results,
        }

        out1 = JSON_RESULTS_DIR / "execution-results.json"
        out2 = REPORTS_DIR / "execution-results.json"
        for out in [out1, out2]:
            with open(out, "w", encoding="utf-8") as f:
                json.dump(payload, f, indent=2, ensure_ascii=False, default=str)
        logger.info(f"Generated JSON report: {out1}")
        return out1
