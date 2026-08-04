import logging
import sys
from datetime import datetime
from automation.config.config import LOGS_DIR, LOGS_RESULTS_DIR, LOG_LEVEL

def get_logger(name: str = "AgroSentry-Automation") -> logging.Logger:
    """Configures and returns a thread-safe logger writing to console and log files."""
    logger = logging.getLogger(name)
    
    if not logger.handlers:
        logger.setLevel(getattr(logging, LOG_LEVEL.upper(), logging.INFO))
        formatter = logging.Formatter(
            fmt="[%(asctime)s] [%(levelname)s] [%(name)s:%(lineno)d] - %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S"
        )
        
        # Console Handler
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
        
        # File Handler in automation/logs
        log_file = LOGS_DIR / "automation_execution.log"
        file_handler = logging.FileHandler(log_file, encoding="utf-8")
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
        
        # File Handler in Test Results/Logs
        results_log_file = LOGS_RESULTS_DIR / "automation_execution.log"
        results_file_handler = logging.FileHandler(results_log_file, encoding="utf-8")
        results_file_handler.setFormatter(formatter)
        logger.addHandler(results_file_handler)
        
    return logger
