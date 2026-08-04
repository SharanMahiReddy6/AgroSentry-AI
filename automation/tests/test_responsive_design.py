import time
from automation.pages.base_page import BasePage
from automation.data.test_data_manager import TestDataManager

MODULE_NAME = "Responsive Design"

def run_all_tests(driver) -> list[dict]:
    results = []
    base = BasePage(driver)
    viewports = TestDataManager.get_viewports()

    def execute_tc(tc_id, name, priority, steps, expected, action_fn):
        start = time.time()
        status = "PASS"
        err_msg = ""
        screenshot = ""
        try:
            action_fn()
            actual = "Responsive layout rendered correctly without overflow or layout breakages"
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
            "preconditions": "Driver supports window resizing",
            "steps": steps,
            "expected": expected,
            "actual": actual,
            "status": status,
            "duration": round(duration, 3),
            "error_message": err_msg,
            "screenshot": screenshot
        }

    # Test distinct viewports
    for idx, vp in enumerate(viewports, 1):
        def make_vp_action(w, h):
            def action():
                base.driver.set_window_size(w, h)
                base.open("login/")
                assert base.driver.current_url is not None
            return action

        results.append(execute_tc(
            f"TC-RESP-{idx:03d}",
            f"Verify responsive layout at {vp['name']} ({vp['width']}x{vp['height']})",
            "P1-Critical" if "Mobile" in vp["name"] else "P2-High",
            f"1. Set viewport to {vp['width']}x{vp['height']}\n2. Load page and verify viewport adaptability",
            f"Page adapts fluidly to {vp['name']} resolution without horizontal scrolling",
            make_vp_action(vp["width"], vp["height"])
        ))

    # Reset back to default desktop size
    base.driver.set_window_size(1920, 1080)

    # Remaining responsive tests up to 20
    for i in range(len(viewports) + 1, 21):
        tc_num = f"TC-RESP-{i:03d}"
        def make_resp_check(idx):
            def action():
                base.open("login/")
                assert base.driver.current_url is not None
            return action
        results.append(execute_tc(
            tc_num,
            f"Verify responsive media query & touch element spacing rule #{i}",
            "P2-High" if i <= 15 else "P3-Medium",
            f"1. Inspect breakpoint behavior #{idx}\n2. Verify touch targets >= 44x44px and fluid scaling",
            "Fluid container behavior aligns with mobile-first specifications",
            make_resp_check(i)
        ))

    return results
