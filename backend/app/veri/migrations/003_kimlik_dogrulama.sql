-- =====================================================================
-- Migration 003: Kimlik doğrulama ve rol tabanlı erişim
--  - kullanici tablosuna rol ve başarısız giriş (kilitleme) alanları
--  - oturum tablosu (sunucu tarafında tutulan, iptal edilebilir oturumlar)
-- Eski migration dosyaları değiştirilmedi; değişiklik yeni dosya olarak eklendi.
-- =====================================================================

ALTER TABLE kullanici ADD COLUMN rol TEXT NOT NULL DEFAULT 'kullanici'
    CHECK (rol IN ('kullanici', 'yonetici'));

-- Art arda hatalı girişleri sayar; sınır aşılınca hesap geçici olarak kilitlenir.
ALTER TABLE kullanici ADD COLUMN basarisiz_giris INTEGER NOT NULL DEFAULT 0
    CHECK (basarisiz_giris >= 0);
ALTER TABLE kullanici ADD COLUMN kilit_bitis TEXT;          -- NULL = kilitli değil

-- ---------------------------------------------------------------------
-- OTURUM  (Kullanıcı 1 — N Oturum)
-- Token'ın kendisi değil, SHA-256 özeti saklanır: veritabanı sızsa bile
-- buradaki değerlerle kimse oturum açamaz.
-- ---------------------------------------------------------------------
CREATE TABLE oturum (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    kullanici_id    INTEGER NOT NULL REFERENCES kullanici(id) ON DELETE CASCADE,
    token_ozeti     TEXT    NOT NULL UNIQUE,
    olusturma       TEXT    NOT NULL DEFAULT (datetime('now')),
    bitis           TEXT    NOT NULL,                        -- bu andan sonra geçersiz
    iptal_edildi    INTEGER NOT NULL DEFAULT 0 CHECK (iptal_edildi IN (0, 1))
);

CREATE INDEX ix_oturum_kullanici ON oturum (kullanici_id);
