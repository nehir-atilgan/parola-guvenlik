from flask import Blueprint, jsonify

from app.config import SURUM
from app.veri import get_db
from app.veri.repolar import oneri_repo

bp = Blueprint("api", __name__, url_prefix="/api")

# Sitenin modülleri; ilerleyen haftalarda her biri kendi uç noktasına kavuşacak.
MODULLER = [
    {"kod": "analiz", "ad": "Parola Gücü Analizi", "aciklama": "Parolanızın ne kadar güçlü olduğunu ölçün.", "sayfa": "analiz.html"},
    {"kod": "sizinti", "ad": "Sızıntı Kontrolü", "aciklama": "Parolanız bilinen veri sızıntılarında var mı?"},
    {"kod": "rehber", "ad": "Farkındalık Rehberi", "aciklama": "Güçlü parola, 2FA, oltalama ve daha fazlası.", "sayfa": "rehber.html"},
    {"kod": "quiz", "ad": "Farkındalık Quizi", "aciklama": "10 soruda bilginizi test edin.", "sayfa": "quiz.html"},
    {"kod": "rapor", "ad": "Kişisel Skor ve Rapor", "aciklama": "Güvenlik durumunuzu tek sayfada görün."},
]


@bp.get("/saglik")
def saglik():
    """Backend'in ve veritabanının çalıştığını gösteren basit kontrol."""
    get_db().execute("SELECT 1")
    return jsonify(durum="calisiyor", veritabani="bagli", surum=SURUM)


@bp.get("/moduller")
def moduller():
    return jsonify(MODULLER)


@bp.get("/oneriler")
def oneriler():
    """Veritabanındaki öneri kataloğu (veri erişim katmanının uçtan uca çalıştığını gösterir)."""
    return jsonify([dict(o) for o in oneri_repo.listele(get_db())])
