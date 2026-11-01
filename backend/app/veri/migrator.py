"""Basit migration çalıştırıcısı.

- migrations/ klasöründeki NNN_ad.sql dosyalarını numara sırasıyla uygular.
- Hangi dosyaların uygulandığını `schema_surumu` tablosunda tutar.
- Daha önce uygulanmış bir dosyayı tekrar çalıştırmaz (idempotent).

Şemayı değiştirmek gerektiğinde eski dosya DÜZENLENMEZ; yeni bir dosya eklenir
(ör. 003_kullaniciya_rol_ekle.sql). Böylece her bilgisayardaki veritabanı aynı adımlardan geçer.
"""
import os
import re

MIGRATION_KLASORU = os.path.join(os.path.dirname(__file__), "migrations")
DOSYA_DESENI = re.compile(r"^(\d{3})_.+\.sql$")


def _surum_tablosu(con):
    con.execute(
        """CREATE TABLE IF NOT EXISTS schema_surumu (
               surum            INTEGER PRIMARY KEY,
               dosya            TEXT NOT NULL,
               uygulanma_tarihi TEXT NOT NULL DEFAULT (datetime('now'))
           )"""
    )


def bekleyenler(con):
    _surum_tablosu(con)
    uygulanan = {r[0] for r in con.execute("SELECT surum FROM schema_surumu")}
    dosyalar = []
    for ad in sorted(os.listdir(MIGRATION_KLASORU)):
        eslesme = DOSYA_DESENI.match(ad)
        if eslesme and int(eslesme.group(1)) not in uygulanan:
            dosyalar.append((int(eslesme.group(1)), ad))
    return dosyalar


def uygula(con):
    """Bekleyen tüm migration'ları uygular, uygulanan dosya adlarını döndürür."""
    uygulananlar = []
    for surum, ad in bekleyenler(con):
        with open(os.path.join(MIGRATION_KLASORU, ad), encoding="utf-8") as f:
            sql = f.read()
        try:
            # Her migration tek bir işlem (transaction) içinde: ya tamamı uygulanır ya hiçbiri.
            con.executescript("BEGIN;\n" + sql + "\nINSERT INTO schema_surumu (surum, dosya) "
                              f"VALUES ({surum}, '{ad}');\nCOMMIT;")
        except Exception:
            if con.in_transaction:
                con.rollback()  # yarım kalan migration geri alınır
            raise
        uygulananlar.append(ad)
    return uygulananlar
