"""Parola Gücü Analizi uç noktaları (Hafta 6).

POST   /api/analiz             herkes analiz yapabilir; giriş yapan kullanıcı "kaydet" diyebilir
GET    /api/analizler          🔒 kendi analiz geçmişi
GET    /api/analizler/<id>     🔒 yalnızca kendi kaydı (başkasınınki için 404)
DELETE /api/analizler/<id>     🔒 yalnızca kendi kaydı

Parola istek gövdesinde gelir, bellekte analiz edilir ve yanıta, loglara veya
veritabanına hiçbir zaman yazılmaz.
"""
from flask import Blueprint, g, jsonify, request

from app.api.yetki import giris_gerekli, istek_kullanicisi
from app.servisler import parola_analiz
from app.servisler.parola_analiz import AnalizHatasi
from app.veri import get_db
from app.veri.repolar import analiz_repo, oneri_repo

bp = Blueprint("analiz", __name__, url_prefix="/api")


@bp.errorhandler(AnalizHatasi)
def analiz_hatasi(hata):
    return jsonify(hata=hata.mesaj), 400


def _oneri_detaylari(con, kodlar):
    katalog = {o["kod"]: o for o in oneri_repo.listele(con)}
    return [
        {"oncelik": i, "kod": k, "baslik": katalog[k]["baslik"], "aciklama": katalog[k]["aciklama"]}
        for i, k in enumerate(kodlar, start=1) if k in katalog
    ]


def _kayit_json(a):
    return {
        "id": a["id"], "tarih": a["analiz_tarihi"], "uzunluk": a["uzunluk"],
        "guc_skoru": a["guc_skoru"], "guc_seviyesi": a["guc_seviyesi"], "entropi_bit": a["entropi_bit"],
        "buyuk_harf": bool(a["buyuk_harf"]), "kucuk_harf": bool(a["kucuk_harf"]),
        "rakam": bool(a["rakam"]), "ozel_karakter": bool(a["ozel_karakter"]),
        "sizinti_sayisi": a["sizinti_sayisi"],
    }


@bp.post("/analiz")
def analiz():
    veri = request.get_json(silent=True) or {}
    kaydet = veri.get("kaydet") is True

    kullanici = istek_kullanicisi()
    if kaydet and kullanici is None:
        return jsonify(hata="Sonucu kaydetmek için giriş yapmalısınız."), 401

    con = get_db()
    sonuc = parola_analiz.analiz_et(
        veri.get("parola"),
        ad_soyad=kullanici["ad_soyad"] if kullanici else None,
        eposta=kullanici["eposta"] if kullanici else None,
    )
    kodlar = parola_analiz.oneri_kodlari_sec(sonuc)
    sonuc["oneriler"] = _oneri_detaylari(con, kodlar)

    sonuc["analiz_id"] = None
    if kaydet:
        sonuc["analiz_id"] = analiz_repo.onerileriyle_kaydet(con, kullanici["id"], sonuc, kodlar)
    return jsonify(sonuc), 201 if kaydet else 200


@bp.get("/analizler")
@giris_gerekli
def analizlerim():
    kayitlar = analiz_repo.kullanici_analizleri(get_db(), g.kullanici["id"], limit=50)
    return jsonify([_kayit_json(a) for a in kayitlar])


@bp.get("/analizler/<int:analiz_id>")
@giris_gerekli
def analiz_detay(analiz_id):
    con = get_db()
    kayit = analiz_repo.kullaniciya_ait_getir(con, analiz_id, g.kullanici["id"])
    if kayit is None:
        # Başkasının kaydı için de 404: kaydın var olup olmadığı bile açığa çıkmaz.
        return jsonify(hata="Analiz bulunamadı."), 404
    return jsonify({**_kayit_json(kayit),
                    "oneriler": [dict(o) for o in analiz_repo.analiz_onerileri(con, analiz_id)]})


@bp.delete("/analizler/<int:analiz_id>")
@giris_gerekli
def analiz_sil(analiz_id):
    con = get_db()
    if analiz_repo.kullaniciya_ait_getir(con, analiz_id, g.kullanici["id"]) is None:
        return jsonify(hata="Analiz bulunamadı."), 404
    analiz_repo.sil(con, analiz_id)  # bağlı öneriler CASCADE ile silinir
    return jsonify(mesaj="Analiz silindi.")
