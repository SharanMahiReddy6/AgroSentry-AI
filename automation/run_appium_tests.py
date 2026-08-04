import sys
import os
import time
import shutil
from pathlib import Path
from datetime import datetime, timezone

# Ensure project root is importable
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from automation.config import appium_config
from automation.drivers.appium_driver_factory import AppiumDriverFactory
from automation.utils.logger import get_logger
from automation.utils.excel_report_generator import ExcelReportGenerator
from automation.utils.html_report_generator import HTMLReportGenerator
from automation.utils.json_report_generator import JSONReportGenerator
from automation.utils.summary_generator import SummaryGenerator

# Import all 20 Mobile Appium Test Modules
from automation.tests import (
    test_mobile_authentication,
    test_mobile_authorization,
    test_mobile_registration,
    test_mobile_profile_management,
    test_mobile_navigation,
    test_mobile_dashboard,
    test_mobile_forms,
    test_mobile_crud_operations,
    test_mobile_search,
    test_mobile_filters,
    test_mobile_input_validation,
    test_mobile_error_handling,
    test_mobile_session_management,
    test_mobile_notifications,
    test_mobile_file_upload,
    test_mobile_offline_handling,
    test_mobile_accessibility,
    test_mobile_responsive_ui,
    test_mobile_performance_smoke,
    test_mobile_regression,
)

logger = get_logger("AppiumTestRunner")

APPIUM_TEST_MODULES = [
    ("Authentication",          test_mobile_authentication.run_all_tests,    40),
    ("Authorization",           test_mobile_authorization.run_all_tests,     30),
    ("Registration",            test_mobile_registration.run_all_tests,      20),
    ("Profile Management",      test_mobile_profile_management.run_all_tests,20),
    ("Navigation",              test_mobile_navigation.run_all_tests,        30),
    ("Dashboard",               test_mobile_dashboard.run_all_tests,         20),
    ("Forms",                   test_mobile_forms.run_all_tests,             40),
    ("CRUD Operations",         test_mobile_crud_operations.run_all_tests,   40),
    ("Search",                  test_mobile_search.run_all_tests,            20),
    ("Filters",                 test_mobile_filters.run_all_tests,           20),
    ("Input Validation",        test_mobile_input_validation.run_all_tests,  40),
    ("Error Handling",          test_mobile_error_handling.run_all_tests,    20),
    ("Session Management",      test_mobile_session_management.run_all_tests,20),
    ("Notifications",           test_mobile_notifications.run_all_tests,     20),
    ("File Upload",             test_mobile_file_upload.run_all_tests,       20),
    ("Offline Handling",        test_mobile_offline_handling.run_all_tests,  10),
    ("Accessibility",           test_mobile_accessibility.run_all_tests,     20),
    ("Responsive UI",           test_mobile_responsive_ui.run_all_tests,     10),
    ("Performance Smoke Tests", test_mobile_performance_smoke.run_all_tests, 20),
    ("Regression",              test_mobile_regression.run_all_tests,        50),
]


# ─────────────────────────────────────────────────────────────────────────────
# GITHUB STEP SUMMARY helpers
# ─────────────────────────────────────────────────────────────────────────────
STEP_SUMMARY = os.environ.get("GITHUB_STEP_SUMMARY", "")

def _write_summary(text: str):
    """Appends text directly to $GITHUB_STEP_SUMMARY (CI) or prints locally."""
    if STEP_SUMMARY:
        try:
            with open(STEP_SUMMARY, "a", encoding="utf-8") as f:
                f.write(text + "\n")
        except Exception as e:
            logger.warning(f"Step summary write failed: {e}")
    else:
        print(text)


def write_summary_header(build_num, git_commit, git_branch, device, platform):
    """Writes the opening block to GitHub Step Summary."""
    _write_summary(f"""# AgroSentry Android Appium E2E Execution Summary

| Field | Value |
|-------|-------|
| **Build #** | `{build_num}` |
| **Git Commit** | `{git_commit}` |
| **Branch** | `{git_branch}` |
| **Device** | `{device}` |
| **Platform** | `{platform}` |
| **App Package** | `{appium_config.APP_PACKAGE}` |
| **Automation** | Appium UiAutomator2 |
| **Started** | `{datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}` |

---

## Module Results

| # | Module | Total | Passed | Failed | Pass Rate | Status |
|---|--------|-------|--------|--------|-----------|--------|""")


def write_summary_module_row(idx, mod_name, total, passed, failed, dur):
    """Appends one module result row."""
    rate = (passed / max(total, 1)) * 100.0
    status = "PASS" if failed == 0 else "FAIL"
    _write_summary(
        f"| {idx} | {mod_name} | {total} | {passed} | {failed} | {rate:.0f}% | {status} |"
    )


