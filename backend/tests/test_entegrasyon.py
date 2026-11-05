"""Uçtan uca entegrasyon testi (Hafta 8 — ara sürüm v0.8.0).

Tek bir kullanıcının siteye girişten çıkışa kadar tüm modülleri sırayla kullandığı senaryo:
kayıt → giriş → parola analizi (kaydet) → öneriden rehbere geçiş → quiz → panel → temizlik → çıkış.
Her adım bir önceki adımın ürettiği veriyi kullanır; modüller arasındaki bağlar böylece test edilir.
"""
from app.veri.repolar import quiz_repo


def _bearer(token):
    return {"Authorization": f"Bearer {token}"}


def test_uctan_uca_kullanici_senaryosu(istemci, con):
    # 1) Kayıt ve giriş (Hafta 5)
    assert istemci.post("/api/kayit", json={
        "ad_soyad": "Elif Demir", "eposta": "elif@ornek.test", "parola": "GucluParola1"}).status_code == 201
    token = istemci.post("/api/giris", json={"eposta": "elif@ornek.test", "parola": "GucluParola1"}).get_json()["token"]
    h = _bearer(token)

    # 2) Parola analizi + kaydetme (Hafta 6) — kişisel bilgi kuralı oturumdaki kullanıcıyı kullanır
    analiz = istemci.post("/api/analiz", headers=h, json={"parola": "elif1990", "kaydet": True})
    assert analiz.status_code == 201
    sonuc = analiz.get_json()
    assert sonuc["guc_seviyesi"] == "zayif" and "kisisel_bilgi" in sonuc["bulgular"]
    assert "elif1990" not in analiz.get_data(as_text=True)  # parola yanıta geri dönmez

    # 3) Öneriden rehber konusuna geçiş (Hafta 6 → Hafta 7 entegrasyonu)
    slug = sonuc["oneriler"][0]["rehber_slug"]
    konu = istemci.get(f"/api/rehber/{slug}")
    assert konu.status_code == 200 and konu.get_json()["paragraflar"]

    # 4) Quiz: başlat → tümü doğru cevapla → sonuç (Hafta 7)
    deneme = istemci.post("/api/quiz/baslat", headers=h).get_json()
    idler = [s["soru_id"] for s in deneme["sorular"]]
    dogru = {str(s["soru_id"]): s["id"] for s in quiz_repo.secenekler(con, idler) if s["dogru"]}
    quiz = istemci.post(f"/api/quiz/{deneme['deneme_id']}/gonder", headers=h, json={"cevaplar": dogru}).get_json()
    assert quiz["puan"] == 100

    # 5) Panel tüm modüllerin verisini bir arada gösterir (Hafta 4 veri katmanı + 5 + 6 + 7)
    panel = istemci.get("/api/ben", headers=h).get_json()
    assert panel["kullanici"]["eposta"] == "elif@ornek.test"
    assert panel["son_analizler"][0]["skor"] == sonuc["guc_skoru"]
    assert panel["en_iyi_quiz_puani"] == 100

    # 6) Kendi analizini silme; bağlı öneriler de silinir (ilişkili kayıt yönetimi)
    analiz_id = sonuc["analiz_id"]
    assert istemci.delete(f"/api/analizler/{analiz_id}", headers=h).status_code == 200
    assert con.execute("SELECT COUNT(*) FROM analiz_oneri WHERE analiz_id = ?", (analiz_id,)).fetchone()[0] == 0

    # 7) Çıkış: token artık hiçbir korumalı uçta çalışmaz
    assert istemci.post("/api/cikis", headers=h).status_code == 200
    for yontem, yol in [("get", "/api/ben"), ("get", "/api/analizler"), ("post", "/api/quiz/baslat")]:
        assert getattr(istemci, yontem)(yol, headers=h).status_code == 401


def test_frontend_ayni_adresten_sunulur(istemci):
    """Canlı sürümde tek adres: / → index.html, *.html ve js/css dosyaları, /api → API."""
    ana = istemci.get("/")
    assert ana.status_code == 200 and "<title>Parola Güvenliği</title>" in ana.get_data(as_text=True)
    for yol in ("/quiz.html", "/rehber.html", "/js/config.js", "/css/stil.css"):
        assert istemci.get(yol).status_code == 200, yol
    assert istemci.get("/api/saglik").get_json()["surum"] == "0.8.0"


def test_frontend_klasoru_disina_cikilamaz(istemci):
    for yol in ("/../backend/run.py", "/..%2fbackend%2frun.py", "/%2e%2e/backend/app/config.py"):
        assert istemci.get(yol).status_code == 404, yol


def test_bilinmeyen_api_yolu_404(istemci):
    assert istemci.get("/api/yok-boyle-bir-yol").status_code == 404


def test_api_yanitlari_onbellege_alinmaz(istemci):
    yanit = istemci.get("/api/rehber")
    assert yanit.headers["Cache-Control"] == "no-store"
    assert yanit.headers["X-Content-Type-Options"] == "nosniff"


def test_ornek_veri_secenegi_demo_hesaplarini_olusturur(tmp_path):
    from app import create_app
    from app.config import TestConfig

    app = create_app(TestConfig, VERITABANI=str(tmp_path / "demo.db"), ORNEK_VERI=True)
    istemci = app.test_client()
    giris = istemci.post("/api/giris", json={"eposta": "yonetici@ornek.test", "parola": "Yonetici123"})
    assert giris.status_code == 200 and giris.get_json()["kullanici"]["rol"] == "yonetici"
    # Uygulama yeniden başlatılınca örnek veri ikinci kez yüklenmez
    create_app(TestConfig, VERITABANI=str(tmp_path / "demo.db"), ORNEK_VERI=True)
    assert app.test_client().get("/api/saglik").status_code == 200
