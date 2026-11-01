-- =====================================================================
-- Migration 001: İlk şema
-- ER diyagramındaki 5 tabloyu, ilişkileri, kısıtları ve indeksleri oluşturur.
-- Not: Analiz edilen parola veya hash'i HİÇBİR tabloda saklanmaz.
-- =====================================================================

-- ---------------------------------------------------------------------
-- KULLANICI
-- ---------------------------------------------------------------------
CREATE TABLE kullanici (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    ad_soyad      TEXT    NOT NULL CHECK (length(trim(ad_soyad)) >= 2),
    eposta        TEXT    NOT NULL UNIQUE CHECK (eposta LIKE '%_@_%._%'),
    sifre_hash    TEXT    NOT NULL,                     -- siteye giriş parolasının tuzlu hash'i
    kayit_tarihi  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- ---------------------------------------------------------------------
-- ANALİZ KAYDI  (Kullanıcı 1 — N Analiz Kaydı)
-- ---------------------------------------------------------------------
CREATE TABLE analiz_kaydi (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    kullanici_id    INTEGER NOT NULL
                    REFERENCES kullanici(id) ON DELETE CASCADE,  -- kullanıcı silinirse analizleri de silinir
    uzunluk         INTEGER NOT NULL CHECK (uzunluk >= 0),
    guc_skoru       INTEGER NOT NULL CHECK (guc_skoru BETWEEN 0 AND 100),
    guc_seviyesi    TEXT    NOT NULL CHECK (guc_seviyesi IN ('zayif', 'orta', 'guclu')),
    buyuk_harf      INTEGER NOT NULL DEFAULT 0 CHECK (buyuk_harf IN (0, 1)),
    kucuk_harf      INTEGER NOT NULL DEFAULT 0 CHECK (kucuk_harf IN (0, 1)),
    rakam           INTEGER NOT NULL DEFAULT 0 CHECK (rakam IN (0, 1)),
    ozel_karakter   INTEGER NOT NULL DEFAULT 0 CHECK (ozel_karakter IN (0, 1)),
    sizinti_sayisi  INTEGER NOT NULL DEFAULT 0 CHECK (sizinti_sayisi >= 0),
    analiz_tarihi   TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- "Bir kullanıcının analizlerini en yeniden eskiye listele" sorgusu çok sık çalışır.
CREATE INDEX ix_analiz_kullanici_tarih ON analiz_kaydi (kullanici_id, analiz_tarihi DESC);

-- ---------------------------------------------------------------------
-- ÖNERİ (katalog)
-- ---------------------------------------------------------------------
CREATE TABLE oneri (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    kod       TEXT NOT NULL UNIQUE,                     -- ör. UZUNLUK_ARTIR
    baslik    TEXT NOT NULL,
    aciklama  TEXT NOT NULL,
    kategori  TEXT NOT NULL CHECK (kategori IN ('uzunluk', 'cesitlilik', 'sizinti', 'tekrar', '2fa', 'genel'))
);

-- ---------------------------------------------------------------------
-- ANALİZ–ÖNERİ ara tablosu  (Analiz Kaydı N — N Öneri)
-- ---------------------------------------------------------------------
CREATE TABLE analiz_oneri (
    analiz_id    INTEGER NOT NULL REFERENCES analiz_kaydi(id) ON DELETE CASCADE,
    oneri_id     INTEGER NOT NULL REFERENCES oneri(id)        ON DELETE RESTRICT, -- kullanımdaki öneri silinemez
    oncelik      INTEGER NOT NULL DEFAULT 1 CHECK (oncelik BETWEEN 1 AND 5),
    kisisel_not  TEXT,                                  -- yapay zekâ ile üretilecek kişisel açıklama
    PRIMARY KEY (analiz_id, oneri_id)                   -- aynı öneri bir analize iki kez eklenemez
);

-- Bileşik anahtar analiz_id ile başladığı için "bu öneri hangi analizlerde?" sorgusuna ayrı indeks gerekir.
CREATE INDEX ix_analiz_oneri_oneri ON analiz_oneri (oneri_id);

-- ---------------------------------------------------------------------
-- QUIZ SONUCU  (Kullanıcı 1 — N Quiz Sonucu)
-- ---------------------------------------------------------------------
CREATE TABLE quiz_sonucu (
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    kullanici_id       INTEGER NOT NULL REFERENCES kullanici(id) ON DELETE CASCADE,
    dogru_sayisi       INTEGER NOT NULL CHECK (dogru_sayisi >= 0),
    soru_sayisi        INTEGER NOT NULL CHECK (soru_sayisi > 0),
    puan               INTEGER NOT NULL CHECK (puan BETWEEN 0 AND 100),
    tamamlanma_tarihi  TEXT    NOT NULL DEFAULT (datetime('now')),
    CHECK (dogru_sayisi <= soru_sayisi)                 -- tablo düzeyinde kısıt
);

CREATE INDEX ix_quiz_kullanici ON quiz_sonucu (kullanici_id);