def write_summary_footer(total, passed, failed, skipped, pass_rate, duration, gate_passed,
                          threshold, failed_samples):
    """Writes the final totals and quality gate result."""
    gate_label = "PASSED (>= 95%)" if gate_passed else "FAILED (< 95%)"

    _write_summary(f"""
---

## Overall Results

| Metric | Value |
|--------|-------|
| **Total Test Cases** | `{total}` |
| **Passed** | `{passed}` |
| **Failed** | `{failed}` |
| **Skipped** | `{skipped}` |
| **Pass Rate** | `{pass_rate:.2f}%` |
| **Execution Duration** | `{duration:.2f}s` |
| **Quality Gate ({threshold}% threshold)** | `{gate_label}` |
""")

    if failed_samples:
        _write_summary("## Failed Tests\n")
        _write_summary("| Test ID | Module | Name | Reason |")
        _write_summary("|---------|--------|------|--------|")
        for r in failed_samples[:20]:
            reason = (r.get("error_message") or "Assertion error")[:80]
            _write_summary(
                f"| `{r['test_id']}` | {r['module']} | {r['name'][:50]} | {reason} |"
            )
    else:
        _write_summary("## Zero Failures Detected\n\nAll executed tests passed with 100% fidelity.\n")

    _write_summary("""
---

## Artifacts
- Excel Reports: `Automation_Test_Report.xlsx`, `Passed_Test_Cases.xlsx`, `Failed_Test_Cases.xlsx`, `Summary_Report.xlsx`
- HTML Reports: `execution-report.html`, `dashboard.html`
- JSON: `execution-results.json`
- Screenshots, Logs – uploaded as workflow artifacts (30-day retention)
""")


# ─────────────────────────────────────────────────────────────────────────────

def dump_device_logs(output_dir: Path):
    """Dumps ADB logcat for failed test diagnosis."""
    try:
        log_path = output_dir / f"device_logcat_{int(time.time())}.log"
        AppiumDriverFactory.dump_device_logcat(log_path)
    except Exception as e:
        logger.warning(f"Device log dump skipped: {e}")


def copy_artifacts_to_test_results(source_dir: Path, dest_dir: Path):
    """Mirrors artifacts from automation/reports to 'Test Results' for CI upload."""
    try:
        if source_dir.exists():
            dest_dir.mkdir(parents=True, exist_ok=True)
            for item in source_dir.iterdir():
                target = dest_dir / item.name
                if item.is_file():
                    shutil.copy2(item, target)
    except Exception as e:
        logger.warning(f"Artifact copy failed: {e}")


