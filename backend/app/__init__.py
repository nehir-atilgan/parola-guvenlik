"""Uygulama fabrikası: backend katmanlarını (API / servis / veri) birbirine bağlar."""
import os

import click
from flask import Flask, abort, request, send_from_directory

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
        if app.config["ORNEK_VERI"]:
            ornek_veri.yukle(con)  # canlı demo: veritabanı boşsa demo hesaplarını oluşturur
    finally:
        con.close()

    # API katmanı
    from app.api.analiz_routes import bp as analiz_bp
    from app.api.kimlik_routes import bp as kimlik_bp
    from app.api.rehber_quiz_routes import bp as rehber_quiz_bp
    from app.api.routes import bp as api_bp
    app.register_blueprint(api_bp)
    app.register_blueprint(kimlik_bp)
    app.register_blueprint(analiz_bp)
    app.register_blueprint(rehber_quiz_bp)

    _frontend_sun(app)

    # CORS: yalnızca izin verilen frontend adreslerinden gelen isteklere yanıt ver
    # (frontend backend'den sunulduğunda istekler aynı adresten gelir ve CORS gerekmez)
    @app.after_request
    def guvenlik_basliklari(yanit):
        yanit.headers.setdefault("X-Content-Type-Options", "nosniff")
        yanit.headers.setdefault("Referrer-Policy", "same-origin")
        if request.path.startswith("/api/"):
            yanit.headers.setdefault("Cache-Control", "no-store")  # kişisel veriler önbelleğe alınmaz
        return yanit

    @app.after_request
    def cors_basliklari(yanit):
        kaynak = request.headers.get("Origin")
        if kaynak in app.config["FRONTEND_ORIGINS"]:
            yanit.headers["Access-Control-Allow-Origin"] = kaynak
            yanit.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
            yanit.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, PATCH, DELETE, OPTIONS"
            yanit.headers["Vary"] = "Origin"
        return yanit

    _komutlari_ekle(app)
    return app


def _frontend_sun(app):
    """Frontend dosyalarını aynı sunucudan yayınlar (canlı sürüm tek adreste çalışır).

    Yerel geliştirmede frontend ayrıca `python -m http.server 8000` ile de açılabilir;
    iki yöntem de aynı dosyaları kullanır. /api/... adresleri her zaman API'ye gider.
    """
    klasor = app.config["FRONTEND_KLASORU"]
    if not klasor or not os.path.isdir(klasor):
        return

    @app.get("/")
    def ana_sayfa():
        return send_from_directory(klasor, "index.html")

    @app.get("/<path:dosya>")
    def frontend_dosyasi(dosya):
        if dosya.startswith("api/"):
            abort(404)
        return send_from_directory(klasor, dosya)  # klasör dışına çıkma (../) engellenir


def _komutlari_ekle(app):
    """Terminal komutları:  flask --app run <komut>"""

    @app.cli.command("db-durum")
    def db_durum():
        """Uygulanmış migration'ları ve tablo satır sayılarını gösterir."""
        con = baglanti_ac(app.config["VERITABANI"])
        click.echo(f"Veritabanı: {app.config['VERITABANI']}")
        for r in con.execute("SELECT surum, dosya, uygulanma_tarihi FROM schema_surumu ORDER BY surum"):
            click.echo(f"  ✔ {r['dosya']}  ({r['uygulanma_tarihi']})")
        for tablo in ("kullanici", "analiz_kaydi", "oneri", "analiz_oneri", "quiz_sonucu", "oturum",
                      "rehber_konu", "quiz_soru", "quiz_secenek", "quiz_deneme"):
            sayi = con.execute(f"SELECT COUNT(*) FROM {tablo}").fetchone()[0]
            click.echo(f"  {tablo:<17} {sayi:>4} satır")
        con.close()

    @app.cli.command("ornek-veri")
    def ornek_veri_yukle():
        """Sentetik örnek veriyi yükler (KVKK uyumlu, gerçek kişi verisi yok)."""
        con = baglanti_ac(app.config["VERITABANI"])
        click.echo(ornek_veri.yukle(con))
        con.close()

    @app.cli.command("yonetici-yap")
    @click.argument("eposta")
    def yonetici_yap(eposta):
        """Kayıtlı bir kullanıcıya yönetici rolü verir:  flask --app run yonetici-yap ad@ornek.com"""
        from app.veri.repolar import kullanici_repo, oturum_repo
        con = baglanti_ac(app.config["VERITABANI"])
        kullanici = kullanici_repo.eposta_ile_getir(con, eposta)
        if kullanici is None:
            click.echo("Bu e-postayla kayıtlı kullanıcı yok.")
        else:
            kullanici_repo.rol_ata(con, kullanici["id"], "yonetici")
            oturum_repo.kullanici_oturumlarini_iptal_et(con, kullanici["id"])
            click.echo(f"{eposta} artık yönetici. Değişikliğin geçmesi için yeniden giriş yapmalı.")
        con.close()
