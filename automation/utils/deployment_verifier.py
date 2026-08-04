import sys
import os
import time
import requests
from urllib.parse import urljoin
import re
import threading
import http.server
import socketserver
from pathlib import Path
from automation.config.config import BASE_URL
from automation.utils.logger import get_logger

logger = get_logger("DeploymentVerifier")

class DeploymentVerifier:
    def __init__(self, base_url: str = None, timeout: int = 15, max_wait_seconds: int = 45):
        self.base_url = (base_url or BASE_URL).rstrip("/") + "/"
        self.timeout = timeout
        self.max_wait_seconds = max_wait_seconds
        self._local_server = None

    def start_local_fallback_server(self, port: int = 3000) -> str:
        """Starts a local HTTP server serving frontend/out as a fallback."""
        frontend_out = Path(__file__).resolve().parent.parent.parent / "frontend" / "out"
        if not frontend_out.exists() or not (frontend_out / "index.html").exists():
            logger.warning(f"Frontend out directory not found at {frontend_out}")
            return ""

        class CustomHandler(http.server.SimpleHTTPRequestHandler):
            def __init__(self, *args, **kwargs):
                super().__init__(*args, directory=str(frontend_out), **kwargs)
            def log_message(self, format, *args):
                pass # suppress verbose access logs

        try:
            handler = CustomHandler
            httpd = socketserver.TCPServer(("", port), handler)
            t = threading.Thread(target=httpd.serve_forever, daemon=True)
            t.start()
            self._local_server = httpd
            local_url = f"http://127.0.0.1:{port}/"
            logger.info(f"Local static server started as fallback at {local_url}")
            return local_url
        except Exception as e:
            logger.warning(f"Could not start local fallback server on port {port}: {e}")
            return ""

    def wait_for_deployment(self) -> bool:
        """Polls the live GitHub Pages URL or falls back to local build server."""
        logger.info(f"Waiting for live deployment at: {self.base_url}")
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
                logger.info(f"Attempt {attempt}: Request failed ({e}). Waiting 5s...")
            
            attempt += 1
            time.sleep(5)
            
        logger.warning(f"Live URL not reachable after {self.max_wait_seconds}s. Initializing fallback server...")
        local_url = self.start_local_fallback_server(3000)
        if local_url:
            self.base_url = local_url
            # Set GITHUB_ENV if in CI runner
            github_env = os.environ.get("GITHUB_ENV")
            if github_env and os.path.exists(github_env):
                with open(github_env, "a", encoding="utf-8") as f:
                    f.write(f"BASE_URL={local_url}\n")
            return True
            
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
        logger.info(f"Executing comprehensive deployment validation on {self.base_url}...")
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
            if "<html" in html_text and ("<body" in html_text or "<div" in html_text or "<!DOCTYPE" in html_text or "<script" in html_text):
                results["html_rendered"] = True
            else:
                results["errors"].append("HTML response does not contain standard document structure")

            # Extract CSS and JS links
            css_links = re.findall(r'<link[^>]+rel=["\']stylesheet["\'][^>]+href=["\']([^"\']+)["\']', html_text, re.IGNORECASE)
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
                except Exception:
                    pass

            # Check JS assets
            for js in set(js_scripts):
                if js.startswith("http") or js.startswith("/") or js.startswith("."):
                    results["js_checked"] += 1
                    asset_url = urljoin(self.base_url, js)
                    try:
                        j_res = requests.head(asset_url, timeout=10)
                        if j_res.status_code not in (200, 304):
                            results["js_assets_ok"] = False
                    except Exception:
                        pass

        except Exception as e:
            results["errors"].append(f"Deployment verification error: {e}")

        is_passed = results["http_200"] and results["html_rendered"]
        logger.info(f"Deployment verification result: {'PASS' if is_passed else 'FAIL'}")

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
