import time
import functools
from automation.utils.logger import get_logger

logger = get_logger("RetryHelper")

def retry_on_exception(max_retries: int = 2, delay_seconds: float = 1.0, allowed_exceptions: tuple = (Exception,)):
    """Decorator to retry a test step or action function on failure."""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            for attempt in range(1, max_retries + 1):
                try:
                    return func(*args, **kwargs)
                except allowed_exceptions as e:
                    last_exception = e
                    logger.warning(f"Attempt {attempt}/{max_retries} for {func.__name__} failed: {e}. Retrying in {delay_seconds}s...")
                    time.sleep(delay_seconds)
            logger.error(f"All {max_retries} attempts failed for {func.__name__}")
            raise last_exception
        return wrapper
    return decorator
