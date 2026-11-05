"""analiz_kaydi ve analiz_oneri tabloları için CRUD."""


def olustur(con, kullanici_id, uzunluk, guc_skoru, guc_seviyesi,
            buyuk_harf=False, kucuk_harf=False, rakam=False, ozel_karakter=False, sizinti_sayisi=0):
    """CREATE — analiz kaydı ekler. (Parolanın kendisi bu fonksiyona hiç gelmez.)"""
    imlec = con.execute(
        """INSERT INTO analiz_kaydi
               (kullanici_id, uzunluk, guc_skoru, guc_seviyesi,
                buyuk_harf, kucuk_harf, rakam, ozel_karakter, sizinti_sayisi)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        (kullanici_id, uzunluk, guc_skoru, guc_seviyesi,
         int(buyuk_harf), int(kucuk_harf), int(rakam), int(ozel_karakter), sizinti_sayisi),
    )
    con.commit()
    return imlec.lastrowid


def onerileriyle_kaydet(con, kullanici_id, olcum, oneri_kodlari):
    """CREATE — analiz kaydını ve önerilerini TEK İŞLEMDE (transaction) kaydeder.
    Öneri eklenirken hata olursa analiz de kaydedilmez; yarım kayıt kalmaz."""
    with con:  # hata olursa otomatik ROLLBACK, başarılıysa COMMIT
        imlec = con.execute(
            """INSERT INTO analiz_kaydi
                   (kullanici_id, uzunluk, guc_skoru, guc_seviyesi, buyuk_harf, kucuk_harf,
                    rakam, ozel_karakter, sizinti_sayisi, entropi_bit)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (kullanici_id, olcum["uzunluk"], olcum["guc_skoru"], olcum["guc_seviyesi"],
             int(olcum["buyuk_harf"]), int(olcum["kucuk_harf"]), int(olcum["rakam"]),
             int(olcum["ozel_karakter"]), olcum.get("sizinti_sayisi", 0), olcum.get("entropi_bit", 0)),
        )
        analiz_id = imlec.lastrowid
        for oncelik, kod in enumerate(oneri_kodlari, start=1):
            con.execute(
                """INSERT INTO analiz_oneri (analiz_id, oneri_id, oncelik)
                   SELECT ?, id, ? FROM oneri WHERE kod = ?""",
                (analiz_id, oncelik, kod),
            )
    return analiz_id


def kullaniciya_ait_getir(con, analiz_id, kullanici_id):
    """READ — yalnızca kaydın sahibi ise döndürür (sahiplik kontrolü SQL'in içinde)."""
    return con.execute(
        "SELECT * FROM analiz_kaydi WHERE id = ? AND kullanici_id = ?", (analiz_id, kullanici_id)
    ).fetchone()


def getir(con, analiz_id):
    """READ — tek analiz kaydı."""
    return con.execute("SELECT * FROM analiz_kaydi WHERE id = ?", (analiz_id,)).fetchone()


def kullanici_analizleri(con, kullanici_id, limit=20):
    """READ — kullanıcının analizleri, en yeni önce (ix_analiz_kullanici_tarih indeksini kullanır)."""
    return con.execute(
        """SELECT * FROM analiz_kaydi
           WHERE kullanici_id = ?
           ORDER BY analiz_tarihi DESC, id DESC
           LIMIT ?""",
        (kullanici_id, limit),
    ).fetchall()


def sizinti_guncelle(con, analiz_id, sizinti_sayisi):
    """UPDATE — sızıntı kontrolü sonradan tamamlandığında sonucu yazar."""
    imlec = con.execute(
        "UPDATE analiz_kaydi SET sizinti_sayisi = ? WHERE id = ?", (sizinti_sayisi, analiz_id)
    )
    con.commit()
    return imlec.rowcount


def sil(con, analiz_id):
    """DELETE — analizi siler; bağlı analiz_oneri satırları CASCADE ile silinir."""
    imlec = con.execute("DELETE FROM analiz_kaydi WHERE id = ?", (analiz_id,))
    con.commit()
    return imlec.rowcount


# ---------------------------------------------------------------- N-N ilişki

def oneri_ekle(con, analiz_id, oneri_id, oncelik=1, kisisel_not=None):
    """CREATE — analize öneri bağlar (ara tabloya satır ekler)."""
    con.execute(
        "INSERT INTO analiz_oneri (analiz_id, oneri_id, oncelik, kisisel_not) VALUES (?, ?, ?, ?)",
        (analiz_id, oneri_id, oncelik, kisisel_not),
    )
    con.commit()


def analiz_onerileri(con, analiz_id):
    """READ — bir analize verilen öneriler, öncelik sırasıyla (JOIN örneği)."""
    return con.execute(
        """SELECT o.kod, o.baslik, o.aciklama, o.kategori, ao.oncelik, ao.kisisel_not
           FROM analiz_oneri AS ao
           JOIN oneri AS o ON o.id = ao.oneri_id
           WHERE ao.analiz_id = ?
           ORDER BY ao.oncelik""",
        (analiz_id,),
    ).fetchall()
