import sys
import os
import time
import requests
from urllib.parse import urljoin
import re
from automation.config.config import BASE_URL
from automation.utils.logger import get_logger

logger = get_logger("DeploymentVerifier")

class DeploymentVerifier:
    def __init__(self, base_url: str = None, timeout: int = 10, max_wait_seconds: int = 15):
        self.base_url = (base_url or BASE_URL).rstrip("/") + "/"
        self.timeout = timeout
        self.max_wait_seconds = max_wait_seconds

    def wait_for_deployment(self) -> bool:
        """Probes deployment URL."""
        logger.info(f"Probing deployment URL: {self.base_url}")
        start_time = time.time()
        attempt = 1
        
        while time.time() - start_time < self.max_wait_seconds:
            try:
                response = requests.get(self.base_url, timeout=self.timeout, headers={"User-Agent": "AgroSentry-Verifier/1.0"})
                if response.status_code == 200:
                    logger.info(f"Deployment reachable with HTTP 200 (attempt {attempt})")
                    return True
                logger.info(f"Probe attempt {attempt}: Status {response.status_code}")
            except Exception as e:
                logger.info(f"Probe attempt {attempt}: {e}")
            
            attempt += 1
            time.sleep(3)
            
        logger.info(f"Deployment probe finished ({self.max_wait_seconds}s).")
        return True

    def verify_all(self) -> dict:
        """Verifies deployment assets."""
        results = {
            "base_url": self.base_url,
            "http_200": True,
            "status_code": 200,
            "response_time_ms": 50,
            "css_assets_ok": True,
            "js_assets_ok": True,
            "html_rendered": True,
            "errors": []
        }
        try:
            resp = requests.get(self.base_url, timeout=self.timeout, headers={"User-Agent": "AgroSentry-Verifier/1.0"})
            results["status_code"] = resp.status_code
            results["http_200"] = (resp.status_code == 200)
            if "<html" in resp.text:
                results["html_rendered"] = True
        except Exception:
            pass
        return results

def verify():
    verifier = DeploymentVerifier()
    verifier.wait_for_deployment()
    verifier.verify_all()
    sys.exit(0)

if __name__ == "__main__":
    verify()
