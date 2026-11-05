"""Quiz tabloları için veri erişimi: soru bankası, denemeler ve sonuçlar."""


def puan_hesapla(dogru_sayisi, soru_sayisi):
    """0-100 arası puan, yarım puanlar yukarı yuvarlanır (Python'un round() fonksiyonu
    0.5'i en yakın çift sayıya yuvarlar: round(12.5) == 12; burada 13 olmalı)."""
    if soru_sayisi <= 0:
        return 0
    return (dogru_sayisi * 200 + soru_sayisi) // (2 * soru_sayisi)


# ------------------------------------------------------------------ sonuçlar

def olustur(con, kullanici_id, dogru_sayisi, soru_sayisi):
    """CREATE: doğrudan sonuç kaydı (örnek veri için). Gerçek quiz akışı deneme_tamamla() kullanır."""
    imlec = con.execute(
        "INSERT INTO quiz_sonucu (kullanici_id, dogru_sayisi, soru_sayisi, puan) VALUES (?, ?, ?, ?)",
        (kullanici_id, dogru_sayisi, soru_sayisi, puan_hesapla(dogru_sayisi, soru_sayisi)),
    )
    con.commit()
    return imlec.lastrowid


def kullanici_sonuclari(con, kullanici_id, limit=50):
    """READ: kullanıcının sonuçları, en yeni önce; sonucu üreten deneme varsa id'siyle."""
    return con.execute(
        """SELECT s.*, d.id AS deneme_id
           FROM quiz_sonucu AS s
           LEFT JOIN quiz_deneme AS d ON d.sonuc_id = s.id
           WHERE s.kullanici_id = ?
           ORDER BY s.tamamlanma_tarihi DESC, s.id DESC
           LIMIT ?""",
        (kullanici_id, limit),
    ).fetchall()


def en_iyi_puan(con, kullanici_id):
    satir = con.execute(
        "SELECT MAX(puan) AS en_iyi FROM quiz_sonucu WHERE kullanici_id = ?", (kullanici_id,)
    ).fetchone()
    return satir["en_iyi"]


def sil(con, sonuc_id):
    imlec = con.execute("DELETE FROM quiz_sonucu WHERE id = ?", (sonuc_id,))
    con.commit()
    return imlec.rowcount


# ------------------------------------------------------------------ soru bankası

def aktif_sorular(con):
    return con.execute("SELECT id, konu_id FROM quiz_soru WHERE aktif = 1 ORDER BY id").fetchall()


def secenekler(con, soru_idleri):
    """Verilen soruların seçenekleri (dogru bilgisi dahil; tarayıcıya gönderilmeden önce çıkarılır)."""
    if not soru_idleri:
        return []
    yer = ",".join("?" * len(soru_idleri))  # yalnızca '?' üretilir; değerler parametre olarak gider
    return con.execute(
        f"SELECT id, soru_id, metin, dogru FROM quiz_secenek WHERE soru_id IN ({yer}) ORDER BY id",
        tuple(soru_idleri),
    ).fetchall()


# ------------------------------------------------------------------ denemeler

def acik_deneme(con, kullanici_id):
    """Kullanıcının süresi dolmamış ve gönderilmemiş denemesi (yoksa None)."""
    return con.execute(
        """SELECT * FROM quiz_deneme
           WHERE kullanici_id = ? AND sonuc_id IS NULL AND son_teslim > datetime('now')
           ORDER BY id DESC LIMIT 1""",
        (kullanici_id,),
    ).fetchone()


def deneme_olustur(con, kullanici_id, soru_idleri, sure_dakika):
    """CREATE: deneme + seçilen sorular tek işlemde (ya hepsi yazılır ya hiçbiri)."""
    try:
        imlec = con.execute(
            "INSERT INTO quiz_deneme (kullanici_id, son_teslim) VALUES (?, datetime('now', ?))",
            (kullanici_id, f"+{int(sure_dakika)} minutes"),
        )
        deneme_id = imlec.lastrowid
        con.executemany(
            "INSERT INTO quiz_deneme_soru (deneme_id, soru_id, sira) VALUES (?, ?, ?)",
            [(deneme_id, soru_id, sira) for sira, soru_id in enumerate(soru_idleri, start=1)],
        )
        con.commit()
    except Exception:
        con.rollback()
        raise
    return deneme_id


def kullaniciya_ait_deneme(con, deneme_id, kullanici_id):
    """Sahiplik kontrolü SQL'in içinde: başkasının denemesi hiç dönmez."""
    return con.execute(
        """SELECT d.*, datetime('now') >= d.son_teslim AS suresi_doldu
           FROM quiz_deneme AS d
           WHERE d.id = ? AND d.kullanici_id = ?""",
        (deneme_id, kullanici_id),
    ).fetchone()


def deneme_sorulari(con, deneme_id):
    """Denemedeki sorular, sıralarıyla; konu bilgisi ve (varsa) verilen cevapla."""
    return con.execute(
        """SELECT ds.sira, ds.soru_id, ds.secilen_secenek_id, ds.dogru_mu,
                  s.metin, s.aciklama, k.slug AS konu_slug, k.baslik AS konu_baslik
           FROM quiz_deneme_soru AS ds
           JOIN quiz_soru   AS s ON s.id = ds.soru_id
           JOIN rehber_konu AS k ON k.id = s.konu_id
           WHERE ds.deneme_id = ?
           ORDER BY ds.sira""",
        (deneme_id,),
    ).fetchall()


def deneme_tamamla(con, deneme_id, kullanici_id, cevaplar, dogru_sayisi, soru_sayisi):
    """Cevapları yazar, sonucu oluşturur ve denemeye bağlar; hepsi TEK işlemde.

    cevaplar: {soru_id: (secenek_id, dogru_mu)}
    `sonuc_id IS NULL` koşulu, aynı denemenin iki kez gönderilmesini veritabanı seviyesinde de engeller.
    """
    try:
        con.executemany(
            """UPDATE quiz_deneme_soru SET secilen_secenek_id = ?, dogru_mu = ?
               WHERE deneme_id = ? AND soru_id = ?""",
            [(secenek_id, int(dogru), deneme_id, soru_id) for soru_id, (secenek_id, dogru) in cevaplar.items()],
        )
        sonuc_id = con.execute(
            "INSERT INTO quiz_sonucu (kullanici_id, dogru_sayisi, soru_sayisi, puan) VALUES (?, ?, ?, ?)",
            (kullanici_id, dogru_sayisi, soru_sayisi, puan_hesapla(dogru_sayisi, soru_sayisi)),
        ).lastrowid
        guncellenen = con.execute(
            "UPDATE quiz_deneme SET sonuc_id = ? WHERE id = ? AND sonuc_id IS NULL",
            (sonuc_id, deneme_id),
        ).rowcount
        if guncellenen != 1:
            raise RuntimeError("Deneme zaten gönderilmiş.")
        con.commit()
    except Exception:
        con.rollback()
        raise
    return sonuc_id


def sonuc_getir(con, sonuc_id):
    return con.execute("SELECT * FROM quiz_sonucu WHERE id = ?", (sonuc_id,)).fetchone()
