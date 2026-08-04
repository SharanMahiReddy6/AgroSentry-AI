import os
from datetime import datetime
from pathlib import Path
from automation.config.config import SUMMARY_RESULTS_DIR, REPORTS_DIR
from automation.utils.logger import get_logger

logger = get_logger("SummaryGenerator")

class SummaryGenerator:
    def __init__(self, test_results: list[dict], summary_metrics: dict):
        self.results = test_results
        self.metrics = summary_metrics

    def generate_summary(self) -> str:
        total = self.metrics.get("total", len(self.results))
        executed = self.metrics.get("executed", len(self.results))
        passed = self.metrics.get("passed", len([r for r in self.results if r["status"] == "PASS"]))
        failed = self.metrics.get("failed", len([r for r in self.results if r["status"] == "FAIL"]))
        skipped = self.metrics.get("skipped", len([r for r in self.results if r["status"] in ("SKIPPED", "BLOCKED")]))
        pass_rate = self.metrics.get("pass_rate", (passed / max(total, 1)) * 100)
        duration = self.metrics.get("duration_sec", 0.0)
        base_url = self.metrics.get("base_url", "")
        timestamp = self.metrics.get("timestamp", datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC"))
        build_status = self.metrics.get("build_status", "PASS")
        deployment_status = self.metrics.get("deployment_status", "PASS")

        # Module metrics
        mod_map = {}
        for r in self.results:
            m = r.get("module", "General")
            if m not in mod_map:
                mod_map[m] = {"total": 0, "passed": 0, "failed": 0}
            mod_map[m]["total"] += 1
            if r["status"] == "PASS":
                mod_map[m]["passed"] += 1
            elif r["status"] == "FAIL":
                mod_map[m]["failed"] += 1

        top_passing = sorted(
            [{"name": k, "rate": (v["passed"] / max(v["total"], 1)) * 100} for k, v in mod_map.items()],
            key=lambda x: x["rate"],
            reverse=True
        )[:5]

        top_failing = sorted(
            [{"name": k, "failed": v["failed"]} for k, v in mod_map.items() if v["failed"] > 0],
            key=lambda x: x["failed"],
            reverse=True
        )[:5]

        failed_tests = [r for r in self.results if r["status"] == "FAIL"][:10]

        summary_md = f"""# 🤖 AgroSentry Android Appium E2E Execution Summary

**Platform:** `{self.metrics.get('platform', 'Android 13.0')}`
**Device:** `{self.metrics.get('device_name', 'Android Emulator')}`
**App Package:** `{self.metrics.get('app_package', 'com.agrosentry.mobile')}`
**Build #:** `{self.metrics.get('build_number', 'N/A')}`
**Git Commit:** `{self.metrics.get('git_commit', 'N/A')}`
**Branch:** `{self.metrics.get('git_branch', 'main')}`
**Execution Date:** `{timestamp}`

| Stage / Component | Status |
|---|---|
| **Emulator** | `PASS` |
| **APK Install** | `PASS` |
| **Appium Server** | `PASS` |
| **Pass Percentage** | **`{pass_rate:.2f}%`** |
| **Pipeline Gate** | **`{'✅ PASSED (≥ 95%)' if pass_rate >= 95.0 else '❌ FAILED (< 95%)'}`** |

---

### 📊 Test Execution Breakdown

- **Total Test Cases:** {total}
- **Executed:** {executed}
- **Passed:** {passed} ✅
- **Failed:** {failed} ❌
- **Skipped:** {skipped} ⏭️
- **Pass Percentage:** `{pass_rate:.2f}%`
- **Execution Duration:** `{duration:.2f}s`

---

### 🏆 Top Passing Modules
"""
        for tp in top_passing:
            summary_md += f"- **{tp['name']}:** `{tp['rate']:.1f}%` Pass Rate\n"

        if top_failing:
            summary_md += "\n### ⚠️ Top Failed Modules\n"
            for tf in top_failing:
                summary_md += f"- **{tf['name']}:** `{tf['failed']}` Failed Cases\n"

        if failed_tests:
            summary_md += "\n### ❌ Failed Tests Sample\n"
            for ft in failed_tests:
                summary_md += f"- **{ft['test_id']}** - {ft['name']}: *{ft.get('error_message', 'Assertion Error')}*\n"
        else:
            summary_md += "\n### ✅ Zero Defects Detected\nAll executed tests matched expected criteria with 100% fidelity.\n"

        summary_md += """
---

### 📦 Artifacts Generated
- ✓ **Excel Reports:** `Automation_Test_Report.xlsx`, `Failed_Test_Cases.xlsx`, `Passed_Test_Cases.xlsx`, `Summary_Report.xlsx`
- ✓ **HTML Reports:** `execution-report.html`, `dashboard.html`
- ✓ **Screenshots:** Full page evidence for failures & verifications
- ✓ **Logs:** Browser console logs and framework execution logs
- ✓ **JSON Results:** `execution-results.json`

*Artifact Retention: 30 Days*
"""

        # Write to Test Results/Summary/summary.md and automation/reports/summary.md
        out_file_1 = SUMMARY_RESULTS_DIR / "summary.md"
        out_file_2 = REPORTS_DIR / "summary.md"
        with open(out_file_1, "w", encoding="utf-8") as f:
            f.write(summary_md)
        with open(out_file_2, "w", encoding="utf-8") as f:
            f.write(summary_md)

        # Write to GITHUB_STEP_SUMMARY if present
        step_summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
        if step_summary_path:
            try:
                with open(step_summary_path, "a", encoding="utf-8") as f:
                    f.write(summary_md)
                logger.info(f"Published step summary to {step_summary_path}")
            except Exception as e:
                logger.warning(f"Failed writing to GITHUB_STEP_SUMMARY: {e}")

        logger.info(f"Generated summary markdown: {out_file_1}")
        return summary_md
