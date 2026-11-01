"""kullanici tablosu için CRUD."""


def olustur(con, ad_soyad, eposta, sifre_hash):
    """CREATE — yeni kullanıcı ekler, oluşan id'yi döndürür."""
    imlec = con.execute(
        "INSERT INTO kullanici (ad_soyad, eposta, sifre_hash) VALUES (?, ?, ?)",
        (ad_soyad, eposta.strip().lower(), sifre_hash),
    )
    con.commit()
    return imlec.lastrowid


def getir(con, kullanici_id):
    """READ — tek kullanıcı (bulunamazsa None)."""
    return con.execute(
        "SELECT id, ad_soyad, eposta, kayit_tarihi FROM kullanici WHERE id = ?",
        (kullanici_id,),
    ).fetchone()


def eposta_ile_getir(con, eposta):
    """READ — giriş için e-postaya göre kullanıcı (sifre_hash dahil)."""
    return con.execute(
        "SELECT * FROM kullanici WHERE eposta = ?", (eposta.strip().lower(),)
    ).fetchone()


def listele(con):
    """READ — tüm kullanıcılar."""
    return con.execute(
        "SELECT id, ad_soyad, eposta, kayit_tarihi FROM kullanici ORDER BY id"
    ).fetchall()


def guncelle(con, kullanici_id, ad_soyad=None, eposta=None):
    """UPDATE — yalnızca verilen alanları değiştirir. Etkilenen satır sayısını döndürür."""
    alanlar, degerler = [], []
    if ad_soyad is not None:
        alanlar.append("ad_soyad = ?")
        degerler.append(ad_soyad)
    if eposta is not None:
        alanlar.append("eposta = ?")
        degerler.append(eposta.strip().lower())
    if not alanlar:
        return 0
    # Sütun adları sabit listeden gelir; kullanıcı girdisi yalnızca ? ile verilir.
    imlec = con.execute(
        f"UPDATE kullanici SET {', '.join(alanlar)} WHERE id = ?", (*degerler, kullanici_id)
    )
    con.commit()
    return imlec.rowcount


def sil(con, kullanici_id):
    """DELETE — kullanıcıyı siler. ON DELETE CASCADE ile analizleri ve quiz sonuçları da silinir."""
    imlec = con.execute("DELETE FROM kullanici WHERE id = ?", (kullanici_id,))
    con.commit()
    return imlec.rowcount
