"""rehber_konu tablosu için okuma fonksiyonları (içerik migration 006 ile yüklenir)."""


def listele(con):
    """Tüm konular, sırasıyla; her konunun soru bankasındaki aktif soru sayısıyla birlikte."""
    return con.execute(
        """SELECT k.id, k.slug, k.baslik, k.ozet, k.sira,
                  (SELECT COUNT(*) FROM quiz_soru s WHERE s.konu_id = k.id AND s.aktif = 1) AS soru_sayisi
           FROM rehber_konu AS k
           ORDER BY k.sira"""
    ).fetchall()


def slug_ile_getir(con, slug):
    return con.execute("SELECT * FROM rehber_konu WHERE slug = ?", (slug,)).fetchone()


def komsular(con, sira):
    """Bir önceki ve bir sonraki konu (sayfa altındaki gezinme için)."""
    onceki = con.execute(
        "SELECT slug, baslik FROM rehber_konu WHERE sira < ? ORDER BY sira DESC LIMIT 1", (sira,)
    ).fetchone()
    sonraki = con.execute(
        "SELECT slug, baslik FROM rehber_konu WHERE sira > ? ORDER BY sira LIMIT 1", (sira,)
    ).fetchone()
    return onceki, sonraki


def konuya_bagli_oneriler(con, konu_id):
    """Bu konuya bağlı öneriler (analiz modülündeki öneri kataloğu)."""
    return con.execute(
        "SELECT kod, baslik FROM oneri WHERE rehber_konu_id = ? ORDER BY id", (konu_id,)
    ).fetchall()
