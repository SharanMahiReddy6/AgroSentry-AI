#!/usr/bin/env python3
"""
AgroSentry Emulator Manager
Starts and verifies Android Emulator readiness for CI/CD.
"""
import subprocess
import time
import sys
import os
from automation.utils.logger import get_logger

logger = get_logger("EmulatorManager")

EMULATOR_AVD_NAME = os.environ.get("AVD_NAME", "AgroSentry_CI_Emulator")
BOOT_TIMEOUT = int(os.environ.get("EMULATOR_BOOT_TIMEOUT", "300"))


def get_connected_devices() -> list:
    """Returns list of connected ADB device IDs."""
    try:
        res = subprocess.run(["adb", "devices"], capture_output=True, text=True, timeout=10)
        lines = res.stdout.strip().split("\n")[1:]
        return [ln.split("\t")[0] for ln in lines if ln.strip() and "device" in ln]
    except Exception as e:
        logger.warning(f"ADB devices check failed: {e}")
        return []


def wait_for_emulator_boot(timeout: int = BOOT_TIMEOUT) -> bool:
    """Polls until Android emulator completes boot sequence."""
    logger.info(f"Waiting for emulator boot (timeout={timeout}s)...")
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            result = subprocess.run(
                ["adb", "shell", "getprop", "sys.boot_completed"],
                capture_output=True, text=True, timeout=5
            )
            if result.stdout.strip() == "1":
                logger.info("✓ Emulator fully booted (sys.boot_completed=1)")
                return True
        except Exception:
            pass
        time.sleep(5)
        logger.info("  Emulator still booting...")
    logger.error(f"Emulator did not boot within {timeout}s")
    return False


def unlock_emulator_screen():
    """Dismisses Android lockscreen if present."""
    try:
        subprocess.run(["adb", "shell", "input", "keyevent", "82"], timeout=5)
        subprocess.run(["adb", "shell", "input", "keyevent", "4"], timeout=5)
        logger.info("Emulator screen unlocked.")
    except Exception as e:
        logger.warning(f"Screen unlock failed: {e}")


def disable_animations():
    """Disables all Android animations for stable test execution."""
    cmds = [
        ["adb", "shell", "settings", "put", "global", "window_animation_scale", "0.0"],
        ["adb", "shell", "settings", "put", "global", "transition_animation_scale", "0.0"],
        ["adb", "shell", "settings", "put", "global", "animator_duration_scale", "0.0"],
    ]
    for cmd in cmds:
        try:
            subprocess.run(cmd, timeout=5)
        except Exception:
            pass
    logger.info("Android animations disabled for CI testing.")


def start_emulator(avd_name: str = EMULATOR_AVD_NAME) -> bool:
    """Launches emulator from AVD and waits for boot completion."""
    devices = get_connected_devices()
    if devices:
        logger.info(f"Emulator already connected: {devices}")
        unlock_emulator_screen()
        disable_animations()
        return True

    logger.info(f"Starting Android Emulator AVD: {avd_name}")
    try:
        subprocess.Popen(
            ["emulator", "-avd", avd_name, "-no-snapshot", "-no-audio", "-no-boot-anim",
             "-no-window", "-gpu", "swiftshader_indirect"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except FileNotFoundError:
        logger.error("'emulator' command not found. Ensure Android SDK emulator is in PATH.")
        return False

    # Wait for device to appear in adb devices
    deadline = time.time() + 60
    while time.time() < deadline:
        if get_connected_devices():
            logger.info("Emulator appeared in ADB device list.")
            break
        time.sleep(3)

    booted = wait_for_emulator_boot()
    if booted:
        unlock_emulator_screen()
        disable_animations()
    return booted


def install_apk(apk_path: str) -> bool:
    """Installs APK on connected device via ADB."""
    if not apk_path or not os.path.exists(apk_path):
        logger.warning(f"APK not found at: {apk_path}. Skipping install.")
        return False

    logger.info(f"Installing APK: {apk_path}")
    try:
        result = subprocess.run(
            ["adb", "install", "-r", "-t", apk_path],
            capture_output=True, text=True, timeout=120
        )
        if "Success" in result.stdout:
            logger.info(f"✓ APK installed successfully: {apk_path}")
            return True
        else:
            logger.error(f"APK install failed: {result.stderr}")
            return False
    except Exception as e:
        logger.error(f"APK installation error: {e}")
        return False


if __name__ == "__main__":
    avd = os.environ.get("AVD_NAME", EMULATOR_AVD_NAME)
    success = start_emulator(avd)
    if not success:
        logger.error("Emulator startup failed.")
        sys.exit(1)

    apk_path = os.environ.get("APP_APK_PATH", "")
    if apk_path:
        installed = install_apk(apk_path)
        if not installed:
            logger.warning("APK installation skipped or failed (app may already be present).")

    logger.info("Emulator ready for Appium testing.")
    sys.exit(0)
