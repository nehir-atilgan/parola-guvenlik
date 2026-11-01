"""Uygulama fabrikası: backend katmanlarını (API / servis / veri) birbirine bağlar."""
from flask import Flask, request

from app.config import Config
from app.veri import db


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Veri katmanı
    db.init_app(app)

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
            yanit.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
            yanit.headers["Vary"] = "Origin"
        return yanit

    with app.app_context():
        from app.veri import models  # noqa: F401  (tabloların tanınması için)
        db.create_all()

    return app
