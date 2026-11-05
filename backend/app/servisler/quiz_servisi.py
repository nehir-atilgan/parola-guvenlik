"""Farkındalık Quizi iş kuralları (Hafta 7).

Kurallar
--------
1. Quiz için giriş gerekir (sonuç kullanıcıya kaydedilir).
2. Her denemede 10 soru seçilir: önce her rehber konusundan 1 soru, kalanlar rastgele.
   Böylece her quiz tüm konuları kapsar.
3. Soruları ve seçenek sırasını SUNUCU belirler. Doğru cevaplar tarayıcıya ancak
   cevaplar gönderildikten sonra gider (sayfanın kodu incelenerek kopya çekilemez).
4. Bir kullanıcının aynı anda yalnızca bir açık denemesi olur; yeniden "başlat"
   denirse yeni deneme açılmaz, mevcut deneme kaldığı yerden döner.
5. Deneme 30 dakika içinde gönderilmelidir; süre dolunca cevap kabul edilmez.
6. Gönderilen cevaplar doğrulanır: tüm sorular cevaplanmış olmalı, her seçenek kendi
   sorusuna ait olmalı, denemede olmayan soru gönderilemez, deneme iki kez gönderilemez.
7. Puan = doğru sayısı / soru sayısı × 100 (yarım puan yukarı yuvarlanır).
"""
import random

from app.veri.repolar import quiz_repo

SORU_SAYISI = 10
SURE_DAKIKA = 30

DEGERLENDIRME = (  # (en düşük puan, mesaj)
    (90, "Mükemmel! Parola güvenliği konusunda çok bilinçlisiniz."),
    (70, "İyi! Birkaç konuyu tekrar gözden geçirmeniz yeterli."),
    (50, "Fena değil. Yanlış yaptığınız konuları rehberden okuyun."),
    (0, "Rehberi baştan okumanızı öneririz; ardından quizi tekrar deneyin."),
)


class QuizHatasi(Exception):
    def __init__(self, mesaj, durum=400):
        super().__init__(mesaj)
        self.mesaj = mesaj
        self.durum = durum


def degerlendirme(puan):
    return next(mesaj for alt, mesaj in DEGERLENDIRME if puan >= alt)


def soru_sec(sorular, adet=SORU_SAYISI, rnd=None):
    """Her konudan önce bir soru, sonra kalanlardan rastgele; sonuç karıştırılır.

    sorular: [(soru_id, konu_id), ...]
    """
    rnd = rnd or random.SystemRandom()
    konulara_gore = {}
    for soru_id, konu_id in sorular:
        konulara_gore.setdefault(konu_id, []).append(soru_id)

    secilen = []
    konular = list(konulara_gore)
    rnd.shuffle(konular)
    for konu_id in konular[:adet]:
        secilen.append(rnd.choice(konulara_gore[konu_id]))

    kalan = [s for s, _ in sorular if s not in secilen]
    secilen += rnd.sample(kalan, min(adet - len(secilen), len(kalan)))
    rnd.shuffle(secilen)
    return secilen


def _deneme_json(con, deneme):
    """Açık deneme: sorular ve seçenekler, DOĞRU BİLGİSİ OLMADAN."""
    sorular = quiz_repo.deneme_sorulari(con, deneme["id"])
    secenekler = {}
    for s in quiz_repo.secenekler(con, [r["soru_id"] for r in sorular]):
        secenekler.setdefault(s["soru_id"], []).append({"id": s["id"], "metin": s["metin"]})
    for soru_id, liste in secenekler.items():
        # Seçenek sırası denemeye özgü ama sabit: sayfa yenilense de aynı sırada görünür.
        random.Random(deneme["id"] * 100_000 + soru_id).shuffle(liste)
    return {
        "deneme_id": deneme["id"],
        "durum": "devam",
        "baslangic": deneme["baslangic"],
        "son_teslim": deneme["son_teslim"],
        "sorular": [
            {"soru_id": r["soru_id"], "sira": r["sira"], "metin": r["metin"], "secenekler": secenekler[r["soru_id"]]}
            for r in sorular
        ],
    }


def baslat(con, kullanici_id, rnd=None):
    acik = quiz_repo.acik_deneme(con, kullanici_id)
    if acik is not None:
        return {**_deneme_json(con, acik), "kaldigi_yerden": True}

    soru_idleri = soru_sec([(r["id"], r["konu_id"]) for r in quiz_repo.aktif_sorular(con)], rnd=rnd)
    if len(soru_idleri) < SORU_SAYISI:
        raise QuizHatasi("Soru bankasında yeterli soru yok.", durum=500)
    deneme_id = quiz_repo.deneme_olustur(con, kullanici_id, soru_idleri, SURE_DAKIKA)
    deneme = quiz_repo.kullaniciya_ait_deneme(con, deneme_id, kullanici_id)
    return {**_deneme_json(con, deneme), "kaldigi_yerden": False}


