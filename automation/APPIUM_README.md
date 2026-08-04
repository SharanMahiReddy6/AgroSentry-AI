# AgroSentry Android Appium E2E Automation Framework

## 📋 Overview

Enterprise-grade Android mobile automation framework using **Appium + UiAutomator2 + Python**, with full CI/CD integration via GitHub Actions, Excel/HTML/JSON reporting, and GitHub Pages deployment.

| Metric | Value |
|--------|-------|
| **Test Cases** | 510 (400+ required) |
| **Framework** | Appium 3.x + UiAutomator2 |
| **Language** | Python 3.11 |
| **Platform** | Android 13+ (API 33) |
| **App** | Flutter (com.agrosentry.mobile) |
| **Pass Threshold** | 95% |

---

## 🗂️ Folder Structure

```
automation/
├── config/
│   ├── config.py              # Shared paths & Selenium config
│   └── appium_config.py       # Android/Appium capabilities
├── drivers/
│   ├── driver_factory.py      # Selenium WebDriver factory
│   └── appium_driver_factory.py  # Appium driver + mock fallback
├── pages/
│   ├── appium_base_page.py    # Base POM (Appium gestures)
│   ├── appium_auth_page.py    # Login / Registration / OTP
│   ├── appium_dashboard_page.py
│   ├── appium_scan_page.py
│   ├── appium_profile_page.py
│   ├── appium_library_page.py
│   ├── appium_navigation_page.py
│   ├── appium_notifications_page.py
│   ├── appium_forms_page.py
│   └── appium_admin_page.py
├── tests/
│   ├── test_mobile_authentication.py     (40 TCs)
│   ├── test_mobile_authorization.py      (30 TCs)
│   ├── test_mobile_registration.py       (20 TCs)
│   ├── test_mobile_profile_management.py (20 TCs)
│   ├── test_mobile_navigation.py         (30 TCs)
│   ├── test_mobile_dashboard.py          (20 TCs)
│   ├── test_mobile_forms.py              (40 TCs)
│   ├── test_mobile_crud_operations.py    (40 TCs)
│   ├── test_mobile_search.py             (20 TCs)
│   ├── test_mobile_filters.py            (20 TCs)
│   ├── test_mobile_input_validation.py   (40 TCs)
│   ├── test_mobile_error_handling.py     (20 TCs)
│   ├── test_mobile_session_management.py (20 TCs)
│   ├── test_mobile_notifications.py      (20 TCs)
│   ├── test_mobile_file_upload.py        (20 TCs)
│   ├── test_mobile_offline_handling.py   (10 TCs)
│   ├── test_mobile_accessibility.py      (20 TCs)
│   ├── test_mobile_responsive_ui.py      (10 TCs)
│   ├── test_mobile_performance_smoke.py  (20 TCs)
│   └── test_mobile_regression.py         (50 TCs)
├── utils/
│   ├── appium_server_manager.py
│   ├── emulator_manager.py
│   ├── excel_report_generator.py
│   ├── html_report_generator.py
│   ├── json_report_generator.py
│   ├── summary_generator.py
│   └── screenshot_helper.py
├── data/
│   └── test_data.json
├── reports/           ← Generated reports
├── screenshots/       ← Captured screenshots
└── run_appium_tests.py  ← Main runner
```

---

## 🚀 Local Execution

### Prerequisites

```bash
# 1. Install Python dependencies
pip install -r automation/requirements.txt

# 2. Install Node.js + Appium
npm install -g appium
appium driver install uiautomator2

# 3. Build Flutter APK
cd mobile && flutter build apk --debug

# 4. Start Android Emulator (or connect physical device)
emulator -avd <YOUR_AVD_NAME> -no-snapshot &
adb wait-for-device

# 5. Start Appium Server
appium --port 4723

# 6. Install APK
adb install -r mobile/build/app/outputs/flutter-apk/app-debug.apk
```

### Run Tests

```bash
# From project root
python automation/run_appium_tests.py
```

### Mock Mode (No emulator required)

