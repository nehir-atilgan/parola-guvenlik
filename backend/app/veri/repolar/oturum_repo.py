"""oturum tablosu için CRUD. Bu modül yalnızca token ÖZETİ ile çalışır."""


def olustur(con, kullanici_id, token_ozeti, sure_dakika):
    imlec = con.execute(
        """INSERT INTO oturum (kullanici_id, token_ozeti, bitis)
           VALUES (?, ?, datetime('now', ?))""",
        (kullanici_id, token_ozeti, f"+{int(sure_dakika)} minutes"),
    )
    con.commit()
    return imlec.lastrowid


def gecerli_oturum_kullanicisi(con, token_ozeti):
    """Süresi dolmamış ve iptal edilmemiş oturumun kullanıcısını döndürür (yoksa None)."""
    return con.execute(
        """SELECT k.id, k.ad_soyad, k.eposta, k.rol, o.bitis AS oturum_bitis
           FROM oturum AS o
           JOIN kullanici AS k ON k.id = o.kullanici_id
           WHERE o.token_ozeti = ?
             AND o.iptal_edildi = 0
             AND o.bitis > datetime('now')""",
        (token_ozeti,),
    ).fetchone()


def iptal_et(con, token_ozeti):
    """Çıkış: oturumu iptal eder. Token artık hiçbir istekte kabul edilmez."""
    imlec = con.execute("UPDATE oturum SET iptal_edildi = 1 WHERE token_ozeti = ?", (token_ozeti,))
    con.commit()
    return imlec.rowcount


def kullanici_oturumlarini_iptal_et(con, kullanici_id):
    """Rol değiştiğinde vb. kullanıcının tüm açık oturumlarını kapatır."""
    imlec = con.execute(
        "UPDATE oturum SET iptal_edildi = 1 WHERE kullanici_id = ? AND iptal_edildi = 0",
        (kullanici_id,),
    )
    con.commit()
    return imlec.rowcount


def eskileri_temizle(con):
    """Süresi dolmuş veya iptal edilmiş oturum kayıtlarını siler."""
    imlec = con.execute("DELETE FROM oturum WHERE iptal_edildi = 1 OR bitis <= datetime('now')")
    con.commit()
    return imlec.rowcount
