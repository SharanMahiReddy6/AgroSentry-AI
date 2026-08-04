#!/usr/bin/env python3
"""
AgroSentry Appium Server Manager
Starts and health-checks Appium Server for CI/CD pipeline.
"""
import subprocess
import time
import sys
import os
import requests
from automation.utils.logger import get_logger

logger = get_logger("AppiumServerManager")


def start_appium_server(host: str = "127.0.0.1", port: int = 4723, timeout: int = 60) -> bool:
    """
    Starts Appium server as background process and waits for it to be ready.
    Returns True on success, False on failure.
    """
    server_url = f"http://{host}:{port}/status"
    logger.info(f"Attempting to start Appium Server on {host}:{port}...")

    # Check if already running
    try:
        resp = requests.get(server_url, timeout=3)
        if resp.status_code == 200:
            logger.info(f"Appium server already running at http://{host}:{port}")
            return True
    except Exception:
        pass

    # Start Appium server process
    try:
        log_path = os.path.join(os.path.dirname(__file__), "..", "automation", "logs", "appium_server.log")
        os.makedirs(os.path.dirname(log_path), exist_ok=True)

        with open(log_path, "w") as log_file:
            proc = subprocess.Popen(
                ["appium", "--address", host, "--port", str(port), "--log-level", "info"],
                stdout=log_file,
                stderr=log_file
            )
        logger.info(f"Appium server process started (PID: {proc.pid})")
    except FileNotFoundError:
        logger.error("Appium executable not found. Ensure 'npm install -g appium' completed.")
        return False
    except Exception as e:
        logger.error(f"Failed starting Appium process: {e}")
        return False

    # Poll until server is ready
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            resp = requests.get(server_url, timeout=3)
            if resp.status_code == 200:
                logger.info(f"✓ Appium Server ready at http://{host}:{port}")
                return True
        except Exception:
            pass
        time.sleep(2)
        logger.info("Waiting for Appium server to become ready...")

    logger.error(f"Appium server did not become ready within {timeout}s")
    return False


def verify_appium_health(host: str = "127.0.0.1", port: int = 4723) -> dict:
    """Returns Appium server status information."""
    try:
        resp = requests.get(f"http://{host}:{port}/status", timeout=5)
        if resp.status_code == 200:
            data = resp.json()
            build = data.get("value", {}).get("build", {})
            logger.info(f"Appium Version: {build.get('version', 'unknown')}")
            return {"online": True, "version": build.get("version", "unknown"), "status": data}
    except Exception as e:
        logger.error(f"Appium health check failed: {e}")
    return {"online": False}


if __name__ == "__main__":
    host = os.environ.get("APPIUM_HOST", "127.0.0.1")
    port = int(os.environ.get("APPIUM_PORT", "4723"))
    success = start_appium_server(host, port, timeout=90)
    if success:
        health = verify_appium_health(host, port)
        logger.info(f"Appium health check: {health}")
        sys.exit(0)
    else:
        logger.error("Failed to start Appium server")
        sys.exit(1)
