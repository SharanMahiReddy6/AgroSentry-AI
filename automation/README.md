# AgroSentry-AI Enterprise Selenium Automation & CI/CD Deployment Framework

This directory contains the enterprise-grade automated testing and deployment suite for **AgroSentry-AI**. It automates building the web application, deploying it to GitHub Pages, verifying deployment availability, running 400+ Selenium E2E test cases against the live deployment, generating multi-format reports (Excel, HTML, JSON, Markdown), and publishing GitHub Actions summaries.

---

## 🏗️ Architecture & Pipeline Flow

```
Push to main / PR / Workflow Dispatch
  │
  ├─► Stage 1: Repository Checkout
  ├─► Stage 2: Setup Node.js & Python
  ├─► Stage 3: Dependency Installation
  ├─► Stage 4: Static Analysis (Lint & Typecheck)
  ├─► Stage 5: Build Next.js Application (Static Export with .nojekyll)
  ├─► Stage 6: Deploy to GitHub Pages
  ├─► Stage 7: Wait & Verify Live Deployment (HTTP 200, CSS/JS assets, DOM)
  ├─► Stage 8: Execute 400+ Selenium E2E Tests against LIVE BASE_URL
  ├─► Stage 9: Generate Interactive HTML Reports & Dashboard
  ├─► Stage 10: Generate 4 Formatted Excel Reports (openpyxl)
  ├─► Stage 11: Upload All Artifacts to GitHub Actions (30-day retention)
  ├─► Stage 12: Publish Step Summary to $GITHUB_STEP_SUMMARY
  └─► Stage 13: Store Historical Results & Evaluate Quality Gate
```

---

## 📁 Automation Folder Structure

```
automation/
├── config/
│   ├── config.py                 # Core configurations (BASE_URL, Timeouts, Gates)
│   └── settings.json             # Environment parameters
├── drivers/
│   └── driver_factory.py         # Headless Chrome / WebDriver lifecycle manager
├── pages/                        # Page Object Model (POM) abstractions
│   ├── base_page.py              # Common interactions, waits, screenshots
│   ├── login_page.py
│   ├── register_page.py
│   ├── forgot_password_page.py
│   ├── dashboard_page.py
│   ├── scan_page.py
│   ├── library_page.py
│   ├── tips_page.py
│   ├── history_page.py
│   ├── profile_page.py
│   └── admin_page.py
├── data/
│   ├── test_data.json            # Credentials, attack vectors, viewports
│   └── test_data_manager.py      # Test data access layer
├── utils/
│   ├── logger.py                 # Structured logging
│   ├── screenshot_helper.py      # Failure & verification screenshot capturer
│   ├── wait_helpers.py           # Explicit wait wrappers & DOM ready checks
│   ├── retry_helper.py           # Test retry execution decorator
│   ├── deployment_verifier.py    # Pre-test deployment validation (HTTP 200, assets)
│   ├── excel_report_generator.py # Generates 4 styled Excel reports
│   ├── html_report_generator.py  # Generates execution-report.html & dashboard.html
│   ├── json_report_generator.py  # Generates execution-results.json
│   └── summary_generator.py      # Generates summary.md & GitHub step summary
├── tests/                        # 420 Executable Test Cases across 14 modules
│   ├── test_authentication.py    # 40 Test Cases
│   ├── test_authorization.py     # 40 Test Cases
│   ├── test_navigation.py        # 30 Test Cases
│   ├── test_ui_validation.py     # 50 Test Cases
│   ├── test_forms.py             # 50 Test Cases
│   ├── test_crud_operations.py   # 50 Test Cases
│   ├── test_input_validation.py  # 40 Test Cases
│   ├── test_error_handling.py    # 20 Test Cases
│   ├── test_session_management.py# 20 Test Cases
│   ├── test_file_upload.py       # 20 Test Cases
│   ├── test_accessibility.py     # 20 Test Cases
│   ├── test_responsive_design.py # 20 Test Cases
│   ├── test_performance_smoke.py # 20 Test Cases
│   ├── test_regression.py        # 50 Test Cases
│   └── conftest.py               # Pytest fixtures
├── run_tests.py                  # High-performance master test runner
└── requirements.txt              # Python dependencies
```

---

## 📊 Test Case Coverage Breakdown (420 Total Test Cases)

