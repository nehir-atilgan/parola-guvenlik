"""Ortam değişkenlerinden okunan uygulama ayarları."""
import os

from dotenv import load_dotenv

load_dotenv()

BACKEND_KLASORU = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SURUM = "0.8.0"  # semantic versioning: MAJOR.MINOR.PATCH (CHANGELOG.md)


class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "gelistirme-anahtari-degistirin")
    # SQLite veritabanı dosyası (yoksa otomatik oluşturulur)
    VERITABANI = os.getenv("VERITABANI") or os.path.join(BACKEND_KLASORU, "instance", "parola_guvenlik.db")
    # Frontend dosyaları (canlı sürümde backend tarafından aynı adresten sunulur)
    FRONTEND_KLASORU = os.path.join(os.path.dirname(BACKEND_KLASORU), "frontend")
    # 1 ise uygulama açılırken veritabanı boşsa demo hesapları ve örnek veri yüklenir
    ORNEK_VERI = os.getenv("ORNEK_VERI", "0") == "1"
    # Kimlik doğrulama
    OTURUM_SURESI_DAKIKA = int(os.getenv("OTURUM_SURESI_DAKIKA", "120"))  # token 2 saat geçerli
    GIRIS_DENEME_SINIRI = 5        # art arda bu kadar hatalı girişte hesap kilitlenir
    KILIT_SURESI_DAKIKA = 15
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
    ORNEK_VERI = False
