-- Örnek veriyle dolu veritabanının SQL dökümü (flask --app run ornek-veri ile üretildi).
-- Tüm veriler sentetiktir; gerçek kişi verisi içermez (KVKK).

BEGIN TRANSACTION;
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
INSERT INTO "analiz_kaydi" VALUES(1,1,13,76,'guclu',1,1,1,0,0,'2026-11-01 14:05:26');
INSERT INTO "analiz_kaydi" VALUES(2,2,11,60,'orta',1,0,1,0,0,'2026-11-01 14:05:26');
INSERT INTO "analiz_kaydi" VALUES(3,3,5,44,'orta',0,1,1,1,0,'2026-11-01 14:05:27');
INSERT INTO "analiz_kaydi" VALUES(4,3,8,48,'orta',1,1,0,0,0,'2026-11-01 14:05:27');
INSERT INTO "analiz_kaydi" VALUES(5,3,19,100,'guclu',1,0,1,1,0,'2026-11-01 14:05:27');
INSERT INTO "analiz_kaydi" VALUES(6,4,12,48,'orta',0,0,0,0,0,'2026-11-01 14:05:27');
INSERT INTO "analiz_kaydi" VALUES(7,5,11,52,'orta',0,0,0,1,0,'2026-11-01 14:05:27');
INSERT INTO "analiz_kaydi" VALUES(8,5,12,64,'orta',1,1,0,0,0,'2026-11-01 14:05:27');
INSERT INTO "analiz_kaydi" VALUES(9,5,12,56,'orta',0,0,0,1,0,'2026-11-01 14:05:27');
INSERT INTO "analiz_kaydi" VALUES(10,6,11,60,'orta',0,1,0,1,0,'2026-11-01 14:05:27');
INSERT INTO "analiz_kaydi" VALUES(11,6,13,68,'orta',1,0,1,0,0,'2026-11-01 14:05:27');
INSERT INTO "analiz_kaydi" VALUES(12,6,18,88,'guclu',0,1,1,0,0,'2026-11-01 14:05:27');
INSERT INTO "analiz_kaydi" VALUES(13,7,9,52,'orta',0,0,1,1,100040,'2026-11-01 14:05:27');
INSERT INTO "analiz_kaydi" VALUES(14,8,13,76,'guclu',0,1,1,1,0,'2026-11-01 14:05:27');
CREATE TABLE analiz_oneri (
    analiz_id    INTEGER NOT NULL REFERENCES analiz_kaydi(id) ON DELETE CASCADE,
    oneri_id     INTEGER NOT NULL REFERENCES oneri(id)        ON DELETE RESTRICT, -- kullanımdaki öneri silinemez
    oncelik      INTEGER NOT NULL DEFAULT 1 CHECK (oncelik BETWEEN 1 AND 5),
    kisisel_not  TEXT,                                  -- yapay zekâ ile üretilecek kişisel açıklama
    PRIMARY KEY (analiz_id, oneri_id)                   -- aynı öneri bir analize iki kez eklenemez
);
INSERT INTO "analiz_oneri" VALUES(1,5,1,NULL);
INSERT INTO "analiz_oneri" VALUES(1,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(2,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(2,5,2,NULL);
INSERT INTO "analiz_oneri" VALUES(2,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(3,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(3,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(3,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(4,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(4,4,2,NULL);
INSERT INTO "analiz_oneri" VALUES(4,5,3,NULL);
INSERT INTO "analiz_oneri" VALUES(4,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(5,9,1,NULL);
INSERT INTO "analiz_oneri" VALUES(6,3,1,NULL);
INSERT INTO "analiz_oneri" VALUES(6,4,2,NULL);
INSERT INTO "analiz_oneri" VALUES(6,5,3,NULL);
INSERT INTO "analiz_oneri" VALUES(6,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(7,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(7,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(7,4,3,NULL);
INSERT INTO "analiz_oneri" VALUES(7,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(8,4,1,NULL);
INSERT INTO "analiz_oneri" VALUES(8,5,2,NULL);
INSERT INTO "analiz_oneri" VALUES(8,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(9,3,1,NULL);
INSERT INTO "analiz_oneri" VALUES(9,4,2,NULL);
INSERT INTO "analiz_oneri" VALUES(9,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(10,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(10,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(10,4,3,NULL);
INSERT INTO "analiz_oneri" VALUES(10,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(11,5,1,NULL);
INSERT INTO "analiz_oneri" VALUES(11,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(12,3,1,NULL);
INSERT INTO "analiz_oneri" VALUES(12,5,2,NULL);
INSERT INTO "analiz_oneri" VALUES(12,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(13,6,1,NULL);
INSERT INTO "analiz_oneri" VALUES(13,1,2,NULL);
INSERT INTO "analiz_oneri" VALUES(13,3,3,NULL);
INSERT INTO "analiz_oneri" VALUES(13,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(14,3,1,NULL);
INSERT INTO "analiz_oneri" VALUES(14,9,2,NULL);
CREATE TABLE kullanici (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    ad_soyad      TEXT    NOT NULL CHECK (length(trim(ad_soyad)) >= 2),
    eposta        TEXT    NOT NULL UNIQUE CHECK (eposta LIKE '%_@_%._%'),
    sifre_hash    TEXT    NOT NULL,                     -- siteye giriş parolasının tuzlu hash'i
    kayit_tarihi  TEXT    NOT NULL DEFAULT (datetime('now'))
);
INSERT INTO "kullanici" VALUES(1,'Test Kullanıcı 1','test1@ornek.test','scrypt:32768:8:1$cWrLkUKyBTvCufCb$14d666194dc37d2532fc88ba83ce3e8878548dd67ac759ba053cfe578e8d0035f8e3aa8f4d2847db3b5f95f0adb67f74c6faa0035e7a019de6152b7be4404f55','2026-11-01 14:05:26');
INSERT INTO "kullanici" VALUES(2,'Test Kullanıcı 2','test2@ornek.test','scrypt:32768:8:1$RM1EnOGsJu1VYeMU$dd44e677d0153743c8680c3c91b4f48a7a7a6ec55f7c5a9ae6cdc945076fcee4bd43f4d493774ab266214ff592f8ea31c70039caab5586b58fadca89f3ad58e9','2026-11-01 14:05:26');
INSERT INTO "kullanici" VALUES(3,'Test Kullanıcı 3','test3@ornek.test','scrypt:32768:8:1$KK0dGXjLGB6m8Kga$412290b0fa52731ee9181c6228b28a863af7117eb61d653e4dc1f09578e1e440462153dbea5378b6e7e5c34dfce406d6c67bb907fc511032480465aa5aa5c24f','2026-11-01 14:05:27');
INSERT INTO "kullanici" VALUES(4,'Test Kullanıcı 4','test4@ornek.test','scrypt:32768:8:1$qxfsIWtIpjare720$5105bc36f8c3669dc787963f009f6204afb3aa082370c338bc1419e2b86cf3e42dc765b07d09b40a3c18423dd27a9a570d2df33d114710824bbd2167f85b0c4a','2026-11-01 14:05:27');
INSERT INTO "kullanici" VALUES(5,'Test Kullanıcı 5','test5@ornek.test','scrypt:32768:8:1$tdivXNldTk8DFAoS$b0580a24ad4c9931778291e3ffab196895a2bfa2dc80b13c12b29857782d06f11087352ec17e27f839d42e28387b1d43e61e1410b8bca8670ca11868e1bf279d','2026-11-01 14:05:27');
INSERT INTO "kullanici" VALUES(6,'Test Kullanıcı 6','test6@ornek.test','scrypt:32768:8:1$mc62L6KZ87JEOcXX$cb206c42d75bcf1a0aaf3f4b8e1cd86fa7092d5572e7d6a50a2eb431132bbfd16ec47d12058b64e2b76bbd590fa8ac22dcc7313569af36ceb9cff0350dd231da','2026-11-01 14:05:27');
INSERT INTO "kullanici" VALUES(7,'Test Kullanıcı 7','test7@ornek.test','scrypt:32768:8:1$AUgnFLHgSJd7b7Vj$9df6d2790e91b693962a21468ce34220ce460968f40e56ce36f74c82da6d73170b28ad0b6a342f9b6e7ed710960811e0d45711bb9f191332f5e9acedfe2117c7','2026-11-01 14:05:27');
INSERT INTO "kullanici" VALUES(8,'Test Kullanıcı 8','test8@ornek.test','scrypt:32768:8:1$nJjGMrr29akzNINP$61732d7389bac447cae0a5af987641364a966773e6c2c16036422422e2c05b7ff9a1462072822b03e9f0c626787af0085986ff6ab08b780898dd0e6790952a92','2026-11-01 14:05:27');
CREATE TABLE oneri (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    kod       TEXT NOT NULL UNIQUE,                     -- ör. UZUNLUK_ARTIR
    baslik    TEXT NOT NULL,
    aciklama  TEXT NOT NULL,
    kategori  TEXT NOT NULL CHECK (kategori IN ('uzunluk', 'cesitlilik', 'sizinti', 'tekrar', '2fa', 'genel'))
);
INSERT INTO "oneri" VALUES(1,'UZUNLUK_ARTIR','Parolanızı uzatın','En az 12, tercihen 16 karakterlik parolalar kullanın. Uzunluk, parola gücünü en çok artıran etkendir.','uzunluk');
INSERT INTO "oneri" VALUES(2,'PAROLA_CUMLESI','Parola cümlesi kullanın','Birbiriyle ilgisiz 4-5 kelimeden oluşan bir cümle hem güçlü hem de akılda kalıcıdır.','uzunluk');
INSERT INTO "oneri" VALUES(3,'BUYUK_HARF_EKLE','Büyük harf ekleyin','Büyük harf kullanmak olası karakter sayısını artırır.','cesitlilik');
INSERT INTO "oneri" VALUES(4,'RAKAM_EKLE','Rakam ekleyin','Rakamları başa veya sona değil, parolanın içine dağıtın.','cesitlilik');
INSERT INTO "oneri" VALUES(5,'OZEL_KARAKTER','Özel karakter ekleyin','!, ?, #, % gibi özel karakterler tahmin edilmeyi zorlaştırır.','cesitlilik');
INSERT INTO "oneri" VALUES(6,'SIZINTI_DEGISTIR','Parolanızı hemen değiştirin','Bu parola bilinen veri sızıntılarında görülmüş. Kullandığınız her hesapta değiştirin.','sizinti');
INSERT INTO "oneri" VALUES(7,'TEKRAR_KULLANMA','Her hesapta farklı parola kullanın','Bir sitede sızan parola, aynı parolayı kullandığınız tüm hesapları tehlikeye atar.','tekrar');
INSERT INTO "oneri" VALUES(8,'PAROLA_YONETICI','Parola yöneticisi kullanın','Parola yöneticisi her site için güçlü ve benzersiz parola üretip saklar.','genel');
INSERT INTO "oneri" VALUES(9,'IKI_FAKTOR','İki adımlı doğrulamayı açın','Parolanız ele geçirilse bile 2FA hesabınıza girilmesini engeller.','2fa');
CREATE TABLE quiz_sonucu (
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    kullanici_id       INTEGER NOT NULL REFERENCES kullanici(id) ON DELETE CASCADE,
    dogru_sayisi       INTEGER NOT NULL CHECK (dogru_sayisi >= 0),
    soru_sayisi        INTEGER NOT NULL CHECK (soru_sayisi > 0),
    puan               INTEGER NOT NULL CHECK (puan BETWEEN 0 AND 100),
    tamamlanma_tarihi  TEXT    NOT NULL DEFAULT (datetime('now')),
    CHECK (dogru_sayisi <= soru_sayisi)                 -- tablo düzeyinde kısıt
);
INSERT INTO "quiz_sonucu" VALUES(1,1,4,10,40,'2026-11-01 14:05:26');
INSERT INTO "quiz_sonucu" VALUES(2,1,9,10,90,'2026-11-01 14:05:26');
INSERT INTO "quiz_sonucu" VALUES(3,2,9,10,90,'2026-11-01 14:05:26');
INSERT INTO "quiz_sonucu" VALUES(4,2,6,10,60,'2026-11-01 14:05:26');
INSERT INTO "quiz_sonucu" VALUES(5,3,8,10,80,'2026-11-01 14:05:27');
INSERT INTO "quiz_sonucu" VALUES(6,3,6,10,60,'2026-11-01 14:05:27');
INSERT INTO "quiz_sonucu" VALUES(7,4,8,10,80,'2026-11-01 14:05:27');
INSERT INTO "quiz_sonucu" VALUES(8,5,7,10,70,'2026-11-01 14:05:27');
INSERT INTO "quiz_sonucu" VALUES(9,6,10,10,100,'2026-11-01 14:05:27');
INSERT INTO "quiz_sonucu" VALUES(10,6,4,10,40,'2026-11-01 14:05:27');
INSERT INTO "quiz_sonucu" VALUES(11,7,7,10,70,'2026-11-01 14:05:27');
INSERT INTO "quiz_sonucu" VALUES(12,7,3,10,30,'2026-11-01 14:05:27');
CREATE TABLE schema_surumu (
               surum            INTEGER PRIMARY KEY,
               dosya            TEXT NOT NULL,
               uygulanma_tarihi TEXT NOT NULL DEFAULT (datetime('now'))
           );
INSERT INTO "schema_surumu" VALUES(1,'001_ilk_sema.sql','2026-11-01 14:05:26');
INSERT INTO "schema_surumu" VALUES(2,'002_oneri_katalogu.sql','2026-11-01 14:05:26');
CREATE INDEX ix_analiz_kullanici_tarih ON analiz_kaydi (kullanici_id, analiz_tarihi DESC);
CREATE INDEX ix_analiz_oneri_oneri ON analiz_oneri (oneri_id);
CREATE INDEX ix_quiz_kullanici ON quiz_sonucu (kullanici_id);
DELETE FROM "sqlite_sequence";
INSERT INTO "sqlite_sequence" VALUES('oneri',9);
INSERT INTO "sqlite_sequence" VALUES('kullanici',8);
INSERT INTO "sqlite_sequence" VALUES('analiz_kaydi',14);
INSERT INTO "sqlite_sequence" VALUES('quiz_sonucu',12);
COMMIT;
