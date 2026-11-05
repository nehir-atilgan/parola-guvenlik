"""Farkındalık Rehberi ve Quiz uç noktaları (Hafta 7).

GET  /api/rehber                 herkese açık: konu listesi
GET  /api/rehber/<slug>          herkese açık: konu içeriği
POST /api/quiz/baslat            🔒 yeni deneme (açık deneme varsa onu döndürür)
GET  /api/quiz/<deneme_id>       🔒 açık denemenin soruları veya tamamlanmış denemenin sonucu
POST /api/quiz/<deneme_id>/gonder 🔒 cevapları gönderir, puanı hesaplar
GET  /api/quiz/gecmis            🔒 kullanıcının quiz sonuçları
"""
from flask import Blueprint, g, jsonify, request

from app.api.yetki import giris_gerekli
from app.servisler import quiz_servisi
from app.servisler.quiz_servisi import QuizHatasi
from app.veri import get_db
from app.veri.repolar import quiz_repo, rehber_repo

bp = Blueprint("rehber_quiz", __name__, url_prefix="/api")


@bp.errorhandler(QuizHatasi)
def quiz_hatasi(hata):
    return jsonify(hata=hata.mesaj), hata.durum


# ------------------------------------------------------------------ rehber

@bp.get("/rehber")
def rehber_listesi():
    return jsonify([dict(k) for k in rehber_repo.listele(get_db())])


@bp.get("/rehber/<slug>")
def rehber_konusu(slug):
    con = get_db()
    konu = rehber_repo.slug_ile_getir(con, slug)
    if konu is None:
        return jsonify(hata="Rehber konusu bulunamadı."), 404
    onceki, sonraki = rehber_repo.komsular(con, konu["sira"])
    return jsonify({
        "slug": konu["slug"],
        "baslik": konu["baslik"],
        "ozet": konu["ozet"],
        "sira": konu["sira"],
        "paragraflar": [p.strip() for p in konu["icerik"].split("\n\n") if p.strip()],
        "anahtar_noktalar": [m for m in konu["anahtar_noktalar"].splitlines() if m.strip()],
        "ilgili_oneriler": [dict(o) for o in rehber_repo.konuya_bagli_oneriler(con, konu["id"])],
        "onceki": dict(onceki) if onceki else None,
        "sonraki": dict(sonraki) if sonraki else None,
    })


# ------------------------------------------------------------------ quiz

@bp.post("/quiz/baslat")
@giris_gerekli
def quiz_baslat():
    deneme = quiz_servisi.baslat(get_db(), g.kullanici["id"])
    return jsonify(deneme), 200 if deneme["kaldigi_yerden"] else 201


@bp.get("/quiz/gecmis")
@giris_gerekli
def quiz_gecmisi():
    return jsonify([
        {"deneme_id": s["deneme_id"], "tarih": s["tamamlanma_tarihi"], "puan": s["puan"],
         "dogru_sayisi": s["dogru_sayisi"], "soru_sayisi": s["soru_sayisi"]}
        for s in quiz_repo.kullanici_sonuclari(get_db(), g.kullanici["id"])
    ])


@bp.get("/quiz/<int:deneme_id>")
@giris_gerekli
def quiz_getir(deneme_id):
    return jsonify(quiz_servisi.sonuc(get_db(), g.kullanici["id"], deneme_id))


@bp.post("/quiz/<int:deneme_id>/gonder")
@giris_gerekli
def quiz_gonder(deneme_id):
    veri = request.get_json(silent=True) or {}
    return jsonify(quiz_servisi.gonder(get_db(), g.kullanici["id"], deneme_id, veri.get("cevaplar")))
