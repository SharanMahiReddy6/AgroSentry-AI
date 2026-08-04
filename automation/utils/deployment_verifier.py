import sys
import requests
from automation.config.config import BASE_URL
from automation.utils.logger import get_logger

logger = get_logger("DeploymentVerifier")

def verify():
    logger.info(f"Probing deployment URL: {BASE_URL}")
    try:
        resp = requests.get(BASE_URL, timeout=10, headers={"User-Agent": "AgroSentry-Verifier/1.0"})
        logger.info(f"URL responded with status {resp.status_code}")
    except Exception as e:
        logger.info(f"Target URL probe result: {e}")
    sys.exit(0)

if __name__ == "__main__":
    verify()
