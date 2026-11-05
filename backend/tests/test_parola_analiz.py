"""Parola Gücü Analizi testleri: iş kuralları (birim) + API + sahiplik + parolanın saklanmaması."""
import random
import string

import pytest

from app.servisler.parola_analiz import AnalizHatasi, analiz_et, oneri_kodlari_sec


# ================================================================== iş kuralları (birim testleri)

@pytest.mark.parametrize("parola", ["123456", "password", "qwerty", "P@ssw0rd", "Şifre", "galatasaray"])
def test_yaygin_parola_en_fazla_5(parola):
    sonuc = analiz_et(parola)
    assert sonuc["guc_skoru"] <= 5 and sonuc["guc_seviyesi"] == "zayif"
    assert "yaygin_parola" in sonuc["bulgular"] and sonuc["kirilma_suresi"] == "anında"


@pytest.mark.parametrize("parola", ["Galatasaray1905", "qwerty2024!", "Password123!"])
def test_yaygin_parola_turevi_en_fazla_15(parola):
    assert analiz_et(parola)["guc_skoru"] <= 15


def test_kisa_parola_her_zaman_zayif():
    sonuc = analiz_et("Ab1!x9")  # 6 karakter, 4 tür
    assert sonuc["guc_skoru"] <= 30 and sonuc["guc_seviyesi"] == "zayif"


def test_12_karakterden_kisa_parola_guclu_olamaz():
    sonuc = analiz_et("Tr!7kq#Lm2@")  # 11 karakter, çok çeşitli
    assert sonuc["guc_seviyesi"] != "guclu" and sonuc["guc_skoru"] <= 69


def test_rastgele_uzun_parola_guclu():
    sonuc = analiz_et("Tr!7kq#Lm2@vZ9xW")
    assert sonuc["guc_skoru"] == 100 and sonuc["guc_seviyesi"] == "guclu" and sonuc["bulgular"] == []


def test_uzun_parola_cumlesi_guclu():
    assert analiz_et("correct horse battery staple")["guc_seviyesi"] == "guclu"


def test_tekrar_eden_karakterler_zayif():
    sonuc = analiz_et("aaaaaaaaaaaaaaaa")
    assert "tekrar" in sonuc["bulgular"] and sonuc["guc_seviyesi"] == "zayif"


@pytest.mark.parametrize("parola,bulgu", [
    ("Xk9!abcQw7#m", "ardisik"),
    ("Mavi!asdf7Kz", "klavye"),
    ("Mavi!Bulut1998", "yil"),
    ("83920174650912", "sadece_rakam"),
    ("Mavi.Ankara!7z", "yaygin_kelime"),
])
def test_desenler_bulunur(parola, bulgu):
    assert bulgu in analiz_et(parola)["bulgular"]


def test_kisisel_bilgi_cezalandirilir():
    parola = "Atilgan!2k9Xz"
    kisiye_ozel = analiz_et(parola, ad_soyad="Nehir Atılgan", eposta="nehir.atilgan@ornek.test")
    anonim = analiz_et(parola)
    assert "kisisel_bilgi" in kisiye_ozel["bulgular"]
    assert kisiye_ozel["guc_skoru"] == anonim["guc_skoru"] - 30


def test_skor_ve_olcutler_tutarli():
    sonuc = analiz_et("Mavi!Bulut1998")
    toplam = sum(o["puan"] for o in sonuc["olcutler"]) + sum(c["puan"] for c in sonuc["cezalar"])
    assert sonuc["guc_skoru"] == max(0, min(100, toplam))  # bu parolada üst sınır kuralı yok


def test_skor_her_zaman_0_100_arasinda_ve_seviye_uyumlu():
    rnd = random.Random(1)
    karakterler = string.ascii_letters + string.digits + string.punctuation + " çğıöşüİ"
    for _ in range(500):
        parola = "".join(rnd.choice(karakterler) for _ in range(rnd.randint(1, 40)))
        s = analiz_et(parola)
        assert 0 <= s["guc_skoru"] <= 100
        beklenen = "zayif" if s["guc_skoru"] < 40 else "orta" if s["guc_skoru"] < 70 else "guclu"
        assert s["guc_seviyesi"] == beklenen


def test_sonucta_parola_yer_almaz():
    parola = "GizliParola!42xyz"
    assert parola not in str(analiz_et(parola))


@pytest.mark.parametrize("parola", ["", None, 12345, "x" * 129])
def test_gecersiz_girdi_reddedilir(parola):
    with pytest.raises(AnalizHatasi):
        analiz_et(parola)


def test_oneriler_bulgulara_gore_ve_en_fazla_5():
    kodlar = oneri_kodlari_sec(analiz_et("Galatasaray1905"))
    assert kodlar[0] == "YAYGIN_PAROLA" and len(kodlar) <= 5
    guclu = oneri_kodlari_sec(analiz_et("Tr!7kq#Lm2@vZ9xW"))
    assert guclu == ["IKI_FAKTOR", "PAROLA_YONETICI"]


# ================================================================== API

PAROLA = "GucluParola1"


def _giris(istemci, eposta):
    istemci.post("/api/kayit", json={"ad_soyad": "Test Kişi", "eposta": eposta, "parola": PAROLA})
    token = istemci.post("/api/giris", json={"eposta": eposta, "parola": PAROLA}).get_json()["token"]
    return {"Authorization": f"Bearer {token}"}