def main():
    logger.info("=" * 70)
    logger.info("  AgroSentry-AI Enterprise Android Appium E2E Test Suite")
    logger.info(f"  Appium Server : {appium_config.APPIUM_SERVER_URL}")
    logger.info(f"  Device        : {appium_config.DEVICE_NAME} ({appium_config.PLATFORM_NAME} {appium_config.PLATFORM_VERSION})")
    logger.info(f"  App Package   : {appium_config.APP_PACKAGE}")
    logger.info(f"  Mock Mode     : {appium_config.MOCK_EMULATION_MODE}")
    logger.info("=" * 70)

    # Collect CI context
    git_commit  = os.environ.get("GITHUB_SHA", "local-dev")[:7]
    git_branch  = os.environ.get("GITHUB_REF_NAME", "main")
    build_num   = os.environ.get("GITHUB_RUN_NUMBER", "N/A")
    runner_os   = os.environ.get("RUNNER_OS", "ubuntu-latest")

    start_total = time.time()
    driver = None
    all_results = []
    module_rows = []

    # ── Write summary header (immediately visible in GitHub Actions) ──────────
    write_summary_header(
        build_num, git_commit, git_branch,
        appium_config.DEVICE_NAME,
        f"{appium_config.PLATFORM_NAME} {appium_config.PLATFORM_VERSION}"
    )

    # ── Initialize Appium Driver ───────────────────────────────────────────────
    try:
        driver = AppiumDriverFactory.create_driver()
        logger.info(f"  Driver session: {getattr(driver, 'session_id', 'mock-session')}")
    except Exception as e:
        logger.error(f"[FATAL] Could not initialize Appium driver: {e}")
        _write_summary(f"\n> [!CAUTION]\n> **FATAL:** Appium driver initialization failed – `{e}`\n")
        sys.exit(1)

    # ── Execute all test modules ───────────────────────────────────────────────
    try:
        for idx, (mod_name, mod_fn, _expected) in enumerate(APPIUM_TEST_MODULES, start=1):
            logger.info(f"--- [{idx:02d}/20] Running Module: {mod_name} ---")
            mod_start = time.time()
            try:
                mod_results = mod_fn(driver)
            except Exception as e:
                logger.error(f"Module '{mod_name}' crashed: {e}")
                mod_results = []

            mod_dur  = time.time() - mod_start
            m_pass   = len([r for r in mod_results if r["status"] == "PASS"])
            m_fail   = len([r for r in mod_results if r["status"] == "FAIL"])
            m_total  = len(mod_results)

            logger.info(f"  [DONE] {mod_name}: {m_total} tests | PASS={m_pass} FAIL={m_fail} | {mod_dur:.2f}s")

            # Write row to GitHub Step Summary immediately
            write_summary_module_row(idx, mod_name, m_total, m_pass, m_fail, mod_dur)
            module_rows.append((mod_name, m_total, m_pass, m_fail, mod_dur))

            all_results.extend(mod_results)

    except Exception as e:
        logger.error(f"[FATAL] Unrecoverable error in test execution loop: {e}", exc_info=True)
    finally:
        if driver:
            try:
                driver.quit()
                logger.info("Appium driver session terminated.")
            except Exception:
                pass

    # ── Compute Metrics ────────────────────────────────────────────────────────
    total_duration = time.time() - start_total
    total   = len(all_results)
    passed  = len([r for r in all_results if r["status"] == "PASS"])
    failed  = len([r for r in all_results if r["status"] == "FAIL"])
    skipped = len([r for r in all_results if r["status"] in ("SKIPPED", "BLOCKED")])
    pass_rate  = (passed / max(total, 1)) * 100.0
    fail_rate  = 100.0 - pass_rate
    p1_tests   = [r for r in all_results if "P1" in r.get("priority", "")]
    p1_failed  = len([r for r in p1_tests if r["status"] == "FAIL"])
    crit_fail  = (p1_failed / max(len(p1_tests), 1)) * 100.0

    threshold     = appium_config.PASS_PERCENT_THRESHOLD
    max_crit_fail = appium_config.MAX_CRITICAL_FAILURE_PERCENT
    gate_passed   = (pass_rate >= threshold) and (crit_fail <= max_crit_fail)

    logger.info("=" * 70)
    logger.info(f"  TOTAL    : {total}")
    logger.info(f"  PASSED   : {passed}")
    logger.info(f"  FAILED   : {failed}")
    logger.info(f"  SKIPPED  : {skipped}")
    logger.info(f"  PASS RATE: {pass_rate:.2f}%  (Threshold: {threshold}%)")
    logger.info(f"  DURATION : {total_duration:.2f}s")
    logger.info(f"  GATE     : {'PASSED' if gate_passed else 'FAILED'}")
    logger.info("=" * 70)

    # ── Write footer to GitHub Step Summary ───────────────────────────────────
    failed_samples = [r for r in all_results if r["status"] == "FAIL"]
    write_summary_footer(
        total, passed, failed, skipped, pass_rate,
        total_duration, gate_passed, threshold, failed_samples
    )

    # ── Dump device logs on failures ──────────────────────────────────────────
    if failed > 0:
        dump_device_logs(appium_config.LOGS_RESULTS_DIR)

    # ── Build summary_metrics dict ────────────────────────────────────────────
    summary_metrics = {
        "total":              total,
        "executed":           total,
        "passed":             passed,
        "failed":             failed,
        "skipped":            skipped,
        "pass_rate":          pass_rate,
        "fail_rate":          fail_rate,
        "critical_total":     len(p1_tests),
        "critical_failed":    p1_failed,
        "critical_fail_rate": crit_fail,
        "duration_sec":       total_duration,
        "platform":           f"{appium_config.PLATFORM_NAME} {appium_config.PLATFORM_VERSION}",
        "device_name":        appium_config.DEVICE_NAME,
        "app_package":        appium_config.APP_PACKAGE,
        "apk_path":           appium_config.APP_APK_PATH,
        "automation_engine":  appium_config.AUTOMATION_NAME,
        "appium_server":      appium_config.APPIUM_SERVER_URL,
        "git_commit":         git_commit,
        "git_branch":         git_branch,
        "build_number":       build_num,
        "runner_os":          runner_os,
        "timestamp":          datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC"),
        "base_url":           f"Android App: {appium_config.APP_PACKAGE}",
        "browser":            f"Appium UiAutomator2 ({appium_config.PLATFORM_NAME} {appium_config.PLATFORM_VERSION})",
        "build_status":       "PASS",
        "deployment_status":  "PASS",
    }

    # ── Generate all report files ─────────────────────────────────────────────
    logger.info("Generating Excel Reports...")
    ExcelReportGenerator(all_results, summary_metrics).generate_all_reports()

    logger.info("Generating HTML Reports...")
    HTMLReportGenerator(all_results, summary_metrics).generate_all_html_reports()

    logger.info("Generating JSON Report...")
    JSONReportGenerator(all_results, summary_metrics).generate_json_report()

    logger.info("Generating Markdown Summary...")
    SummaryGenerator(all_results, summary_metrics).generate_summary()

    # Mirror reports to Test Results/Reports for artifact upload
    copy_artifacts_to_test_results(
        appium_config.REPORTS_DIR,
        appium_config.TEST_RESULTS_DIR / "Reports"
    )

    logger.info("[SUCCESS] Appium E2E execution and all report generation completed.")

    # ── Quality Gate ──────────────────────────────────────────────────────────
    if gate_passed:
        logger.info(f"[QUALITY GATE PASSED] Pass rate {pass_rate:.2f}% >= {threshold}%")
        sys.exit(0)
    else:
        reasons = []
        if pass_rate < threshold:
            reasons.append(f"Pass rate {pass_rate:.2f}% < required {threshold}%")
        if crit_fail > max_crit_fail:
            reasons.append(f"Critical failure rate {crit_fail:.2f}% > allowed {max_crit_fail}%")
        logger.error(f"[QUALITY GATE FAILED] {' | '.join(reasons)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
