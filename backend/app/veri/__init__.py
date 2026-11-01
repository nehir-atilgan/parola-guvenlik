"""VERİ KATMANI: veritabanı bağlantısı, migration'lar ve CRUD fonksiyonları (repolar).
İş kuralı içermez.

Yaklaşım: saf SQL (sqlite3, Python ile birlikte gelir; ek kurulum gerekmez).
Her istek kendi bağlantısını açar, istek bitince bağlantı kapanır.
"""
import os
import sqlite3

from flask import current_app, g


def baglanti_ac(yol):
    """Yeni bir SQLite bağlantısı açar ve güvenli varsayılanları ayarlar."""
    klasor = os.path.dirname(yol)
    if klasor:
        os.makedirs(klasor, exist_ok=True)
    con = sqlite3.connect(yol)
    con.row_factory = sqlite3.Row           # satırlara sütun adıyla erişim: satir["eposta"]
    con.execute("PRAGMA foreign_keys = ON")  # SQLite'ta yabancı anahtar kontrolü varsayılan olarak KAPALIDIR
    return con


def get_db():
    """O anki HTTP isteğine ait bağlantıyı döndürür (yoksa açar)."""
    if "db" not in g:
        g.db = baglanti_ac(current_app.config["VERITABANI"])
    return g.db


def kapat(_hata=None):
    con = g.pop("db", None)
    if con is not None:
        con.close()


def init_app(app):
    app.teardown_appcontext(kapat)
