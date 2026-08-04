import json
from pathlib import Path
from automation.config.config import DATA_DIR

class TestDataManager:
    _instance = None
    _data = None

    @classmethod
    def get_data(cls) -> dict:
        if cls._data is None:
            data_file = DATA_DIR / "test_data.json"
            if data_file.exists():
                with open(data_file, "r", encoding="utf-8") as f:
                    cls._data = json.load(f)
            else:
                cls._data = {}
        return cls._data

    @classmethod
    def get_credentials(cls, user_type: str = "admin") -> dict:
        return cls.get_data().get("credentials", {}).get(user_type, {})

    @classmethod
    def get_malicious_inputs(cls) -> list:
        return cls.get_data().get("malicious_inputs", [])

    @classmethod
    def get_mobile_devices(cls) -> list:
        return cls.get_data().get("mobile_devices", [])

    @classmethod
    def get_crops(cls) -> list:
        return cls.get_data().get("crops", [])

    @classmethod
    def get_diseases(cls) -> list:
        return cls.get_data().get("diseases", [])

    @classmethod
    def get_languages(cls) -> list:
        return cls.get_data().get("languages", [])

    @classmethod
    def get_form_plots(cls) -> list:
        return cls.get_data().get("form_plot_samples", [])

    @classmethod
    def get_search_queries(cls) -> list:
        return cls.get_data().get("search_queries", [])
