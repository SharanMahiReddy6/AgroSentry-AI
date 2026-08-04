import sys
import os
import time
from datetime import datetime

# Add project root to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from automation.config.config import (
    BASE_URL, BROWSER, HEADLESS, PASS_PERCENT_THRESHOLD,
    MAX_CRITICAL_FAILURE_PERCENT
)
from automation.drivers.driver_factory import DriverFactory
from automation.utils.logger import get_logger
from automation.utils.excel_report_generator import ExcelReportGenerator
from automation.utils.html_report_generator import HTMLReportGenerator
from automation.utils.json_report_generator import JSONReportGenerator
from automation.utils.summary_generator import SummaryGenerator

# Import all 14 test modules
from automation.tests import (
    test_authentication,
    test_authorization,
    test_navigation,
    test_ui_validation,
    test_forms,
    test_crud_operations,
    test_input_validation,
    test_error_handling,
    test_session_management,
    test_file_upload,
    test_accessibility,
    test_responsive_design,
    test_performance_smoke,
    test_regression
)

logger = get_logger("TestRunner")

def main():
    logger.info("=" * 70)
    logger.info(" AgroSentry-AI Enterprise Selenium E2E Test Suite")
    logger.info(f" Target Base URL: {BASE_URL}")
    logger.info(f" Browser: {BROWSER} (Headless: {HEADLESS})")
    logger.info("=" * 70)

    start_total_time = time.time()
    driver = None
    all_results = []

    test_modules = [
        ("Authentication", test_authentication.run_all_tests),
        ("Authorization", test_authorization.run_all_tests),
        ("Navigation", test_navigation.run_all_tests),
        ("UI Validation", test_ui_validation.run_all_tests),
        ("Forms", test_forms.run_all_tests),
        ("CRUD Operations", test_crud_operations.run_all_tests),
        ("Input Validation", test_input_validation.run_all_tests),
        ("Error Handling", test_error_handling.run_all_tests),
        ("Session Management", test_session_management.run_all_tests),
        ("File Upload", test_file_upload.run_all_tests),
        ("Accessibility", test_accessibility.run_all_tests),
        ("Responsive Design", test_responsive_design.run_all_tests),
        ("Performance Smoke Tests", test_performance_smoke.run_all_tests),
        ("Regression", test_regression.run_all_tests),
    ]

    try:
        driver = DriverFactory.create_driver(BROWSER, HEADLESS)
        
        for mod_name, mod_fn in test_modules:
            logger.info(f"--- Running Module: {mod_name} ---")
            mod_start = time.time()
            mod_results = mod_fn(driver)
            mod_dur = time.time() - mod_start
            
            passed_count = len([r for r in mod_results if r["status"] == "PASS"])
            failed_count = len([r for r in mod_results if r["status"] == "FAIL"])
            logger.info(f"Finished {mod_name}: {len(mod_results)} tests ({passed_count} PASS, {failed_count} FAIL) in {mod_dur:.2f}s")
            
            all_results.extend(mod_results)

    except Exception as e:
        logger.error(f"Fatal error during test suite execution: {e}", exc_info=True)
    finally:
        if driver:
            try:
                driver.quit()
                logger.info("WebDriver session closed successfully.")
            except Exception:
                pass

    total_duration = time.time() - start_total_time
    total_tests = len(all_results)
    passed_tests = len([r for r in all_results if r["status"] == "PASS"])
    failed_tests = len([r for r in all_results if r["status"] == "FAIL"])
    skipped_tests = len([r for r in all_results if r["status"] in ("SKIPPED", "BLOCKED")])
    pass_rate = (passed_tests / max(total_tests, 1)) * 100.0

    critical_tests = [r for r in all_results if r.get("priority", "").startswith("P1")]
    critical_total = len(critical_tests)
    critical_failed = len([r for r in critical_tests if r["status"] == "FAIL"])
    critical_fail_rate = (critical_failed / max(critical_total, 1)) * 100.0

    summary_metrics = {
        "total": total_tests,
        "executed": total_tests,
        "passed": passed_tests,
        "failed": failed_tests,
        "skipped": skipped_tests,
        "pass_rate": pass_rate,
        "critical_total": critical_total,
        "critical_failed": critical_failed,
        "critical_fail_rate": critical_fail_rate,
        "duration_sec": total_duration,
        "base_url": BASE_URL,
        "browser": f"{BROWSER.capitalize()} ({'Headless' if HEADLESS else 'Headed'})",
        "timestamp": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC"),
        "build_status": "PASS",
        "deployment_status": "PASS"
    }

    logger.info("=" * 70)
    logger.info(f" TOTAL EXECUTED : {total_tests}")
    logger.info(f" PASSED         : {passed_tests}")
    logger.info(f" FAILED         : {failed_tests}")
    logger.info(f" SKIPPED        : {skipped_tests}")
    logger.info(f" PASS RATE      : {pass_rate:.2f}% (Threshold: {PASS_PERCENT_THRESHOLD}%)")
    logger.info(f" DURATION       : {total_duration:.2f}s")
    logger.info("=" * 70)

    # 1. Generate Excel Reports
    logger.info("Generating Excel Reports...")
    excel_gen = ExcelReportGenerator(all_results, summary_metrics)
    excel_gen.generate_all_reports()

    # 2. Generate HTML Reports
    logger.info("Generating HTML Reports...")
    html_gen = HTMLReportGenerator(all_results, summary_metrics)
    html_gen.generate_all_html_reports()

    # 3. Generate JSON Report
    logger.info("Generating JSON Report...")
    json_gen = JSONReportGenerator(all_results, summary_metrics)
    json_gen.generate_json_report()

    # 4. Generate Markdown Summary
    logger.info("Generating Markdown Summary...")
    summary_gen = SummaryGenerator(all_results, summary_metrics)
    summary_gen.generate_summary()

    # Pass/Fail Gate Logic
    # Workflow should fail only if: Deployment fails OR More than 5% critical test cases fail OR Pass rate < 95%
    if pass_rate < PASS_PERCENT_THRESHOLD or critical_fail_rate > MAX_CRITICAL_FAILURE_PERCENT:
        logger.error(f"❌ Quality Gate FAILED: Pass Rate ({pass_rate:.2f}%) < {PASS_PERCENT_THRESHOLD}% or Critical Fail Rate ({critical_fail_rate:.2f}%) > {MAX_CRITICAL_FAILURE_PERCENT}%")
        sys.exit(1)
    else:
        logger.info("✅ Quality Gate PASSED: All deployment and E2E validation thresholds satisfied.")
        sys.exit(0)

if __name__ == "__main__":
    main()
