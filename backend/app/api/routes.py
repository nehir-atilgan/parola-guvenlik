from flask import Blueprint, jsonify

from app.veri import get_db
from app.veri.repolar import oneri_repo

bp = Blueprint("api", __name__, url_prefix="/api")

# Sitenin modülleri; ilerleyen haftalarda her biri kendi uç noktasına kavuşacak.
MODULLER = [
    {"kod": "analiz", "ad": "Parola Gücü Analizi", "aciklama": "Parolanızın ne kadar güçlü olduğunu ölçün."},
    {"kod": "sizinti", "ad": "Sızıntı Kontrolü", "aciklama": "Parolanız bilinen veri sızıntılarında var mı?"},
    {"kod": "oneri", "ad": "Öneri ve Rehber", "aciklama": "Size özel güvenlik önerileri alın."},
    {"kod": "quiz", "ad": "Farkındalık Quizi", "aciklama": "Bilginizi test edin."},
    {"kod": "rapor", "ad": "Kişisel Skor ve Rapor", "aciklama": "Güvenlik durumunuzu tek sayfada görün."},
]


@bp.get("/saglik")
def saglik():
    """Backend'in ve veritabanının çalıştığını gösteren basit kontrol."""
    get_db().execute("SELECT 1")
    return jsonify(durum="calisiyor", veritabani="bagli")


@bp.get("/moduller")
def moduller():
    return jsonify(MODULLER)


@bp.get("/oneriler")
def oneriler():
    """Veritabanındaki öneri kataloğu (veri erişim katmanının uçtan uca çalıştığını gösterir)."""
    return jsonify([dict(o) for o in oneri_repo.listele(get_db())])
