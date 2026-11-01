"""Veri modeli (ER diyagramı: docs/er_diyagrami.md).

GÜVENLİK İLKESİ: Analiz edilen parolanın kendisi veya hash'i ASLA saklanmaz.
Yalnızca türetilmiş ölçümler (uzunluk, skor, karakter çeşitliliği, sızıntı sayısı) tutulur.
"""
from datetime import datetime, timezone

from app.veri import db


def simdi():
    return datetime.now(timezone.utc)


class Kullanici(db.Model):
    __tablename__ = "kullanici"

    id = db.Column(db.Integer, primary_key=True)
    ad_soyad = db.Column(db.String(100), nullable=False)
    eposta = db.Column(db.String(150), unique=True, nullable=False)
    sifre_hash = db.Column(db.String(255), nullable=False)  # giriş parolası (hash'lenmiş)
    kayit_tarihi = db.Column(db.DateTime, default=simdi, nullable=False)

    analizler = db.relationship("AnalizKaydi", back_populates="kullanici", cascade="all, delete-orphan")
    quiz_sonuclari = db.relationship("QuizSonucu", back_populates="kullanici", cascade="all, delete-orphan")


class AnalizKaydi(db.Model):
    __tablename__ = "analiz_kaydi"

    id = db.Column(db.Integer, primary_key=True)
    kullanici_id = db.Column(db.Integer, db.ForeignKey("kullanici.id"), nullable=False, index=True)
    uzunluk = db.Column(db.Integer, nullable=False)
    guc_skoru = db.Column(db.Integer, nullable=False)          # 0-100
    guc_seviyesi = db.Column(db.String(20), nullable=False)    # zayif / orta / guclu
    buyuk_harf = db.Column(db.Boolean, default=False)
    kucuk_harf = db.Column(db.Boolean, default=False)
    rakam = db.Column(db.Boolean, default=False)
    ozel_karakter = db.Column(db.Boolean, default=False)
    sizinti_sayisi = db.Column(db.Integer, default=0)          # HIBP'te kaç kez görüldüğü
    analiz_tarihi = db.Column(db.DateTime, default=simdi, nullable=False)

    kullanici = db.relationship("Kullanici", back_populates="analizler")
    oneriler = db.relationship("AnalizOneri", back_populates="analiz", cascade="all, delete-orphan")


class Oneri(db.Model):
    """Öneri kataloğu: aynı öneri birçok analizde tekrar kullanılır (N-N)."""
    __tablename__ = "oneri"

    id = db.Column(db.Integer, primary_key=True)
    kod = db.Column(db.String(30), unique=True, nullable=False)   # ör. UZUNLUK_ARTIR
    baslik = db.Column(db.String(150), nullable=False)
    aciklama = db.Column(db.Text, nullable=False)
    kategori = db.Column(db.String(50), nullable=False)           # uzunluk, cesitlilik, sizinti, 2fa...

    analizler = db.relationship("AnalizOneri", back_populates="oneri")


class AnalizOneri(db.Model):
    """Ara tablo: AnalizKaydi <-> Oneri (N-N). Yapay zekâ kişisel notu burada durur."""
    __tablename__ = "analiz_oneri"

    analiz_id = db.Column(db.Integer, db.ForeignKey("analiz_kaydi.id"), primary_key=True)
    oneri_id = db.Column(db.Integer, db.ForeignKey("oneri.id"), primary_key=True)
    oncelik = db.Column(db.Integer, default=1)                    # 1 = en önemli
    kisisel_not = db.Column(db.Text)                              # LLM ile üretilen kişisel açıklama

    analiz = db.relationship("AnalizKaydi", back_populates="oneriler")
    oneri = db.relationship("Oneri", back_populates="analizler")


class QuizSonucu(db.Model):
    __tablename__ = "quiz_sonucu"

    id = db.Column(db.Integer, primary_key=True)
    kullanici_id = db.Column(db.Integer, db.ForeignKey("kullanici.id"), nullable=False, index=True)
    dogru_sayisi = db.Column(db.Integer, nullable=False)
    soru_sayisi = db.Column(db.Integer, nullable=False)
    puan = db.Column(db.Integer, nullable=False)                  # 0-100
    tamamlanma_tarihi = db.Column(db.DateTime, default=simdi, nullable=False)

    kullanici = db.relationship("Kullanici", back_populates="quiz_sonuclari")
