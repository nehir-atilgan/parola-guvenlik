from flask import Blueprint, jsonify

bp = Blueprint("api", __name__, url_prefix="/api")

# Sitenin modülleri; ilerleyen haftalarda her biri kendi uç noktasına kavuşacak.
MODULLER = [
    {"kod": "analiz", "ad": "Parola Gücü Analizi", "aciklama": "Parolanızın ne kadar güçlü olduğunu ölçün.", "hafta": 4},
    {"kod": "sizinti", "ad": "Sızıntı Kontrolü", "aciklama": "Parolanız bilinen veri sızıntılarında var mı?", "hafta": 5},
    {"kod": "oneri", "ad": "Öneri ve Rehber", "aciklama": "Size özel güvenlik önerileri alın.", "hafta": 6},
    {"kod": "quiz", "ad": "Farkındalık Quizi", "aciklama": "Bilginizi test edin.", "hafta": 7},
    {"kod": "rapor", "ad": "Kişisel Skor ve Rapor", "aciklama": "Güvenlik durumunuzu tek sayfada görün.", "hafta": 8},
]


@bp.get("/saglik")
def saglik():
    """Backend'in çalıştığını gösteren basit kontrol."""
    return jsonify(durum="calisiyor")


@bp.get("/moduller")
def moduller():
    return jsonify(MODULLER)
