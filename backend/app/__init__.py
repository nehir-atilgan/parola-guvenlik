"""Uygulama fabrikası: backend katmanlarını (API / servis / veri) birbirine bağlar."""
import click
from flask import Flask, request

from app import veri
from app.config import Config
from app.veri import baglanti_ac, migrator, ornek_veri


def create_app(config_class=Config, **ayarlar):
    app = Flask(__name__)
    app.config.from_object(config_class)
    app.config.update(ayarlar)

    # Veri katmanı: bağlantı yönetimi + bekleyen migration'ları uygula
    veri.init_app(app)
    con = baglanti_ac(app.config["VERITABANI"])
    try:
        migrator.uygula(con)
    finally:
        con.close()

    # API katmanı
    from app.api.routes import bp as api_bp
    app.register_blueprint(api_bp)

    # CORS: yalnızca izin verilen frontend adreslerinden gelen isteklere yanıt ver
    @app.after_request
    def cors_basliklari(yanit):
        kaynak = request.headers.get("Origin")
        if kaynak in app.config["FRONTEND_ORIGINS"]:
            yanit.headers["Access-Control-Allow-Origin"] = kaynak
            yanit.headers["Access-Control-Allow-Headers"] = "Content-Type"
            yanit.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
            yanit.headers["Vary"] = "Origin"
        return yanit

    _komutlari_ekle(app)
    return app


def _komutlari_ekle(app):
    """Terminal komutları:  flask --app run <komut>"""

    @app.cli.command("db-durum")
    def db_durum():
        """Uygulanmış migration'ları ve tablo satır sayılarını gösterir."""
        con = baglanti_ac(app.config["VERITABANI"])
        click.echo(f"Veritabanı: {app.config['VERITABANI']}")
        for r in con.execute("SELECT surum, dosya, uygulanma_tarihi FROM schema_surumu ORDER BY surum"):
            click.echo(f"  ✔ {r['dosya']}  ({r['uygulanma_tarihi']})")
        for tablo in ("kullanici", "analiz_kaydi", "oneri", "analiz_oneri", "quiz_sonucu"):
            sayi = con.execute(f"SELECT COUNT(*) FROM {tablo}").fetchone()[0]
            click.echo(f"  {tablo:<14} {sayi:>4} satır")
        con.close()

    @app.cli.command("ornek-veri")
    def ornek_veri_yukle():
        """Sentetik örnek veriyi yükler (KVKK uyumlu, gerçek kişi verisi yok)."""
        con = baglanti_ac(app.config["VERITABANI"])
        click.echo(ornek_veri.yukle(con))
        con.close()
