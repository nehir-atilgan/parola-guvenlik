"""Sentetik (uydurma) örnek veri üretir.

KVKK uyumu:
- Gerçek kişi adı, gerçek e-posta veya gerçek parola KULLANILMAZ.
- Adlar "Test Kullanıcı N", e-postalar ayrılmış `.test` alan adındadır (gerçek posta alamaz).
- Analiz kayıtları gerçek parolalardan değil, rastgele üretilmiş ölçümlerden oluşur.
- Rastgelelik sabit tohumla (seed=42) üretilir: her çalıştırmada aynı veri oluşur.
"""
import random

from werkzeug.security import generate_password_hash

from app.veri.repolar import analiz_repo, kullanici_repo, oneri_repo, quiz_repo

KULLANICI_SAYISI = 8


def _seviye(skor):
    return "zayif" if skor < 40 else "orta" if skor < 70 else "guclu"


def _uygun_oneriler(analiz):
    """Analiz ölçümlerine göre hangi önerilerin verileceği (basit kurallar)."""
    kodlar = []
    if analiz["sizinti_sayisi"] > 0:
        kodlar.append("SIZINTI_DEGISTIR")
    if analiz["uzunluk"] < 12:
        kodlar.append("UZUNLUK_ARTIR")
    if not analiz["buyuk_harf"]:
        kodlar.append("BUYUK_HARF_EKLE")
    if not analiz["rakam"]:
        kodlar.append("RAKAM_EKLE")
    if not analiz["ozel_karakter"]:
        kodlar.append("OZEL_KARAKTER")
    kodlar.append("IKI_FAKTOR")
    return kodlar[:5]  # öncelik 1..5


def yukle(con, tohum=42):
    """Örnek veriyi yükler. Tablolarda zaten kullanıcı varsa hiçbir şey yapmaz."""
    if con.execute("SELECT COUNT(*) FROM kullanici").fetchone()[0] > 0:
        return {"durum": "atlandi", "neden": "veritabanında zaten kullanıcı var"}

    rnd = random.Random(tohum)
    oneri_idleri = {o["kod"]: o["id"] for o in oneri_repo.listele(con)}
    sayac = {"kullanici": 0, "analiz": 0, "analiz_oneri": 0, "quiz": 0}

    for n in range(1, KULLANICI_SAYISI + 1):
        kid = kullanici_repo.olustur(
            con,
            ad_soyad=f"Test Kullanıcı {n}",
            eposta=f"test{n}@ornek.test",
            sifre_hash=generate_password_hash(f"OrnekGiris-{n}-{rnd.random()}"),
        )
        sayac["kullanici"] += 1

        for _ in range(rnd.randint(1, 4)):
            uzunluk = rnd.randint(5, 20)
            ozellik = {k: rnd.random() < 0.6 for k in ("buyuk_harf", "kucuk_harf", "rakam", "ozel_karakter")}
            skor = min(100, uzunluk * 4 + 8 * sum(ozellik.values()))
            sizinti = rnd.choice([0, 0, 0, rnd.randint(1, 250000)]) if skor < 60 else 0
            aid = analiz_repo.olustur(
                con, kid, uzunluk, skor, _seviye(skor), sizinti_sayisi=sizinti, **ozellik
            )
            sayac["analiz"] += 1

            analiz = analiz_repo.getir(con, aid)
            for oncelik, kod in enumerate(_uygun_oneriler(analiz), start=1):
                analiz_repo.oneri_ekle(con, aid, oneri_idleri[kod], oncelik)
                sayac["analiz_oneri"] += 1

        for _ in range(rnd.randint(0, 2)):
            soru = 10
            quiz_repo.olustur(con, kid, rnd.randint(3, soru), soru)
            sayac["quiz"] += 1

    return {"durum": "yuklendi", **sayac}
