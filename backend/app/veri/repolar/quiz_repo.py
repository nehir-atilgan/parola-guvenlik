"""quiz_sonucu tablosu için CRUD."""


def olustur(con, kullanici_id, dogru_sayisi, soru_sayisi):
    puan = round(dogru_sayisi * 100 / soru_sayisi) if soru_sayisi else 0
    imlec = con.execute(
        "INSERT INTO quiz_sonucu (kullanici_id, dogru_sayisi, soru_sayisi, puan) VALUES (?, ?, ?, ?)",
        (kullanici_id, dogru_sayisi, soru_sayisi, puan),
    )
    con.commit()
    return imlec.lastrowid


def kullanici_sonuclari(con, kullanici_id):
    return con.execute(
        "SELECT * FROM quiz_sonucu WHERE kullanici_id = ? ORDER BY tamamlanma_tarihi DESC, id DESC",
        (kullanici_id,),
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
