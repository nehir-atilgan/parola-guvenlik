"""Kimlik doğrulama iş kuralları: kayıt, giriş, çıkış, oturum doğrulama.

Bu dosya HTTP bilmez; API katmanı buradaki fonksiyonları çağırır.

Parola saklama: werkzeug `generate_password_hash` → scrypt algoritması.
  - Her parola için rastgele bir TUZ (salt) üretilir ve hash'in içine yazılır.
  - Aynı parola iki kullanıcıda farklı hash üretir; hazır "rainbow table"lar işe yaramaz.
  - scrypt bilerek yavaş ve bellek isteyen bir algoritmadır; kaba kuvvet denemelerini pahalılaştırır.
  - Örnek kayıt:  scrypt:32768:8:1$<tuz>$<hash>
"""
import hashlib
import re
import secrets

from flask import current_app
from werkzeug.security import check_password_hash, generate_password_hash

from app.veri.repolar import kullanici_repo, oturum_repo

EPOSTA_DESENI = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")

# Kullanıcı bulunamadığında da aynı sürede yanıt vermek için kullanılan sahte hash.
# Böylece yanıt süresinden "bu e-posta kayıtlı mı?" anlaşılamaz.
_SAHTE_HASH = generate_password_hash("zamanlama-esitleme")


class KimlikHatasi(Exception):
    """Kullanıcıya gösterilebilecek doğrulama hatası. durum: HTTP durum kodu önerisi."""

    def __init__(self, mesaj, durum=400):
        super().__init__(mesaj)
        self.mesaj = mesaj
        self.durum = durum


def token_ozeti(token):
    """Veritabanında token'ın kendisi değil SHA-256 özeti saklanır."""
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def parola_kurallarini_kontrol_et(parola):
    """Site hesabı parolası için asgari kurallar. Hata listesini döndürür (boşsa uygun)."""
    hatalar = []
    if len(parola) < 8:
        hatalar.append("Parola en az 8 karakter olmalı.")
    if not re.search(r"[A-Za-zÇĞİÖŞÜçğıöşü]", parola):
        hatalar.append("Parola en az bir harf içermeli.")
    if not re.search(r"\d", parola):
        hatalar.append("Parola en az bir rakam içermeli.")
    return hatalar


def kayit_ol(con, ad_soyad, eposta, parola):
    """Yeni kullanıcı oluşturur. Kayıtla gelen herkes 'kullanici' rolündedir;
    rol isteğin içinden ASLA alınmaz (kullanıcı kendini yönetici yapamaz)."""
    ad_soyad = (ad_soyad or "").strip()
    eposta = (eposta or "").strip().lower()
    parola = parola or ""

    if len(ad_soyad) < 2:
        raise KimlikHatasi("Ad soyad en az 2 karakter olmalı.")
    if not EPOSTA_DESENI.match(eposta):
        raise KimlikHatasi("Geçerli bir e-posta adresi girin.")
    hatalar = parola_kurallarini_kontrol_et(parola)
    if hatalar:
        raise KimlikHatasi(" ".join(hatalar))
    if kullanici_repo.eposta_ile_getir(con, eposta):
        raise KimlikHatasi("Bu e-posta adresiyle zaten bir hesap var.", durum=409)

    kid = kullanici_repo.olustur(con, ad_soyad, eposta, generate_password_hash(parola))
    return kullanici_repo.getir(con, kid)


def giris_yap(con, eposta, parola):
    """Başarılıysa (token, kullanıcı) döndürür. Başarısızsa KimlikHatasi fırlatır.

    Hata mesajı bilerek geneldir: "e-posta yok" ile "parola yanlış" ayırt edilmez,
    böylece saldırgan hangi e-postaların kayıtlı olduğunu öğrenemez.
    """
    ayar = current_app.config
    eposta = (eposta or "").strip().lower()
    kullanici = kullanici_repo.eposta_ile_getir(con, eposta) if eposta else None

    if kullanici is None:
        check_password_hash(_SAHTE_HASH, parola or "")  # zamanlamayı eşitle
        raise KimlikHatasi("E-posta veya parola hatalı.", durum=401)

    if kullanici_repo.kilitli_mi(con, kullanici["id"]):
        raise KimlikHatasi(
            f"Çok sayıda hatalı deneme yapıldı. Hesap {ayar['KILIT_SURESI_DAKIKA']} dakika kilitlendi.",
            durum=429,
        )

    if not check_password_hash(kullanici["sifre_hash"], parola or ""):
        kullanici_repo.basarisiz_giris_kaydet(
            con, kullanici["id"], ayar["GIRIS_DENEME_SINIRI"], ayar["KILIT_SURESI_DAKIKA"]
        )
        raise KimlikHatasi("E-posta veya parola hatalı.", durum=401)

    kullanici_repo.basarili_giris_kaydet(con, kullanici["id"])
    token = secrets.token_urlsafe(32)  # 256 bit, tahmin edilemez
    oturum_repo.olustur(con, kullanici["id"], token_ozeti(token), ayar["OTURUM_SURESI_DAKIKA"])
    return token, kullanici_repo.getir(con, kullanici["id"])


def oturumu_dogrula(con, token):
    """Geçerli token → kullanıcı satırı; geçersiz/süresi dolmuş/iptal edilmiş → None."""
    if not token:
        return None
    return oturum_repo.gecerli_oturum_kullanicisi(con, token_ozeti(token))


def cikis_yap(con, token):
    return oturum_repo.iptal_et(con, token_ozeti(token)) > 0


def rol_degistir(con, kullanici_id, yeni_rol):
    if yeni_rol not in ("kullanici", "yonetici"):
        raise KimlikHatasi("Geçersiz rol.")
    if not kullanici_repo.rol_ata(con, kullanici_id, yeni_rol):
        raise KimlikHatasi("Kullanıcı bulunamadı.", durum=404)
    # Yetkisi değişen kullanıcı yeniden giriş yapmalı: açık oturumları kapatılır.
    oturum_repo.kullanici_oturumlarini_iptal_et(con, kullanici_id)
    return kullanici_repo.getir(con, kullanici_id)