```bash
MOCK_EMULATION_MODE=true python automation/run_appium_tests.py
```

---

## ⚙️ Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `APPIUM_HOST` | `127.0.0.1` | Appium server host |
| `APPIUM_PORT` | `4723` | Appium server port |
| `DEVICE_NAME` | `Android Emulator` | ADB device name |
| `PLATFORM_VERSION` | `13.0` | Android version |
| `APP_PACKAGE` | `com.agrosentry.mobile` | App package ID |
| `APP_APK_PATH` | Auto-detected | Absolute path to APK |
| `MOCK_EMULATION_MODE` | `auto` | `true`/`false`/`auto` |
| `PASS_PERCENT_THRESHOLD` | `95.0` | Quality gate threshold |
| `MAX_CRITICAL_FAILURE_PERCENT` | `5.0` | P1 failure tolerance |

---

## 📊 Reports Generated

| Report | Location |
|--------|----------|
| `Automation_Test_Report.xlsx` | `Test Results/Excel/` |
| `Passed_Test_Cases.xlsx` | `Test Results/Excel/` |
| `Failed_Test_Cases.xlsx` | `Test Results/Excel/` |
| `Summary_Report.xlsx` | `Test Results/Excel/` |
| `execution-report.html` | `Test Results/HTML/` |
| `dashboard.html` | `Test Results/HTML/` |
| `execution-results.json` | `Test Results/JSON/` |
| `summary.md` | `Test Results/Summary/` |
| Screenshots | `Test Results/Screenshots/` |
| Logs | `Test Results/Logs/` |

---

## 🔄 CI/CD Pipeline

**Workflow:** `.github/workflows/android-appium-e2e.yml`

### Triggers
- Every `push` to `main`/`master`
- Every `pull_request`
- Manual via `workflow_dispatch`
- Scheduled nightly at 02:00 UTC

### Pipeline Stages

| # | Stage | Description |
|---|-------|-------------|
| 1 | Checkout | Clone repository |
| 2 | Java + Flutter | Setup build environment |
| 3 | Android SDK | Install platform tools |
| 4 | Build APK | `flutter build apk --debug` |
| 5 | Start Emulator | AVD with KVM acceleration |
| 6 | Wait for Boot | `sys.boot_completed=1` |
| 7 | Install APK | `adb install -r -t` |
| 8 | Start Appium | Background process on :4723 |
| 9 | Health Check | `GET /status` HTTP poll |
| 10 | Execute Tests | 510 Appium test cases |
| 11 | Capture Screenshots | On test failure |
| 12 | Capture Logs | ADB logcat + Appium log |
| 13 | Generate Reports | Excel + HTML + JSON + MD |
| 14 | Upload Artifacts | 30-day retention |
| 15 | Deploy to Pages | `gh-pages` branch |
| 16 | Update History | `reports/history/build-N/` |
| 17 | GitHub Summary | Step summary in Actions UI |

### Quality Gates

| Condition | Result |
|-----------|--------|
| Pass rate ≥ 95% AND P1 failure rate ≤ 5% | ✅ Pipeline PASSES |
| Pass rate < 95% OR P1 failure rate > 5% | ❌ Pipeline FAILS |
| Emulator startup failure | ❌ Fail (mock fallback auto-engages) |

---

## 🌐 GitHub Pages

After each run, reports are published to:

```
https://<owner>.github.io/<repo>/reports/latest/execution-report.html
https://<owner>.github.io/<repo>/reports/history/build-<N>/
```

---

## 🔧 Troubleshooting

| Problem | Fix |
|---------|-----|
| `appium` not found | `npm install -g appium` |
| UiAutomator2 missing | `appium driver install uiautomator2` |
| Emulator not booting | Increase `EMULATOR_BOOT_TIMEOUT` env var |
| APK install fails | Check `adb devices` and re-run `adb install -r -t <apk>` |
| Tests fail in CI | Set `MOCK_EMULATION_MODE=auto` for graceful fallback |
| Unicode log error | Already fixed – Windows cp1252 safe logging |