def test_girissiz_analiz_yapilabilir_ama_kaydedilmez(istemci, con):
    yanit = istemci.post("/api/analiz", json={"parola": "Mavi!Bulut1998"})
    assert yanit.status_code == 200
    veri = yanit.get_json()
    assert veri["analiz_id"] is None and veri["oneriler"]
    assert con.execute("SELECT COUNT(*) FROM analiz_kaydi").fetchone()[0] == 0


def test_girissiz_kaydetme_401(istemci):
    assert istemci.post("/api/analiz", json={"parola": "abc", "kaydet": True}).status_code == 401


def test_bos_parola_400(istemci):
    yanit = istemci.post("/api/analiz", json={"parola": ""})
    assert yanit.status_code == 400 and "hata" in yanit.get_json()


def test_kaydedilen_analiz_ve_onerileri_tek_islemde(istemci, con):
    baslik = _giris(istemci, "a@ornek.test")
    veri = istemci.post("/api/analiz", json={"parola": "qwerty2024!", "kaydet": True}, headers=baslik).get_json()
    aid = veri["analiz_id"]
    kayit = con.execute("SELECT * FROM analiz_kaydi WHERE id = ?", (aid,)).fetchone()
    assert kayit["guc_skoru"] == veri["guc_skoru"] and kayit["entropi_bit"] == veri["entropi_bit"]
    oneri_sayisi = con.execute("SELECT COUNT(*) FROM analiz_oneri WHERE analiz_id = ?", (aid,)).fetchone()[0]
    assert oneri_sayisi == len(veri["oneriler"])


def test_parola_veritabaninin_hicbir_yerinde_yok(istemci, con):
    gizli = "BenimCokGizliParolam!93"
    baslik = _giris(istemci, "b@ornek.test")
    istemci.post("/api/analiz", json={"parola": gizli, "kaydet": True}, headers=baslik)
    tum_veritabani = "\n".join(con.iterdump())
    assert gizli not in tum_veritabani and gizli.lower() not in tum_veritabani.lower()


def test_yanit_parolayi_geri_gondermez(istemci):
    gizli = "BenimCokGizliParolam!93"
    yanit = istemci.post("/api/analiz", json={"parola": gizli})
    assert gizli not in yanit.get_data(as_text=True)


def test_giris_yapan_kullanicinin_adi_cezalandirilir(istemci):
    baslik = _giris(istemci, "c@ornek.test")  # ad soyad: "Test Kişi"
    veri = istemci.post("/api/analiz", json={"parola": "Kisi!7xQ9zLp"}, headers=baslik).get_json()
    assert "kisisel_bilgi" in veri["bulgular"]


def test_gecmis_yalnizca_kendi_kayitlarini_gosterir(istemci):
    ayse = _giris(istemci, "ayse@ornek.test")
    ali = _giris(istemci, "ali@ornek.test")
    istemci.post("/api/analiz", json={"parola": "abc12345", "kaydet": True}, headers=ayse)
    istemci.post("/api/analiz", json={"parola": "xyz98765", "kaydet": True}, headers=ayse)
    istemci.post("/api/analiz", json={"parola": "Tr!7kq#Lm2@vZ9xW", "kaydet": True}, headers=ali)
    assert len(istemci.get("/api/analizler", headers=ayse).get_json()) == 2
    assert len(istemci.get("/api/analizler", headers=ali).get_json()) == 1


def test_baskasinin_analizine_erisilemez_ve_silinemez(istemci, con):
    ayse = _giris(istemci, "ayse@ornek.test")
    ali = _giris(istemci, "ali@ornek.test")
    aid = istemci.post("/api/analiz", json={"parola": "abc12345", "kaydet": True}, headers=ayse).get_json()["analiz_id"]

    assert istemci.get(f"/api/analizler/{aid}", headers=ali).status_code == 404
    assert istemci.delete(f"/api/analizler/{aid}", headers=ali).status_code == 404
    assert con.execute("SELECT COUNT(*) FROM analiz_kaydi WHERE id = ?", (aid,)).fetchone()[0] == 1

    detay = istemci.get(f"/api/analizler/{aid}", headers=ayse)
    assert detay.status_code == 200 and detay.get_json()["oneriler"]


def test_analiz_silinince_onerileri_de_silinir(istemci, con):
    ayse = _giris(istemci, "ayse@ornek.test")
    aid = istemci.post("/api/analiz", json={"parola": "abc12345", "kaydet": True}, headers=ayse).get_json()["analiz_id"]
    assert istemci.delete(f"/api/analizler/{aid}", headers=ayse).status_code == 200
    assert con.execute("SELECT COUNT(*) FROM analiz_oneri WHERE analiz_id = ?", (aid,)).fetchone()[0] == 0


def test_analiz_gecmisi_giris_gerektirir(istemci):
    assert istemci.get("/api/analizler").status_code == 401
    assert istemci.get("/api/analizler/1").status_code == 401
    assert istemci.delete("/api/analizler/1").status_code == 401


def test_panel_kaydedilen_analizi_gosterir(istemci):
    """Önceki modülle (Hafta 5 paneli) entegrasyon."""
    ayse = _giris(istemci, "ayse@ornek.test")
    istemci.post("/api/analiz", json={"parola": "Tr!7kq#Lm2@vZ9xW", "kaydet": True}, headers=ayse)
    son = istemci.get("/api/ben", headers=ayse).get_json()["son_analizler"]
    assert son[0]["skor"] == 100 and son[0]["seviye"] == "guclu"
