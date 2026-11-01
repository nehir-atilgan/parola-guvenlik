"""Ortam değişkenlerinden okunan uygulama ayarları."""
import os

from dotenv import load_dotenv

load_dotenv()

BACKEND_KLASORU = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "gelistirme-anahtari-degistirin")
    # SQLite veritabanı dosyası (yoksa otomatik oluşturulur)
    VERITABANI = os.getenv("VERITABANI") or os.path.join(BACKEND_KLASORU, "instance", "parola_guvenlik.db")
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
    VERITABANI = None  # testler her seferinde geçici bir dosya verir
