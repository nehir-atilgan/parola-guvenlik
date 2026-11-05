"""Farkındalık Rehberi ve Quiz testleri (Hafta 7)."""
import random
import sqlite3

import pytest

from app.servisler import quiz_servisi
from app.veri.repolar import kullanici_repo, quiz_repo


def _bearer(token):
    return {"Authorization": f"Bearer {token}"}


def _hesap(istemci, eposta="quiz@ornek.test"):
    istemci.post("/api/kayit", json={"ad_soyad": "Quiz Test", "eposta": eposta, "parola": "GucluParola1"})
    return istemci.post("/api/giris", json={"eposta": eposta, "parola": "GucluParola1"}).get_json()["token"]


@pytest.fixture
def token(istemci):
    return _hesap(istemci)


def _dogru_cevaplar(con, deneme):
    """Test için doğru cevapları veritabanından okur (tarayıcı bunu göremez)."""
    idler = [s["soru_id"] for s in deneme["sorular"]]
    return {str(s["soru_id"]): s["id"] for s in quiz_repo.secenekler(con, idler) if s["dogru"]}


def _yanlis_cevaplar(con, deneme):
    idler = [s["soru_id"] for s in deneme["sorular"]]
    yanlis = {}
    for s in quiz_repo.secenekler(con, idler):
        if not s["dogru"]:
            yanlis.setdefault(str(s["soru_id"]), s["id"])
    return yanlis


# ------------------------------------------------------------------ içerik ve şema

def test_her_sorunun_tam_bir_dogru_cevabi_ve_dort_secenegi_var(con):
    satirlar = con.execute(
        """SELECT s.id, COUNT(c.id) AS secenek, SUM(c.dogru) AS dogru
           FROM quiz_soru s JOIN quiz_secenek c ON c.soru_id = s.id GROUP BY s.id"""
    ).fetchall()
    assert len(satirlar) == 21
    assert all(r["secenek"] == 4 and r["dogru"] == 1 for r in satirlar)


def test_ikinci_dogru_secenek_eklenemez(con):
    with pytest.raises(sqlite3.IntegrityError):  # kısmi benzersiz indeks
        con.execute("UPDATE quiz_secenek SET dogru = 1 WHERE soru_id = 1")


def test_sorusu_olan_konu_silinemez(con):
    with pytest.raises(sqlite3.IntegrityError):  # ON DELETE RESTRICT
        con.execute("DELETE FROM rehber_konu WHERE id = 1")


def test_her_oneri_bir_rehber_konusuna_bagli(con):
    assert con.execute("SELECT COUNT(*) FROM oneri WHERE rehber_konu_id IS NULL").fetchone()[0] == 0


# ------------------------------------------------------------------ rehber API

def test_rehber_listesi_herkese_acik(istemci):
    konular = istemci.get("/api/rehber").get_json()
    assert len(konular) == 7
    assert [k["sira"] for k in konular] == list(range(1, 8))
    assert all(k["soru_sayisi"] == 3 for k in konular)


def test_rehber_konusu_detayi(istemci):
    konu = istemci.get("/api/rehber/iki-adimli-dogrulama").get_json()
    assert konu["baslik"].startswith("İki adımlı")
    assert len(konu["paragraflar"]) == 3 and len(konu["anahtar_noktalar"]) >= 3
    assert konu["onceki"]["slug"] == "veri-sizintilari"
    assert {o["kod"] for o in konu["ilgili_oneriler"]} == {"IKI_FAKTOR"}


def test_olmayan_rehber_konusu_404(istemci):
    assert istemci.get("/api/rehber/yok-boyle-konu").status_code == 404


def test_analiz_onerileri_rehbere_baglanir(istemci):
    sonuc = istemci.post("/api/analiz", json={"parola": "kisa"}).get_json()
    assert all(o["rehber_slug"] for o in sonuc["oneriler"])


# ------------------------------------------------------------------ soru seçimi

