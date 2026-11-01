"""Veri katmanı testleri: migration, CRUD, ilişkiler ve kısıtlar."""
import sqlite3

import pytest

from app.veri import migrator, ornek_veri
from app.veri.repolar import analiz_repo, kullanici_repo, oneri_repo, quiz_repo


def _kullanici(con, n=1):
    return kullanici_repo.olustur(con, f"Test Kişi {n}", f"kisi{n}@ornek.test", "hash")


# ------------------------------------------------------------------ migration

def test_migrationlar_uygulandi(con):
    surumler = [r["dosya"] for r in con.execute("SELECT dosya FROM schema_surumu ORDER BY surum")]
    assert surumler == ["001_ilk_sema.sql", "002_oneri_katalogu.sql", "003_kimlik_dogrulama.sql"]


def test_migration_tekrar_calismaz(con):
    assert migrator.uygula(con) == []


def test_indeksler_olusturuldu(con):
    indeksler = {r[0] for r in con.execute("SELECT name FROM sqlite_master WHERE type='index'")}
    assert {"ix_analiz_kullanici_tarih", "ix_analiz_oneri_oneri", "ix_quiz_kullanici"} <= indeksler


# ------------------------------------------------------------------ CRUD

def test_kullanici_crud(con):
    kid = _kullanici(con)
    assert kullanici_repo.getir(con, kid)["eposta"] == "kisi1@ornek.test"

    assert kullanici_repo.guncelle(con, kid, ad_soyad="Yeni Ad") == 1
    assert kullanici_repo.getir(con, kid)["ad_soyad"] == "Yeni Ad"

    assert kullanici_repo.sil(con, kid) == 1
    assert kullanici_repo.getir(con, kid) is None


def test_eposta_kucuk_harfe_cevrilir(con):
    kullanici_repo.olustur(con, "Test", "  BuYuK@Ornek.TEST ", "hash")
    assert kullanici_repo.eposta_ile_getir(con, "buyuk@ornek.test") is not None


def test_analiz_ve_oneri_iliskisi(con):
    kid = _kullanici(con)
    aid = analiz_repo.olustur(con, kid, uzunluk=8, guc_skoru=35, guc_seviyesi="zayif", kucuk_harf=True)
    oneri = oneri_repo.kod_ile_getir(con, "UZUNLUK_ARTIR")
    analiz_repo.oneri_ekle(con, aid, oneri["id"], oncelik=1, kisisel_not="12+ karakter deneyin")

    oneriler = analiz_repo.analiz_onerileri(con, aid)
    assert [o["kod"] for o in oneriler] == ["UZUNLUK_ARTIR"]
    assert analiz_repo.sizinti_guncelle(con, aid, 42) == 1
    assert analiz_repo.getir(con, aid)["sizinti_sayisi"] == 42


def test_quiz_puani_hesaplanir(con):
    kid = _kullanici(con)
    quiz_repo.olustur(con, kid, dogru_sayisi=7, soru_sayisi=10)
    quiz_repo.olustur(con, kid, dogru_sayisi=9, soru_sayisi=10)
    assert quiz_repo.en_iyi_puan(con, kid) == 90


# ------------------------------------------------------------------ kısıtlar

def test_ayni_eposta_iki_kez_eklenemez(con):
    _kullanici(con)
    with pytest.raises(sqlite3.IntegrityError):
        _kullanici(con)


def test_olmayan_kullaniciya_analiz_eklenemez(con):
    with pytest.raises(sqlite3.IntegrityError):  # FOREIGN KEY
        analiz_repo.olustur(con, 999, 10, 50, "orta")


def test_gecersiz_skor_reddedilir(con):
    kid = _kullanici(con)
    with pytest.raises(sqlite3.IntegrityError):  # CHECK guc_skoru BETWEEN 0 AND 100
        analiz_repo.olustur(con, kid, 10, 150, "guclu")


def test_gecersiz_seviye_reddedilir(con):
    kid = _kullanici(con)
    with pytest.raises(sqlite3.IntegrityError):  # CHECK guc_seviyesi IN (...)
        analiz_repo.olustur(con, kid, 10, 50, "super")


def test_dogru_sayisi_soru_sayisini_gecemez(con):
    kid = _kullanici(con)
    with pytest.raises(sqlite3.IntegrityError):
        quiz_repo.olustur(con, kid, dogru_sayisi=11, soru_sayisi=10)


def test_ayni_oneri_bir_analize_iki_kez_eklenemez(con):
    kid = _kullanici(con)
    aid = analiz_repo.olustur(con, kid, 10, 50, "orta")
    oid = oneri_repo.kod_ile_getir(con, "RAKAM_EKLE")["id"]
    analiz_repo.oneri_ekle(con, aid, oid)
    with pytest.raises(sqlite3.IntegrityError):  # bileşik PRIMARY KEY
        analiz_repo.oneri_ekle(con, aid, oid)


def test_kullanici_silinince_kayitlari_da_silinir(con):
    kid = _kullanici(con)
    aid = analiz_repo.olustur(con, kid, 10, 50, "orta")
    analiz_repo.oneri_ekle(con, aid, oneri_repo.kod_ile_getir(con, "IKI_FAKTOR")["id"])
    quiz_repo.olustur(con, kid, 5, 10)

    kullanici_repo.sil(con, kid)  # ON DELETE CASCADE
    for tablo in ("analiz_kaydi", "analiz_oneri", "quiz_sonucu"):
        assert con.execute(f"SELECT COUNT(*) FROM {tablo}").fetchone()[0] == 0


def test_kullanimdaki_oneri_silinemez(con):
    kid = _kullanici(con)
    aid = analiz_repo.olustur(con, kid, 10, 50, "orta")
    oid = oneri_repo.kod_ile_getir(con, "IKI_FAKTOR")["id"]
    analiz_repo.oneri_ekle(con, aid, oid)
    with pytest.raises(sqlite3.IntegrityError):  # ON DELETE RESTRICT
        oneri_repo.sil(con, oid)


# ------------------------------------------------------------------ örnek veri

def test_ornek_veri_yuklenir_ve_kvkk_uyumludur(con):
    sonuc = ornek_veri.yukle(con)
    assert sonuc["durum"] == "yuklendi" and sonuc["kullanici"] == 10
    eposta_alanlari = {r[0].split("@")[1] for r in con.execute("SELECT eposta FROM kullanici")}
    assert eposta_alanlari == {"ornek.test"}  # gerçek e-posta yok
    assert ornek_veri.yukle(con)["durum"] == "atlandi"  # ikinci kez yüklenmez
