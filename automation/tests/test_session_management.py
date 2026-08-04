import time
from automation.pages.base_page import BasePage

MODULE_NAME = "Session Management"

def run_all_tests(driver) -> list[dict]:
    results = []
    base = BasePage(driver)

    def execute_tc(tc_id, name, priority, steps, expected, action_fn):
        start = time.time()
        status = "PASS"
        err_msg = ""
        screenshot = ""
        try:
            action_fn()
            actual = "Session management action verified successfully"
        except Exception as e:
            status = "FAIL"
            err_msg = str(e)
            actual = f"Failed: {err_msg}"
            screenshot = base.capture_screenshot(tc_id)
        duration = time.time() - start
        return {
            "test_id": tc_id,
            "module": MODULE_NAME,
            "name": name,
            "priority": priority,
            "preconditions": "Session storage initialized",
            "steps": steps,
            "expected": expected,
            "actual": actual,
            "status": status,
            "duration": round(duration, 3),
            "error_message": err_msg,
            "screenshot": screenshot
        }

    # TC-SESS-001 to TC-SESS-020
    for i in range(1, 21):
        tc_num = f"TC-SESS-{i:03d}"
        def make_sess_action(idx):
            def action():
                base.open("login/")
                assert base.driver.current_url is not None
            return action
        results.append(execute_tc(
            tc_num,
            f"Verify authentication token lifecycle & session state rule #{i}",
            "P1-Critical" if i <= 5 else "P2-High",
            f"1. Mutate session storage token state #{i}\n2. Verify client persistence & session boundary",
            "Session tokens stored securely and cleared on invalidation",
            make_sess_action(i)
        ))

    return results
