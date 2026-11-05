"""Sentetik (uydurma) örnek veri üretir.

KVKK uyumu:
- Gerçek kişi adı, gerçek e-posta veya gerçek parola KULLANILMAZ.
- Adlar "Test Kullanıcı N", e-postalar ayrılmış `.test` alan adındadır (gerçek posta alamaz).
- Analiz kayıtları gerçek parolalardan değil, rastgele üretilmiş ölçümlerden oluşur.
- Rastgelelik sabit tohumla (seed=42) üretilir: her çalıştırmada aynı veri oluşur.
"""
import random

from werkzeug.security import generate_password_hash

from app.servisler.parola_analiz import entropi_hesapla, oneri_kodlari_sec, seviye_belirle
from app.veri.repolar import analiz_repo, kullanici_repo, quiz_repo

KULLANICI_SAYISI = 8

# Arayüzü denemek için parolası bilinen iki DEMO hesabı (yalnızca yerel geliştirme içindir).
DEMO_HESAPLARI = [
    {"ad_soyad": "Demo Yönetici", "eposta": "yonetici@ornek.test", "parola": "Yonetici123", "rol": "yonetici"},
    {"ad_soyad": "Demo Kullanıcı", "eposta": "kullanici@ornek.test", "parola": "Kullanici123", "rol": "kullanici"},
]


def yukle(con, tohum=42):
    """Örnek veriyi yükler. Tablolarda zaten kullanıcı varsa hiçbir şey yapmaz."""
    if con.execute("SELECT COUNT(*) FROM kullanici").fetchone()[0] > 0:
        return {"durum": "atlandi", "neden": "veritabanında zaten kullanıcı var"}

    rnd = random.Random(tohum)
    sayac = {"kullanici": 0, "analiz": 0, "analiz_oneri": 0, "quiz": 0}

    hesaplar = [
        (h["ad_soyad"], h["eposta"], h["parola"], h["rol"]) for h in DEMO_HESAPLARI
    ] + [
        (f"Test Kullanıcı {n}", f"test{n}@ornek.test", f"OrnekGiris-{n}-{rnd.random()}", "kullanici")
        for n in range(1, KULLANICI_SAYISI + 1)
    ]

    for ad_soyad, eposta, parola, rol in hesaplar:
        kid = kullanici_repo.olustur(con, ad_soyad, eposta, generate_password_hash(parola), rol)
        sayac["kullanici"] += 1

        for _ in range(rnd.randint(1, 4)):
            uzunluk = rnd.randint(5, 20)
            ozellik = {k: rnd.random() < 0.6 for k in ("buyuk_harf", "kucuk_harf", "rakam", "ozel_karakter")}
            skor = min(100, uzunluk * 4 + 8 * sum(ozellik.values()))
            sizinti = rnd.choice([0, 0, 0, rnd.randint(1, 250000)]) if skor < 60 else 0
            # Seviye, entropi ve öneriler gerçek analiz modülüyle aynı kurallarla belirlenir.
            olcum = {"uzunluk": uzunluk, "guc_skoru": skor, "guc_seviyesi": seviye_belirle(skor),
                     "sizinti_sayisi": sizinti, "entropi_bit": entropi_hesapla(uzunluk, ozellik), **ozellik}
            kodlar = oneri_kodlari_sec(olcum)
            analiz_repo.onerileriyle_kaydet(con, kid, olcum, kodlar)
            sayac["analiz"] += 1
            sayac["analiz_oneri"] += len(kodlar)

        for _ in range(rnd.randint(0, 2)):
            soru = 10
            quiz_repo.olustur(con, kid, rnd.randint(3, soru), soru)
            sayac["quiz"] += 1

    return {"durum": "yuklendi", **sayac}
