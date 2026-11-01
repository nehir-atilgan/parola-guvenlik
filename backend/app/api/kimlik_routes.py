"""Kimlik doğrulama ve yönetici uç noktaları."""
from flask import Blueprint, g, jsonify, request

from app.api.yetki import giris_gerekli, istek_tokeni, rol_gerekli
from app.servisler import kimlik_servisi
from app.servisler.kimlik_servisi import KimlikHatasi
from app.veri import get_db
from app.veri.repolar import analiz_repo, kullanici_repo, quiz_repo

bp = Blueprint("kimlik", __name__, url_prefix="/api")


def _kullanici_json(k):
    return {"id": k["id"], "ad_soyad": k["ad_soyad"], "eposta": k["eposta"], "rol": k["rol"]}


@bp.errorhandler(KimlikHatasi)
def kimlik_hatasi(hata):
    return jsonify(hata=hata.mesaj), hata.durum


# ------------------------------------------------------------------ herkese açık

@bp.post("/kayit")
def kayit():
    veri = request.get_json(silent=True) or {}
    kullanici = kimlik_servisi.kayit_ol(get_db(), veri.get("ad_soyad"), veri.get("eposta"), veri.get("parola"))
    return jsonify(mesaj="Kayıt başarılı. Şimdi giriş yapabilirsiniz.", kullanici=_kullanici_json(kullanici)), 201


@bp.post("/giris")
def giris():
    veri = request.get_json(silent=True) or {}
    token, kullanici = kimlik_servisi.giris_yap(get_db(), veri.get("eposta"), veri.get("parola"))
    return jsonify(token=token, kullanici=_kullanici_json(kullanici))


# ------------------------------------------------------------------ giriş gerekli

@bp.post("/cikis")
@giris_gerekli
def cikis():
    kimlik_servisi.cikis_yap(get_db(), istek_tokeni())
    return jsonify(mesaj="Çıkış yapıldı.")


@bp.get("/ben")
@giris_gerekli
def ben():
    """Giriş yapmış kullanıcının bilgileri ve kendi kayıtlarının özeti."""
    con = get_db()
    k = g.kullanici
    analizler = analiz_repo.kullanici_analizleri(con, k["id"], limit=5)
    return jsonify(
        kullanici=_kullanici_json(k),
        oturum_bitis=k["oturum_bitis"] + " UTC",
        son_analizler=[
            {"tarih": a["analiz_tarihi"], "skor": a["guc_skoru"], "seviye": a["guc_seviyesi"],
             "sizinti_sayisi": a["sizinti_sayisi"]}
            for a in analizler
        ],
        en_iyi_quiz_puani=quiz_repo.en_iyi_puan(con, k["id"]),
    )


# ------------------------------------------------------------------ yalnızca yönetici

@bp.get("/yonetici/kullanicilar")
@rol_gerekli("yonetici")
def kullanicilari_listele():
    return jsonify([
        {**_kullanici_json(k), "kayit_tarihi": k["kayit_tarihi"]}
        for k in kullanici_repo.listele(get_db())
    ])


@bp.patch("/yonetici/kullanicilar/<int:kullanici_id>/rol")
@rol_gerekli("yonetici")
def rol_guncelle(kullanici_id):
    if kullanici_id == g.kullanici["id"]:
        raise KimlikHatasi("Kendi rolünüzü değiştiremezsiniz.", durum=400)
    veri = request.get_json(silent=True) or {}
    kullanici = kimlik_servisi.rol_degistir(get_db(), kullanici_id, veri.get("rol"))
    return jsonify(_kullanici_json(kullanici))
