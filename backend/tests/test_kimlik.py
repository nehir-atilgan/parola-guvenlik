"""Kimlik doğrulama ve rol tabanlı erişim testleri."""
import pytest

from app.veri.repolar import kullanici_repo

PAROLA = "GucluParola1"


def _kayit(istemci, eposta="ayse@ornek.test", parola=PAROLA, **ek):
    return istemci.post("/api/kayit", json={"ad_soyad": "Ayşe Test", "eposta": eposta, "parola": parola, **ek})


def _giris(istemci, eposta="ayse@ornek.test", parola=PAROLA):
    return istemci.post("/api/giris", json={"eposta": eposta, "parola": parola})


def _token(istemci, **kw):
    return _giris(istemci, **kw).get_json()["token"]


def _bearer(token):
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def yonetici_token(istemci, con):
    _kayit(istemci, eposta="admin@ornek.test")
    kullanici_repo.rol_ata(con, kullanici_repo.eposta_ile_getir(con, "admin@ornek.test")["id"], "yonetici")
    return _token(istemci, eposta="admin@ornek.test")


# ------------------------------------------------------------------ kayıt

def test_kayit_basarili(istemci):
    yanit = _kayit(istemci)
    assert yanit.status_code == 201
    assert yanit.get_json()["kullanici"]["rol"] == "kullanici"


def test_parola_duz_metin_saklanmaz(istemci, con):
    _kayit(istemci)
    sifre_hash = kullanici_repo.eposta_ile_getir(con, "ayse@ornek.test")["sifre_hash"]
    assert PAROLA not in sifre_hash
    assert sifre_hash.startswith("scrypt:")


def test_ayni_parola_farkli_hash_uretir(istemci, con):
    """Tuz (salt) sayesinde aynı parola iki kullanıcıda farklı hash'lenir."""
    _kayit(istemci, eposta="a@ornek.test")
    _kayit(istemci, eposta="b@ornek.test")
    h1 = kullanici_repo.eposta_ile_getir(con, "a@ornek.test")["sifre_hash"]
    h2 = kullanici_repo.eposta_ile_getir(con, "b@ornek.test")["sifre_hash"]
    assert h1 != h2


def test_kayitta_rol_gonderilse_bile_yonetici_olunmaz(istemci):
    yanit = _kayit(istemci, rol="yonetici")
    assert yanit.get_json()["kullanici"]["rol"] == "kullanici"


@pytest.mark.parametrize("parola", ["kisa1", "sadeceharf", "12345678"])
def test_zayif_site_parolasi_reddedilir(istemci, parola):
    assert _kayit(istemci, parola=parola).status_code == 400


def test_ayni_eposta_ile_ikinci_kayit(istemci):
    _kayit(istemci)
    assert _kayit(istemci, eposta="AYSE@ornek.test").status_code == 409


# ------------------------------------------------------------------ giriş / çıkış

def test_giris_basarili_token_doner(istemci):
    _kayit(istemci)
    yanit = _giris(istemci)
    assert yanit.status_code == 200 and len(yanit.get_json()["token"]) > 30


def test_yanlis_parola_ve_olmayan_eposta_ayni_mesaji_verir(istemci):
    _kayit(istemci)
    yanlis_parola = _giris(istemci, parola="YanlisParola9")
    olmayan = _giris(istemci, eposta="yok@ornek.test")
    assert yanlis_parola.status_code == olmayan.status_code == 401
    assert yanlis_parola.get_json() == olmayan.get_json()


def test_bes_hatali_denemede_hesap_kilitlenir(istemci):
    _kayit(istemci)
    for _ in range(5):
        assert _giris(istemci, parola="YanlisParola9").status_code == 401
    # Doğru parola bile kilit süresince kabul edilmez
    assert _giris(istemci).status_code == 429


def test_token_veritabaninda_acik_saklanmaz(istemci, con):
    _kayit(istemci)
    token = _token(istemci)
    ozetler = [r[0] for r in con.execute("SELECT token_ozeti FROM oturum")]
    assert token not in ozetler and len(ozetler) == 1


def test_cikistan_sonra_token_gecersiz(istemci):
    _kayit(istemci)
    token = _token(istemci)
    assert istemci.get("/api/ben", headers=_bearer(token)).status_code == 200
    assert istemci.post("/api/cikis", headers=_bearer(token)).status_code == 200
    assert istemci.get("/api/ben", headers=_bearer(token)).status_code == 401


def test_suresi_dolmus_token_reddedilir(istemci, con):
    _kayit(istemci)
    token = _token(istemci)
    con.execute("UPDATE oturum SET bitis = datetime('now', '-1 minute')")
    con.commit()
    assert istemci.get("/api/ben", headers=_bearer(token)).status_code == 401


# ------------------------------------------------------------------ yetkilendirme

def test_tokensiz_korumali_sayfa_401(istemci):
    assert istemci.get("/api/ben").status_code == 401


def test_sahte_token_401(istemci):
    assert istemci.get("/api/ben", headers=_bearer("uydurma-token")).status_code == 401


def test_normal_kullanici_yonetici_sayfasina_giremez_403(istemci):
    _kayit(istemci)
    token = _token(istemci)
    assert istemci.get("/api/yonetici/kullanicilar", headers=_bearer(token)).status_code == 403


def test_yonetici_kullanicilari_gorebilir(istemci, yonetici_token):
    yanit = istemci.get("/api/yonetici/kullanicilar", headers=_bearer(yonetici_token))
    assert yanit.status_code == 200
    assert any(k["rol"] == "yonetici" for k in yanit.get_json())


def test_rol_degisince_eski_oturum_kapanir(istemci, yonetici_token):
    _kayit(istemci)
    kullanici_token = _token(istemci)
    kid = istemci.get("/api/ben", headers=_bearer(kullanici_token)).get_json()["kullanici"]["id"]

    yanit = istemci.patch(f"/api/yonetici/kullanicilar/{kid}/rol",
                          json={"rol": "yonetici"}, headers=_bearer(yonetici_token))
    assert yanit.status_code == 200 and yanit.get_json()["rol"] == "yonetici"
    assert istemci.get("/api/ben", headers=_bearer(kullanici_token)).status_code == 401


def test_yonetici_kendi_rolunu_degistiremez(istemci, yonetici_token):
    ben = istemci.get("/api/ben", headers=_bearer(yonetici_token)).get_json()["kullanici"]
    yanit = istemci.patch(f"/api/yonetici/kullanicilar/{ben['id']}/rol",
                          json={"rol": "kullanici"}, headers=_bearer(yonetici_token))
    assert yanit.status_code == 400


def test_cors_authorization_basligina_izin_verir(istemci):
    yanit = istemci.options("/api/ben", headers={
        "Origin": "http://127.0.0.1:8000",
        "Access-Control-Request-Method": "GET",
        "Access-Control-Request-Headers": "Authorization",
    })
    assert "Authorization" in yanit.headers["Access-Control-Allow-Headers"]
