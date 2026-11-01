"""Ortam değişkenlerinden okunan uygulama ayarları."""
import os

from dotenv import load_dotenv

load_dotenv()


class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "gelistirme-anahtari-degistirin")
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL") or "sqlite:///parola_guvenlik.db"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    HIBP_API_URL = os.getenv("HIBP_API_URL", "https://api.pwnedpasswords.com/range/")
    LLM_API_KEY = os.getenv("LLM_API_KEY", "")
    # Backend'e istek atmasına izin verilen frontend adresleri (virgülle ayrılır)
    FRONTEND_ORIGINS = [
        a.strip()
        for a in os.getenv("FRONTEND_ORIGINS", "http://127.0.0.1:8000,http://localhost:8000").split(",")
        if a.strip()
    ]


class TestConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"
