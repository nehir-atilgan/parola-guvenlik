-- Örnek veriyle dolu veritabanının SQL dökümü (flask --app run ornek-veri ile üretildi).
-- Tüm veriler sentetiktir; gerçek kişi verisi içermez (KVKK).
-- sifre_hash sütunları scrypt + tuz ile hash'lenmiş değerlerdir; düz parola yoktur.

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
INSERT INTO "analiz_kaydi" VALUES(1,1,6,56,'orta',1,1,1,1,52125,'2026-11-01 14:15:03');
INSERT INTO "analiz_kaydi" VALUES(2,1,12,64,'orta',1,1,0,0,0,'2026-11-01 14:15:03');
INSERT INTO "analiz_kaydi" VALUES(3,1,10,56,'orta',0,1,1,0,0,'2026-11-01 14:15:03');
INSERT INTO "analiz_kaydi" VALUES(4,1,7,60,'orta',1,1,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(5,2,8,48,'orta',0,1,1,0,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(6,2,11,68,'orta',0,1,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(7,2,7,44,'orta',0,0,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(8,2,10,64,'orta',1,1,1,0,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(9,3,10,56,'orta',1,1,0,0,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(10,3,6,56,'orta',1,1,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(11,4,17,84,'guclu',0,0,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(12,4,13,76,'guclu',0,1,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(13,4,9,68,'orta',1,1,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(14,4,10,64,'orta',0,1,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(15,5,8,48,'orta',0,1,1,0,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(16,6,5,36,'zayif',0,0,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(17,6,14,80,'guclu',0,1,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(18,6,10,64,'orta',1,0,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(19,6,15,84,'guclu',1,1,1,0,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(20,7,12,64,'orta',0,0,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(21,8,9,52,'orta',0,0,1,1,159015,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(22,8,11,44,'orta',0,0,0,0,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(23,9,12,80,'guclu',1,1,1,1,0,'2026-11-01 14:15:04');
INSERT INTO "analiz_kaydi" VALUES(24,10,7,52,'orta',0,1,1,1,0,'2026-11-01 14:15:05');
CREATE TABLE analiz_oneri (
    analiz_id    INTEGER NOT NULL REFERENCES analiz_kaydi(id) ON DELETE CASCADE,
    oneri_id     INTEGER NOT NULL REFERENCES oneri(id)        ON DELETE RESTRICT, -- kullanımdaki öneri silinemez
    oncelik      INTEGER NOT NULL DEFAULT 1 CHECK (oncelik BETWEEN 1 AND 5),
    kisisel_not  TEXT,                                  -- yapay zekâ ile üretilecek kişisel açıklama
    PRIMARY KEY (analiz_id, oneri_id)                   -- aynı öneri bir analize iki kez eklenemez
);
INSERT INTO "analiz_oneri" VALUES(1,6,1,NULL);
INSERT INTO "analiz_oneri" VALUES(1,1,2,NULL);
INSERT INTO "analiz_oneri" VALUES(1,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(2,4,1,NULL);
INSERT INTO "analiz_oneri" VALUES(2,5,2,NULL);
INSERT INTO "analiz_oneri" VALUES(2,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(3,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(3,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(3,5,3,NULL);
INSERT INTO "analiz_oneri" VALUES(3,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(4,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(4,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(5,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(5,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(5,5,3,NULL);
INSERT INTO "analiz_oneri" VALUES(5,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(6,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(6,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(6,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(7,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(7,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(7,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(8,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(8,5,2,NULL);
INSERT INTO "analiz_oneri" VALUES(8,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(9,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(9,4,2,NULL);
INSERT INTO "analiz_oneri" VALUES(9,5,3,NULL);
INSERT INTO "analiz_oneri" VALUES(9,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(10,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(10,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(11,3,1,NULL);
INSERT INTO "analiz_oneri" VALUES(11,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(12,3,1,NULL);
INSERT INTO "analiz_oneri" VALUES(12,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(13,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(13,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(14,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(14,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(14,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(15,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(15,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(15,5,3,NULL);
INSERT INTO "analiz_oneri" VALUES(15,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(16,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(16,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(16,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(17,3,1,NULL);
INSERT INTO "analiz_oneri" VALUES(17,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(18,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(18,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(19,5,1,NULL);
INSERT INTO "analiz_oneri" VALUES(19,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(20,3,1,NULL);
INSERT INTO "analiz_oneri" VALUES(20,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(21,6,1,NULL);
INSERT INTO "analiz_oneri" VALUES(21,1,2,NULL);
INSERT INTO "analiz_oneri" VALUES(21,3,3,NULL);
INSERT INTO "analiz_oneri" VALUES(21,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(22,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(22,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(22,4,3,NULL);
INSERT INTO "analiz_oneri" VALUES(22,5,4,NULL);
INSERT INTO "analiz_oneri" VALUES(22,9,5,NULL);
INSERT INTO "analiz_oneri" VALUES(23,9,1,NULL);
INSERT INTO "analiz_oneri" VALUES(24,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(24,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(24,9,3,NULL);
CREATE TABLE kullanici (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    ad_soyad      TEXT    NOT NULL CHECK (length(trim(ad_soyad)) >= 2),
    eposta        TEXT    NOT NULL UNIQUE CHECK (eposta LIKE '%_@_%._%'),
    sifre_hash    TEXT    NOT NULL,                     -- siteye giriş parolasının tuzlu hash'i
    kayit_tarihi  TEXT    NOT NULL DEFAULT (datetime('now'))
, rol TEXT NOT NULL DEFAULT 'kullanici'
    CHECK (rol IN ('kullanici', 'yonetici')), basarisiz_giris INTEGER NOT NULL DEFAULT 0
    CHECK (basarisiz_giris >= 0), kilit_bitis TEXT);
INSERT INTO "kullanici" VALUES(1,'Demo Yönetici','yonetici@ornek.test','scrypt:32768:8:1$isHQ0I3x04BOSUyc$9e92f0641123097c51a81e80a1738954263085d181537135e59231657b41bcb0a53caa052600445568fcb1270d3c59094ee12bd74d46daaf25fc966e594842f8','2026-11-01 14:15:03','yonetici',0,NULL);
INSERT INTO "kullanici" VALUES(2,'Demo Kullanıcı','kullanici@ornek.test','scrypt:32768:8:1$E3KDbIDCH5kd2H5r$84895b208e277d016042a6bd4d86906474d799385fea984ad6318ec2f1d49526493e6ad5253909b8fb5e7b3f88efb9f80093b55249e8156f180c6dc5f2c8949d','2026-11-01 14:15:04','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(3,'Test Kullanıcı 1','test1@ornek.test','scrypt:32768:8:1$rqMuG5TxE2De5D30$fbb84616661b1ac8d6e2983ad3b6439b2fb0c64d12cc6eb65078f591423f3314c49c9097d0cd51b17ff1358d4657d0cbfbd2f0e485a8635c94a38227f46e0ee1','2026-11-01 14:15:04','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(4,'Test Kullanıcı 2','test2@ornek.test','scrypt:32768:8:1$uxwa1VifTwWAT4oW$7007353772dc79889af33ff221a3032e22b08817b406462901db24345b18b58d17534e885f214d3e216a6e53971b57bd6a2f81f329f873ee4dc6d8c63d10a57d','2026-11-01 14:15:04','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(5,'Test Kullanıcı 3','test3@ornek.test','scrypt:32768:8:1$icTjxJEWk71GomQR$3366cf415c4bb3417182757052b49c73056efcfcb683982946010ae385d723dbb9835341ea5174742210d41de1e9483d989f17a48aff8cd4322b851551ee6727','2026-11-01 14:15:04','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(6,'Test Kullanıcı 4','test4@ornek.test','scrypt:32768:8:1$7f9sI1IuiGrVcfkk$c9ab343fb326b4a2eb8c8d2672a576d6ec0434b7c841a4f4d3e501430824b6c2a2785a74ec55cbe00e36ccb3057f2a75d9c797d95fc44e451d46e9dfa8039445','2026-11-01 14:15:04','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(7,'Test Kullanıcı 5','test5@ornek.test','scrypt:32768:8:1$R1txQY6FTjZIXntN$89f1b9d2f08a9915f02eb19c245b704bd83c809b0f29afc08d2a277a3ca97d73f8840d9aebbfeee55c4a6b6f0f61df974a75343db1df2b2142f91d3d20518288','2026-11-01 14:15:04','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(8,'Test Kullanıcı 6','test6@ornek.test','scrypt:32768:8:1$7vVONNjq74Ebra7H$74e1f0fcc76be549de8bc99e090e03eed4713f494f830eaeb632cb04209fd07c7edaa4f233ea8eefae157d99e7e910cae885c582d17591f92bd354f96d1dfe4b','2026-11-01 14:15:04','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(9,'Test Kullanıcı 7','test7@ornek.test','scrypt:32768:8:1$99u23KSwn9XQaINb$9232b026f9774a26b5623899de0eeab0db693e1c2b929a74836bdbf8a62c4d511d57cd4b1ce58b4d08af4fac0e534d92ead537505b8899596b64ac0560b01a73','2026-11-01 14:15:04','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(10,'Test Kullanıcı 8','test8@ornek.test','scrypt:32768:8:1$Rk4OmHUcij7G5rh6$4855ea82d48a368bb964226191ec40d45ce79c237c149d50d820a66c4c4197a7a63c73a47cd991b5ad14110def48286cb229daff90c64732783c8cdfc6256483','2026-11-01 14:15:05','kullanici',0,NULL);
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
CREATE TABLE oturum (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    kullanici_id    INTEGER NOT NULL REFERENCES kullanici(id) ON DELETE CASCADE,
    token_ozeti     TEXT    NOT NULL UNIQUE,
    olusturma       TEXT    NOT NULL DEFAULT (datetime('now')),
    bitis           TEXT    NOT NULL,                        -- bu andan sonra geçersiz
    iptal_edildi    INTEGER NOT NULL DEFAULT 0 CHECK (iptal_edildi IN (0, 1))
);
CREATE TABLE quiz_sonucu (
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    kullanici_id       INTEGER NOT NULL REFERENCES kullanici(id) ON DELETE CASCADE,
    dogru_sayisi       INTEGER NOT NULL CHECK (dogru_sayisi >= 0),
    soru_sayisi        INTEGER NOT NULL CHECK (soru_sayisi > 0),
    puan               INTEGER NOT NULL CHECK (puan BETWEEN 0 AND 100),
    tamamlanma_tarihi  TEXT    NOT NULL DEFAULT (datetime('now')),
    CHECK (dogru_sayisi <= soru_sayisi)                 -- tablo düzeyinde kısıt
);
INSERT INTO "quiz_sonucu" VALUES(1,2,4,10,40,'2026-11-01 14:15:04');
INSERT INTO "quiz_sonucu" VALUES(2,2,5,10,50,'2026-11-01 14:15:04');
INSERT INTO "quiz_sonucu" VALUES(3,4,7,10,70,'2026-11-01 14:15:04');
INSERT INTO "quiz_sonucu" VALUES(4,5,5,10,50,'2026-11-01 14:15:04');
INSERT INTO "quiz_sonucu" VALUES(5,6,6,10,60,'2026-11-01 14:15:04');
INSERT INTO "quiz_sonucu" VALUES(6,8,10,10,100,'2026-11-01 14:15:04');
INSERT INTO "quiz_sonucu" VALUES(7,10,6,10,60,'2026-11-01 14:15:05');
INSERT INTO "quiz_sonucu" VALUES(8,10,7,10,70,'2026-11-01 14:15:05');
CREATE TABLE schema_surumu (
               surum            INTEGER PRIMARY KEY,
               dosya            TEXT NOT NULL,
               uygulanma_tarihi TEXT NOT NULL DEFAULT (datetime('now'))
           );
INSERT INTO "schema_surumu" VALUES(1,'001_ilk_sema.sql','2026-11-01 14:15:03');
INSERT INTO "schema_surumu" VALUES(2,'002_oneri_katalogu.sql','2026-11-01 14:15:03');
INSERT INTO "schema_surumu" VALUES(3,'003_kimlik_dogrulama.sql','2026-11-01 14:15:03');
CREATE INDEX ix_analiz_kullanici_tarih ON analiz_kaydi (kullanici_id, analiz_tarihi DESC);
CREATE INDEX ix_analiz_oneri_oneri ON analiz_oneri (oneri_id);
CREATE INDEX ix_quiz_kullanici ON quiz_sonucu (kullanici_id);
CREATE INDEX ix_oturum_kullanici ON oturum (kullanici_id);
DELETE FROM "sqlite_sequence";
INSERT INTO "sqlite_sequence" VALUES('oneri',9);
INSERT INTO "sqlite_sequence" VALUES('kullanici',10);
INSERT INTO "sqlite_sequence" VALUES('analiz_kaydi',24);
INSERT INTO "sqlite_sequence" VALUES('quiz_sonucu',8);
COMMIT;
