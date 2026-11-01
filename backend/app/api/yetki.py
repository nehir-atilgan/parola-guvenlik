"""Yetkilendirme dekoratörleri. Korumalı her uç nokta bunlardan birini kullanır.

    @giris_gerekli          → geçerli oturum yoksa 401
    @rol_gerekli("yonetici") → giriş var ama rol yetmiyorsa 403

401 Unauthorized = "Kim olduğunu bilmiyorum" (kimlik doğrulama yok)
403 Forbidden    = "Kim olduğunu biliyorum ama buna iznin yok" (yetkilendirme yok)

Yetki kontrolü BACKEND'de yapılır. Frontend'deki kontroller yalnızca kullanıcı
deneyimi içindir; tarayıcıdaki kod değiştirilebileceği için güvenlik sağlamaz.
"""
from functools import wraps

from flask import g, jsonify, request

from app.servisler import kimlik_servisi
from app.veri import get_db


def istek_tokeni():
    """'Authorization: Bearer <token>' başlığından token'ı okur."""
    baslik = request.headers.get("Authorization", "")
    tur, _, token = baslik.partition(" ")
    return token.strip() if tur.lower() == "bearer" else None


def giris_gerekli(fonksiyon):
    @wraps(fonksiyon)
    def sarmalayici(*args, **kwargs):
        kullanici = kimlik_servisi.oturumu_dogrula(get_db(), istek_tokeni())
        if kullanici is None:
            return jsonify(hata="Bu işlem için giriş yapmalısınız veya oturumunuzun süresi doldu."), 401
        g.kullanici = kullanici
        return fonksiyon(*args, **kwargs)

    return sarmalayici


def rol_gerekli(*roller):
    def dekorator(fonksiyon):
        @wraps(fonksiyon)
        @giris_gerekli
        def sarmalayici(*args, **kwargs):
            if g.kullanici["rol"] not in roller:
                return jsonify(hata="Bu sayfaya erişim yetkiniz yok."), 403
            return fonksiyon(*args, **kwargs)

        return sarmalayici

    return dekorator
