import sys
import time
import requests
from urllib.parse import urljoin
import re
from automation.config.config import BASE_URL
from automation.utils.logger import get_logger

logger = get_logger("DeploymentVerifier")

class DeploymentVerifier:
    def __init__(self, base_url: str = None, timeout: int = 30, max_wait_seconds: int = 180):
        self.base_url = (base_url or BASE_URL).rstrip("/") + "/"
        self.timeout = timeout
        self.max_wait_seconds = max_wait_seconds

    def wait_for_deployment(self) -> bool:
        """Polls the live GitHub Pages URL until it is available or timeout is reached."""
        logger.info(f"Waiting for live GitHub Pages deployment at: {self.base_url}")
        start_time = time.time()
        attempt = 1
        
        while time.time() - start_time < self.max_wait_seconds:
            try:
                response = requests.get(self.base_url, timeout=self.timeout, headers={"User-Agent": "AgroSentry-Deployment-Verifier/1.0"})
                if response.status_code == 200:
                    logger.info(f"Deployment is live and returned HTTP 200 on attempt {attempt} ({time.time() - start_time:.1f}s)")
                    return True
                logger.info(f"Attempt {attempt}: Received status {response.status_code}. Waiting 5s...")
            except Exception as e:
                logger.warning(f"Attempt {attempt}: Request failed with {e}. Waiting 5s...")
            
            attempt += 1
            time.sleep(5)
            
        logger.error(f"Deployment verification timed out after {self.max_wait_seconds} seconds.")
        return False

    def verify_all(self) -> dict:
        """
        Performs comprehensive pre-Selenium verification:
        1. HTTP 200 OK
        2. HTML content presence
        3. CSS stylesheet accessibility
        4. JS script accessibility
        5. Main root container render verification
        """
        logger.info("Executing comprehensive deployment validation...")
        results = {
            "base_url": self.base_url,
            "http_200": False,
            "status_code": 0,
            "response_time_ms": 0,
            "css_assets_ok": True,
            "js_assets_ok": True,
            "css_checked": 0,
            "js_checked": 0,
            "html_rendered": False,
            "errors": []
        }

        try:
            start_req = time.time()
            resp = requests.get(self.base_url, timeout=self.timeout, headers={"User-Agent": "AgroSentry-Deployment-Verifier/1.0"})
            results["response_time_ms"] = int((time.time() - start_req) * 1000)
            results["status_code"] = resp.status_code

            if resp.status_code == 200:
                results["http_200"] = True
            else:
                results["errors"].append(f"Base URL returned HTTP {resp.status_code}, expected 200")

            html_text = resp.text
            if "<html" in html_text and ("<body" in html_text or "<div" in html_text):
                results["html_rendered"] = True
            else:
                results["errors"].append("HTML response does not contain standard document structure")

            # Extract CSS and JS links
            css_links = re.findall(r'<link[^>]+rel=["\']stylesheet["\'][^>]+href=["\']([^"\']+)["\']', html_text, re.IGNORECASE)
            # Also catch reversed attributes: href first then rel
            css_links += re.findall(r'<link[^>]+href=["\']([^"\']+\.css[^"\']*)["\'][^>]+rel=["\']stylesheet["\']', html_text, re.IGNORECASE)
            js_scripts = re.findall(r'<script[^>]+src=["\']([^"\']+)["\']', html_text, re.IGNORECASE)

            # Check CSS assets
            for css in set(css_links):
                results["css_checked"] += 1
                asset_url = urljoin(self.base_url, css)
                try:
                    c_res = requests.head(asset_url, timeout=10)
                    if c_res.status_code not in (200, 304):
                        results["css_assets_ok"] = False
                        results["errors"].append(f"CSS asset failed to load ({c_res.status_code}): {asset_url}")
                except Exception as e:
                    results["css_assets_ok"] = False
                    results["errors"].append(f"CSS asset network error: {asset_url} ({e})")

            # Check JS assets
            for js in set(js_scripts):
                if js.startswith("http") or js.startswith("/") or js.startswith("."):
                    results["js_checked"] += 1
                    asset_url = urljoin(self.base_url, js)
                    try:
                        j_res = requests.head(asset_url, timeout=10)
                        if j_res.status_code not in (200, 304):
                            results["js_assets_ok"] = False
                            results["errors"].append(f"JS asset failed to load ({j_res.status_code}): {asset_url}")
                    except Exception as e:
                        results["js_assets_ok"] = False
                        results["errors"].append(f"JS asset network error: {asset_url} ({e})")

        except Exception as e:
            results["errors"].append(f"Fatal deployment verification error: {e}")

        is_passed = results["http_200"] and results["html_rendered"] and (len(results["errors"]) == 0)
        logger.info(f"Deployment verification result: {'PASS' if is_passed else 'FAIL'} (Errors: {len(results['errors'])})")
        for err in results["errors"]:
            logger.error(f"  - {err}")

        return results

if __name__ == "__main__":
    verifier = DeploymentVerifier()
    if not verifier.wait_for_deployment():
        logger.error("Deployment wait failed!")
        sys.exit(1)
    res = verifier.verify_all()
    if not (res["http_200"] and res["html_rendered"]):
        logger.error("Deployment validation failed!")
        sys.exit(1)
    logger.info("Deployment validation passed!")
    sys.exit(0)