def test_soru_secimi_her_konudan_en_az_bir_soru_icerir():
    bank = [(k * 10 + i, k) for k in range(1, 8) for i in range(3)]  # 7 konu × 3 soru
    for tohum in range(20):
        secilen = quiz_servisi.soru_sec(bank, rnd=random.Random(tohum))
        assert len(secilen) == 10 and len(set(secilen)) == 10
        assert {s // 10 for s in secilen} == set(range(1, 8))


# ------------------------------------------------------------------ quiz akışı

def test_quiz_giris_gerektirir(istemci):
    assert istemci.post("/api/quiz/baslat").status_code == 401


def test_baslatinca_dogru_cevaplar_gonderilmez(istemci, token):
    yanit = istemci.post("/api/quiz/baslat", headers=_bearer(token))
    assert yanit.status_code == 201
    deneme = yanit.get_json()
    assert len(deneme["sorular"]) == 10
    assert "dogru" not in yanit.get_data(as_text=True)  # ne alan ne değer olarak


def test_acik_deneme_varken_yeni_deneme_acilmaz(istemci, token):
    ilk = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    ikinci = istemci.post("/api/quiz/baslat", headers=_bearer(token))
    assert ikinci.status_code == 200
    assert ikinci.get_json()["deneme_id"] == ilk["deneme_id"]
    assert ikinci.get_json()["kaldigi_yerden"] is True


def test_secenek_sirasi_sayfa_yenilense_de_degismez(istemci, token):
    ilk = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    tekrar = istemci.get(f"/api/quiz/{ilk['deneme_id']}", headers=_bearer(token)).get_json()
    assert ilk["sorular"] == tekrar["sorular"]


def test_tum_dogru_cevaplar_100_puan(istemci, token, con):
    deneme = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    sonuc = istemci.post(f"/api/quiz/{deneme['deneme_id']}/gonder", headers=_bearer(token),
                         json={"cevaplar": _dogru_cevaplar(con, deneme)}).get_json()
    assert sonuc["puan"] == 100 and sonuc["dogru_sayisi"] == 10
    assert sonuc["tekrar_okunacak_konular"] == []
    assert sonuc["degerlendirme"].startswith("Mükemmel")


def test_yanlis_cevaplarda_konu_onerilir(istemci, token, con):
    deneme = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    sonuc = istemci.post(f"/api/quiz/{deneme['deneme_id']}/gonder", headers=_bearer(token),
                         json={"cevaplar": _yanlis_cevaplar(con, deneme)}).get_json()
    assert sonuc["puan"] == 0
    assert len(sonuc["tekrar_okunacak_konular"]) == 7  # her konudan en az bir soru vardı
    ilk = sonuc["sorular"][0]
    assert ilk["dogru_mu"] is False and ilk["dogru_cevap"] != ilk["verilen"] and ilk["aciklama"]


def test_sonuc_panelde_gorunur(istemci, token, con):
    deneme = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    cevaplar = _dogru_cevaplar(con, deneme)
    ilk_soru = next(iter(cevaplar))
    cevaplar[ilk_soru] = _yanlis_cevaplar(con, deneme)[ilk_soru]  # 9 doğru, 1 yanlış
    istemci.post(f"/api/quiz/{deneme['deneme_id']}/gonder", headers=_bearer(token), json={"cevaplar": cevaplar})

    assert istemci.get("/api/ben", headers=_bearer(token)).get_json()["en_iyi_quiz_puani"] == 90
    gecmis = istemci.get("/api/quiz/gecmis", headers=_bearer(token)).get_json()
    assert gecmis[0]["puan"] == 90 and gecmis[0]["deneme_id"] == deneme["deneme_id"]


# ------------------------------------------------------------------ doğrulama kuralları

def test_eksik_cevap_reddedilir(istemci, token, con):
    deneme = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    cevaplar = _dogru_cevaplar(con, deneme)
    cevaplar.pop(next(iter(cevaplar)))
    yanit = istemci.post(f"/api/quiz/{deneme['deneme_id']}/gonder", headers=_bearer(token), json={"cevaplar": cevaplar})
    assert yanit.status_code == 400 and "1 soru cevaplanmadı" in yanit.get_json()["hata"]


def test_baska_sorunun_secenegi_reddedilir(istemci, token, con):
    deneme = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    cevaplar = _dogru_cevaplar(con, deneme)
    a, b = list(cevaplar)[:2]
    cevaplar[a], cevaplar[b] = cevaplar[b], cevaplar[a]
    yanit = istemci.post(f"/api/quiz/{deneme['deneme_id']}/gonder", headers=_bearer(token), json={"cevaplar": cevaplar})
    assert yanit.status_code == 400


def test_denemede_olmayan_soru_reddedilir(istemci, token, con):
    deneme = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    cevaplar = _dogru_cevaplar(con, deneme)
    cevaplar["9999"] = 1
    yanit = istemci.post(f"/api/quiz/{deneme['deneme_id']}/gonder", headers=_bearer(token), json={"cevaplar": cevaplar})
    assert yanit.status_code == 400


@pytest.mark.parametrize("govde", [{}, {"cevaplar": []}, {"cevaplar": {"1": "abc"}}, {"cevaplar": {"1": True}}])
def test_bozuk_govde_reddedilir(istemci, token, govde):
    deneme = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    yanit = istemci.post(f"/api/quiz/{deneme['deneme_id']}/gonder", headers=_bearer(token), json=govde)
    assert yanit.status_code == 400


def test_ayni_deneme_iki_kez_gonderilemez(istemci, token, con):
    deneme = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    govde = {"cevaplar": _dogru_cevaplar(con, deneme)}
    yol = f"/api/quiz/{deneme['deneme_id']}/gonder"
    assert istemci.post(yol, headers=_bearer(token), json=govde).status_code == 200
    assert istemci.post(yol, headers=_bearer(token), json=govde).status_code == 409
    assert con.execute("SELECT COUNT(*) FROM quiz_sonucu").fetchone()[0] == 1


def test_suresi_dolan_deneme_kabul_edilmez(istemci, token, con):
    deneme = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    con.execute("UPDATE quiz_deneme SET son_teslim = datetime('now', '-1 minute')")
    con.commit()
    yanit = istemci.post(f"/api/quiz/{deneme['deneme_id']}/gonder", headers=_bearer(token),
                         json={"cevaplar": _dogru_cevaplar(con, deneme)})
    assert yanit.status_code == 410
    # Süresi dolan denemenin yerine yeni bir deneme açılabilir
    yeni = istemci.post("/api/quiz/baslat", headers=_bearer(token))
    assert yeni.status_code == 201 and yeni.get_json()["deneme_id"] != deneme["deneme_id"]


def test_baskasinin_denemesi_404(istemci, token, con):
    deneme = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    baska = _hesap(istemci, eposta="baska@ornek.test")
    yol = f"/api/quiz/{deneme['deneme_id']}"
    assert istemci.get(yol, headers=_bearer(baska)).status_code == 404
    assert istemci.post(yol + "/gonder", headers=_bearer(baska),
                        json={"cevaplar": _dogru_cevaplar(con, deneme)}).status_code == 404


def test_kullanici_silinince_quiz_kayitlari_silinir(istemci, token, con):
    deneme = istemci.post("/api/quiz/baslat", headers=_bearer(token)).get_json()
    istemci.post(f"/api/quiz/{deneme['deneme_id']}/gonder", headers=_bearer(token),
                 json={"cevaplar": _dogru_cevaplar(con, deneme)})
    kullanici_repo.sil(con, kullanici_repo.eposta_ile_getir(con, "quiz@ornek.test")["id"])
    for tablo in ("quiz_deneme", "quiz_deneme_soru", "quiz_sonucu"):
        assert con.execute(f"SELECT COUNT(*) FROM {tablo}").fetchone()[0] == 0, tablo


# ------------------------------------------------------------------ puan

@pytest.mark.parametrize("dogru,soru,puan", [(10, 10, 100), (0, 10, 0), (7, 10, 70), (1, 8, 13), (1, 3, 33), (2, 3, 67)])
def test_puan_hesabi_yarimi_yukari_yuvarlar(dogru, soru, puan):
    assert quiz_repo.puan_hesapla(dogru, soru) == puan