def _deneme_getir(con, kullanici_id, deneme_id):
    deneme = quiz_repo.kullaniciya_ait_deneme(con, deneme_id, kullanici_id)
    if deneme is None:
        # Başkasının denemesi için de 404: denemenin var olduğu bile açığa çıkmaz.
        raise QuizHatasi("Quiz bulunamadı.", durum=404)
    return deneme


def _cevaplari_dogrula(cevaplar, sorular, secenekler):
    """İstekten gelen {soru_id: secenek_id} sözlüğünü doğrular, temiz sözlük döndürür."""
    if not isinstance(cevaplar, dict):
        raise QuizHatasi("Cevaplar {soru_id: secenek_id} biçiminde gönderilmelidir.")

    temiz = {}
    for anahtar, deger in cevaplar.items():
        try:
            soru_id, secenek_id = int(anahtar), int(deger)
        except (TypeError, ValueError):
            raise QuizHatasi("Cevaplar sayı olmalıdır.")
        if isinstance(deger, bool):
            raise QuizHatasi("Cevaplar sayı olmalıdır.")
        temiz[soru_id] = secenek_id

    deneme_sorulari = {r["soru_id"] for r in sorular}
    if set(temiz) - deneme_sorulari:
        raise QuizHatasi("Bu quizde olmayan bir soru için cevap gönderildi.")
    eksik = deneme_sorulari - set(temiz)
    if eksik:
        raise QuizHatasi(f"{len(eksik)} soru cevaplanmadı. Göndermeden önce tüm soruları cevaplayın.")

    secenek_sorusu = {s["id"]: s["soru_id"] for s in secenekler}
    for soru_id, secenek_id in temiz.items():
        if secenek_sorusu.get(secenek_id) != soru_id:
            raise QuizHatasi("Seçilen cevaplardan biri ilgili soruya ait değil.")
    return temiz


def gonder(con, kullanici_id, deneme_id, cevaplar):
    deneme = _deneme_getir(con, kullanici_id, deneme_id)
    if deneme["sonuc_id"] is not None:
        raise QuizHatasi("Bu quiz zaten gönderildi.", durum=409)
    if deneme["suresi_doldu"]:
        raise QuizHatasi(f"Süre doldu ({SURE_DAKIKA} dakika). Yeni bir quiz başlatabilirsiniz.", durum=410)

    sorular = quiz_repo.deneme_sorulari(con, deneme_id)
    secenekler = quiz_repo.secenekler(con, [r["soru_id"] for r in sorular])
    temiz = _cevaplari_dogrula(cevaplar, sorular, secenekler)

    dogru_secenek = {s["soru_id"]: s["id"] for s in secenekler if s["dogru"]}
    degerlendirilmis = {soru_id: (sec, sec == dogru_secenek[soru_id]) for soru_id, sec in temiz.items()}
    dogru_sayisi = sum(1 for _, dogru in degerlendirilmis.values() if dogru)

    try:
        quiz_repo.deneme_tamamla(con, deneme_id, kullanici_id, degerlendirilmis, dogru_sayisi, len(sorular))
    except RuntimeError:
        raise QuizHatasi("Bu quiz zaten gönderildi.", durum=409)
    return sonuc(con, kullanici_id, deneme_id)


def sonuc(con, kullanici_id, deneme_id):
    """Gönderilmiş denemenin sonucu ve soru soru geri bildirimi; açık deneme ise soruları."""
    deneme = _deneme_getir(con, kullanici_id, deneme_id)
    if deneme["sonuc_id"] is None:
        if deneme["suresi_doldu"]:
            raise QuizHatasi(f"Süre doldu ({SURE_DAKIKA} dakika). Yeni bir quiz başlatabilirsiniz.", durum=410)
        return _deneme_json(con, deneme)

    kayit = quiz_repo.sonuc_getir(con, deneme["sonuc_id"])
    sorular = quiz_repo.deneme_sorulari(con, deneme_id)
    secenek = {s["id"]: s for s in quiz_repo.secenekler(con, [r["soru_id"] for r in sorular])}
    dogru = {s["soru_id"]: s for s in secenek.values() if s["dogru"]}

    geri_bildirim, tekrar = [], {}
    for r in sorular:
        if not r["dogru_mu"]:
            tekrar[r["konu_slug"]] = r["konu_baslik"]
        geri_bildirim.append({
            "sira": r["sira"],
            "soru": r["metin"],
            "verilen": secenek[r["secilen_secenek_id"]]["metin"],
            "dogru_cevap": dogru[r["soru_id"]]["metin"],
            "dogru_mu": bool(r["dogru_mu"]),
            "aciklama": r["aciklama"],
            "konu": {"slug": r["konu_slug"], "baslik": r["konu_baslik"]},
        })

    return {
        "deneme_id": deneme_id,
        "durum": "tamamlandi",
        "tarih": kayit["tamamlanma_tarihi"],
        "dogru_sayisi": kayit["dogru_sayisi"],
        "soru_sayisi": kayit["soru_sayisi"],
        "puan": kayit["puan"],
        "degerlendirme": degerlendirme(kayit["puan"]),
        "tekrar_okunacak_konular": [{"slug": s, "baslik": b} for s, b in tekrar.items()],
        "sorular": geri_bildirim,
    }