| Module | Test Cases | Priority Distribution | Key Focus Areas |
|---|---|---|---|
| **Authentication** | 40 | P1 (10), P2 (20), P3 (10) | Form fields, masked inputs, SQLi/XSS prevention, remember token |
| **Authorization** | 40 | P1 (10), P2 (20), P3 (10) | Unauthenticated route guards, role boundaries, token isolation |
| **Navigation** | 30 | P1 (5), P2 (15), P3 (10) | Direct URLs, browser history, routing hydration, deep links |
| **UI Validation** | 50 | P1 (5), P2 (25), P3 (20) | Visual hierarchy, typography, dark/light themes, badges |
| **Forms** | 50 | P1 (10), P2 (25), P3 (15) | Required validation, tab ordering, reset, button states |
| **CRUD Operations** | 50 | P1 (15), P2 (25), P3 (10) | Create scan, update profile, query history, admin records |
| **Input Validation** | 40 | P1 (10), P2 (20), P3 (10) | Email regex, length limits, special characters, whitespace |
| **Error Handling** | 20 | P1 (5), P2 (10), P3 (5) | 404 handler, error boundaries, network resilience, retry alerts |
| **Session Management**| 20 | P1 (5), P2 (10), P3 (5) | Token storage, session clearance, cross-tab persistence |
| **File Upload** | 20 | P1 (5), P2 (10), P3 (5) | Drag-and-drop, mime types (.jpg, .png), size limit, previews |
| **Accessibility** | 20 | P2 (10), P3 (10) | WCAG 2.1 AA, aria-labels, semantic tags, contrast, keyboard nav |
| **Responsive Design** | 20 | P1 (5), P2 (10), P3 (5) | Mobile (375x812), Tablet (768x1024), Desktop (1920x1080) |
| **Performance Smoke** | 20 | P1 (5), P2 (10), P3 (5) | Page load duration (<5s), TTFB, client hydration latency |
| **Regression** | 50 | P1 (15), P2 (25), P3 (10) | Complete end-to-end user journeys & admin workflows |
| **TOTAL** | **420** | **Comprehensive** | **100% Executable against LIVE BASE_URL** |

---

## 🚀 Local Execution Guide

### Prerequisites
- Python 3.10+
- Google Chrome Browser installed

### Setup
```bash
# Install automation dependencies
pip install -r automation/requirements.txt
```

### Run against Live Deployed Application
```bash
# Set target deployment URL
export BASE_URL="https://<username>.github.io/<repository-name>/"
export BROWSER="chrome"
export HEADLESS="true"

# Execute all 420 test cases & generate all reports
python automation/run_tests.py
```

On Windows PowerShell:
```powershell
$env:BASE_URL="https://<username>.github.io/<repository-name>/"
$env:BROWSER="chrome"
$env:HEADLESS="true"
python automation/run_tests.py
```

### Run via Pytest
```bash
pytest automation/tests/ -v
```

---

## 📈 Generated Reports & Artifacts

All test runs automatically populate the `Test Results/` directory:

- **`Test Results/Excel/Automation_Test_Report.xlsx`**: 6 comprehensive sheets:
  1. *Executed Test Cases*
  2. *Passed Tests*
  3. *Failed Tests*
  4. *Skipped Tests*
  5. *Execution Metrics*
  6. *Defect Summary*
- **`Test Results/Excel/Failed_Test_Cases.xlsx`**
- **`Test Results/Excel/Passed_Test_Cases.xlsx`**
- **`Test Results/Excel/Summary_Report.xlsx`**
- **`Test Results/HTML/execution-report.html`**: Interactive dark-themed report with Chart.js visualization, search filters, and modal screenshot viewers.
- **`Test Results/HTML/dashboard.html`**: Executive QA dashboard with pass/fail metrics and release quality gate status.
- **`Test Results/JSON/execution-results.json`**: Machine-readable JSON telemetry.
- **`Test Results/Summary/summary.md`**: Markdown summary published directly to GitHub Actions `$GITHUB_STEP_SUMMARY`.
- **`Test Results/Screenshots/`**: High-resolution PNG screenshots captured upon failure or verification.
- **`Test Results/Logs/`**: Execution and browser console logs.

---

## ⚙️ GitHub Repository Configuration

To enable GitHub Pages deployment:
1. Go to your repository on GitHub: **Settings** → **Pages**.
2. Under **Build and deployment** → **Source**, select **GitHub Actions**.
3. Under **Settings** → **Actions** → **General** → **Workflow permissions**, choose **Read and write permissions**.

---

## 🛡️ Quality Gate & Pass/Fail Criteria

- Pipeline **FAILS** if:
  - GitHub Pages deployment fails or is inaccessible.
  - Overall Pass Percentage is below **95.0%**.
  - Critical (P1) test failure rate exceeds **5.0%**.
- Pipeline **SUCCEEDS** if:
  - Deployment is verified healthy (HTTP 200, CSS/JS loaded).
  - Overall Pass Percentage is **≥ 95.0%**.
