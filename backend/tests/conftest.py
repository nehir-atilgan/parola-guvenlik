import pytest

from app import create_app
from app.config import TestConfig
from app.veri import baglanti_ac


@pytest.fixture
def app(tmp_path):
    """Her test için boş, geçici bir veritabanıyla uygulama (migration'lar uygulanmış)."""
    return create_app(TestConfig, VERITABANI=str(tmp_path / "test.db"))


@pytest.fixture
def istemci(app):
    return app.test_client()


@pytest.fixture
def con(app):
    baglanti = baglanti_ac(app.config["VERITABANI"])
    yield baglanti
    baglanti.close()
