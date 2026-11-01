def test_saglik_kontrolu(istemci):
    assert istemci.get("/api/saglik").get_json() == {"durum": "calisiyor", "veritabani": "bagli"}


def test_moduller_listesi(istemci):
    moduller = istemci.get("/api/moduller").get_json()
    assert len(moduller) == 5
    assert {"kod", "ad", "aciklama"} <= set(moduller[0])


def test_oneriler_veritabanindan_gelir(istemci):
    oneriler = istemci.get("/api/oneriler").get_json()
    assert len(oneriler) == 9
    assert {o["kod"] for o in oneriler} >= {"UZUNLUK_ARTIR", "IKI_FAKTOR"}


def test_cors_izinli_frontend(istemci):
    yanit = istemci.get("/api/saglik", headers={"Origin": "http://127.0.0.1:8000"})
    assert yanit.headers["Access-Control-Allow-Origin"] == "http://127.0.0.1:8000"


def test_cors_yabanci_site_reddedilir(istemci):
    yanit = istemci.get("/api/saglik", headers={"Origin": "https://kotu-site.com"})
    assert "Access-Control-Allow-Origin" not in yanit.headers
