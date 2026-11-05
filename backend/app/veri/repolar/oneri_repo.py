"""oneri (katalog) tablosu için CRUD."""


def olustur(con, kod, baslik, aciklama, kategori):
    imlec = con.execute(
        "INSERT INTO oneri (kod, baslik, aciklama, kategori) VALUES (?, ?, ?, ?)",
        (kod, baslik, aciklama, kategori),
    )
    con.commit()
    return imlec.lastrowid


def listele(con, kategori=None):
    if kategori:
        return con.execute(
            "SELECT * FROM oneri WHERE kategori = ? ORDER BY id", (kategori,)
        ).fetchall()
    return con.execute("SELECT * FROM oneri ORDER BY id").fetchall()


def rehber_baglantili_liste(con):
    """Öneri kataloğu + her önerinin bağlı olduğu rehber konusunun slug'ı (LEFT JOIN: bağı olmayan da gelir)."""
    return con.execute(
        """SELECT o.*, k.slug AS rehber_slug
           FROM oneri AS o
           LEFT JOIN rehber_konu AS k ON k.id = o.rehber_konu_id
           ORDER BY o.id"""
    ).fetchall()


def kod_ile_getir(con, kod):
    return con.execute("SELECT * FROM oneri WHERE kod = ?", (kod,)).fetchone()


def guncelle(con, oneri_id, baslik, aciklama):
    imlec = con.execute(
        "UPDATE oneri SET baslik = ?, aciklama = ? WHERE id = ?", (baslik, aciklama, oneri_id)
    )
    con.commit()
    return imlec.rowcount


def sil(con, oneri_id):
    """Bir analizde kullanılan öneri silinemez (ON DELETE RESTRICT) → sqlite3.IntegrityError."""
    imlec = con.execute("DELETE FROM oneri WHERE id = ?", (oneri_id,))
    con.commit()
    return imlec.rowcount
