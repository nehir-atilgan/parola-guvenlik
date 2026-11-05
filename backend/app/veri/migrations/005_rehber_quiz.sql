-- =====================================================================
-- Migration 005: Farkındalık Rehberi ve Quiz (Hafta 7)
--
--   rehber_konu ──1─N── quiz_soru ──1─N── quiz_secenek
--        │
--        └──1─N── oneri (her öneri ilgili rehber konusuna bağlanır)
--
--   kullanici ──1─N── quiz_deneme ──1─N── quiz_deneme_soru ──N─1── quiz_soru
--                          │
--                          └──1─1── quiz_sonucu (deneme gönderilince oluşur)
-- =====================================================================

-- ---------------------------------------------------------------------
-- REHBER KONUSU
-- ---------------------------------------------------------------------
CREATE TABLE rehber_konu (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    slug              TEXT    NOT NULL UNIQUE CHECK (slug NOT GLOB '*[^a-z0-9-]*' AND length(slug) >= 3),
    baslik            TEXT    NOT NULL,
    ozet              TEXT    NOT NULL,
    icerik            TEXT    NOT NULL,          -- paragraflar boş satırla ayrılır
    anahtar_noktalar  TEXT    NOT NULL,          -- her satır bir madde
    sira              INTEGER NOT NULL UNIQUE CHECK (sira > 0)
);

-- ---------------------------------------------------------------------
-- QUIZ SORUSU  (Rehber konusu 1 — N Soru)
-- Kullanımdaki bir konu silinemez (RESTRICT): soruları sahipsiz kalmaz.
-- ---------------------------------------------------------------------
CREATE TABLE quiz_soru (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    konu_id   INTEGER NOT NULL REFERENCES rehber_konu(id) ON DELETE RESTRICT,
    metin     TEXT    NOT NULL UNIQUE,
    aciklama  TEXT    NOT NULL,                  -- cevaptan sonra gösterilen açıklama
    aktif     INTEGER NOT NULL DEFAULT 1 CHECK (aktif IN (0, 1))
);

CREATE INDEX ix_soru_konu ON quiz_soru (konu_id);

-- ---------------------------------------------------------------------
-- SEÇENEK  (Soru 1 — N Seçenek)
-- ---------------------------------------------------------------------
CREATE TABLE quiz_secenek (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    soru_id  INTEGER NOT NULL REFERENCES quiz_soru(id) ON DELETE CASCADE,
    metin    TEXT    NOT NULL,
    dogru    INTEGER NOT NULL DEFAULT 0 CHECK (dogru IN (0, 1)),
    UNIQUE (soru_id, metin)                      -- aynı soruda aynı seçenek iki kez olamaz
);

-- Kısmi benzersiz indeks: her sorunun EN FAZLA bir doğru seçeneği olabilir.
-- ("En az bir" kuralı içerik yüklenirken test edilir: tests/test_rehber_quiz.py)
CREATE UNIQUE INDEX ux_secenek_tek_dogru ON quiz_secenek (soru_id) WHERE dogru = 1;

-- ---------------------------------------------------------------------
-- QUIZ DENEMESİ  (Kullanıcı 1 — N Deneme)
-- Deneme başlatılınca soruları sunucu seçer; doğru cevaplar tarayıcıya
-- gönderilmez. Gönderilince quiz_sonucu oluşur ve sonuc_id dolar.
-- ---------------------------------------------------------------------
CREATE TABLE quiz_deneme (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    kullanici_id  INTEGER NOT NULL REFERENCES kullanici(id) ON DELETE CASCADE,
    baslangic     TEXT    NOT NULL DEFAULT (datetime('now')),
    son_teslim    TEXT    NOT NULL,              -- bu andan sonra cevap kabul edilmez
    sonuc_id      INTEGER UNIQUE REFERENCES quiz_sonucu(id) ON DELETE CASCADE  -- NULL = devam ediyor
);

CREATE INDEX ix_deneme_kullanici ON quiz_deneme (kullanici_id);

-- ---------------------------------------------------------------------
-- DENEMEDEKİ SORULAR VE VERİLEN CEVAPLAR  (Deneme N — N Soru, ara tablo)
-- ---------------------------------------------------------------------
CREATE TABLE quiz_deneme_soru (
    deneme_id           INTEGER NOT NULL REFERENCES quiz_deneme(id) ON DELETE CASCADE,
    soru_id             INTEGER NOT NULL REFERENCES quiz_soru(id)   ON DELETE RESTRICT,
    sira                INTEGER NOT NULL CHECK (sira > 0),
    secilen_secenek_id  INTEGER REFERENCES quiz_secenek(id),          -- gönderilene kadar NULL
    dogru_mu            INTEGER CHECK (dogru_mu IN (0, 1)),
    PRIMARY KEY (deneme_id, soru_id),            -- aynı soru bir denemede iki kez çıkmaz
    UNIQUE (deneme_id, sira)
);

-- ---------------------------------------------------------------------
-- Öneri → rehber konusu bağlantısı (Hafta 6 modülüyle entegrasyon)
-- ---------------------------------------------------------------------
ALTER TABLE oneri ADD COLUMN rehber_konu_id INTEGER REFERENCES rehber_konu(id);
