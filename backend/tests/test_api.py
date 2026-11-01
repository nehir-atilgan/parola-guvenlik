import pytest

pytest.importorskip("flask_sqlalchemy")

from app import create_app  # noqa: E402
from app.config import TestConfig  # noqa: E402


@pytest.fixture
def istemci():
    return create_app(TestConfig).test_client()


def test_saglik_kontrolu(istemci):
    assert istemci.get("/api/saglik").get_json() == {"durum": "calisiyor"}


def test_moduller_listesi(istemci):
    moduller = istemci.get("/api/moduller").get_json()
    assert len(moduller) == 5
    assert {"kod", "ad", "aciklama", "hafta"} <= set(moduller[0])


def test_cors_izinli_frontend(istemci):
    yanit = istemci.get("/api/saglik", headers={"Origin": "http://127.0.0.1:8000"})
    assert yanit.headers["Access-Control-Allow-Origin"] == "http://127.0.0.1:8000"


def test_cors_yabanci_site_reddedilir(istemci):
    yanit = istemci.get("/api/saglik", headers={"Origin": "https://kotu-site.com"})
    assert "Access-Control-Allow-Origin" not in yanit.headers
