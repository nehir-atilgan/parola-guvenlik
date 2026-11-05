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
, entropi_bit INTEGER NOT NULL DEFAULT 0
    CHECK (entropi_bit >= 0));
INSERT INTO "analiz_kaydi" VALUES(1,1,6,56,'orta',1,1,1,1,52125,'2026-11-05 19:45:43',39);
INSERT INTO "analiz_kaydi" VALUES(2,1,12,64,'orta',1,1,0,0,0,'2026-11-05 19:45:43',68);
INSERT INTO "analiz_kaydi" VALUES(3,1,10,56,'orta',0,1,1,0,0,'2026-11-05 19:45:43',52);
INSERT INTO "analiz_kaydi" VALUES(4,1,7,60,'orta',1,1,1,1,0,'2026-11-05 19:45:43',46);
INSERT INTO "analiz_kaydi" VALUES(5,2,8,48,'orta',0,1,1,0,0,'2026-11-05 19:45:43',41);
INSERT INTO "analiz_kaydi" VALUES(6,2,11,68,'orta',0,1,1,1,0,'2026-11-05 19:45:43',67);
INSERT INTO "analiz_kaydi" VALUES(7,2,7,44,'orta',0,0,1,1,0,'2026-11-05 19:45:43',38);
INSERT INTO "analiz_kaydi" VALUES(8,2,10,64,'orta',1,1,1,0,0,'2026-11-05 19:45:43',60);
INSERT INTO "analiz_kaydi" VALUES(9,3,10,56,'orta',1,1,0,0,0,'2026-11-05 19:45:43',57);
INSERT INTO "analiz_kaydi" VALUES(10,3,6,56,'orta',1,1,1,1,0,'2026-11-05 19:45:43',39);
INSERT INTO "analiz_kaydi" VALUES(11,4,17,84,'guclu',0,0,1,1,0,'2026-11-05 19:45:43',92);
INSERT INTO "analiz_kaydi" VALUES(12,4,13,76,'guclu',0,1,1,1,0,'2026-11-05 19:45:43',79);
INSERT INTO "analiz_kaydi" VALUES(13,4,9,68,'orta',1,1,1,1,0,'2026-11-05 19:45:43',59);
INSERT INTO "analiz_kaydi" VALUES(14,4,10,64,'orta',0,1,1,1,0,'2026-11-05 19:45:43',61);
INSERT INTO "analiz_kaydi" VALUES(15,5,8,48,'orta',0,1,1,0,0,'2026-11-05 19:45:43',41);
INSERT INTO "analiz_kaydi" VALUES(16,6,5,36,'zayif',0,0,1,1,0,'2026-11-05 19:45:43',27);
INSERT INTO "analiz_kaydi" VALUES(17,6,14,80,'guclu',0,1,1,1,0,'2026-11-05 19:45:43',86);
INSERT INTO "analiz_kaydi" VALUES(18,6,10,64,'orta',1,0,1,1,0,'2026-11-05 19:45:43',61);
INSERT INTO "analiz_kaydi" VALUES(19,6,15,84,'guclu',1,1,1,0,0,'2026-11-05 19:45:43',89);
INSERT INTO "analiz_kaydi" VALUES(20,7,12,64,'orta',0,0,1,1,0,'2026-11-05 19:45:43',65);
INSERT INTO "analiz_kaydi" VALUES(21,8,9,52,'orta',0,0,1,1,159015,'2026-11-05 19:45:43',49);
INSERT INTO "analiz_kaydi" VALUES(22,8,11,44,'orta',0,0,0,0,0,'2026-11-05 19:45:43',0);
INSERT INTO "analiz_kaydi" VALUES(23,9,12,80,'guclu',1,1,1,1,0,'2026-11-05 19:45:44',79);
INSERT INTO "analiz_kaydi" VALUES(24,10,7,52,'orta',0,1,1,1,0,'2026-11-05 19:45:44',43);
CREATE TABLE analiz_oneri (
    analiz_id    INTEGER NOT NULL REFERENCES analiz_kaydi(id) ON DELETE CASCADE,
    oneri_id     INTEGER NOT NULL REFERENCES oneri(id)        ON DELETE RESTRICT, -- kullanımdaki öneri silinemez
    oncelik      INTEGER NOT NULL DEFAULT 1 CHECK (oncelik BETWEEN 1 AND 5),
    kisisel_not  TEXT,                                  -- yapay zekâ ile üretilecek kişisel açıklama
    PRIMARY KEY (analiz_id, oneri_id)                   -- aynı öneri bir analize iki kez eklenemez
);
INSERT INTO "analiz_oneri" VALUES(1,6,1,NULL);
INSERT INTO "analiz_oneri" VALUES(1,1,2,NULL);
INSERT INTO "analiz_oneri" VALUES(1,2,3,NULL);
INSERT INTO "analiz_oneri" VALUES(1,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(1,8,5,NULL);
INSERT INTO "analiz_oneri" VALUES(2,5,1,NULL);
INSERT INTO "analiz_oneri" VALUES(2,4,2,NULL);
INSERT INTO "analiz_oneri" VALUES(2,2,3,NULL);
INSERT INTO "analiz_oneri" VALUES(2,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(2,8,5,NULL);
INSERT INTO "analiz_oneri" VALUES(3,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(3,5,2,NULL);
INSERT INTO "analiz_oneri" VALUES(3,3,3,NULL);
INSERT INTO "analiz_oneri" VALUES(3,2,4,NULL);
INSERT INTO "analiz_oneri" VALUES(3,9,5,NULL);
INSERT INTO "analiz_oneri" VALUES(4,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(4,2,2,NULL);
INSERT INTO "analiz_oneri" VALUES(4,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(4,8,4,NULL);
INSERT INTO "analiz_oneri" VALUES(5,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(5,5,2,NULL);
INSERT INTO "analiz_oneri" VALUES(5,3,3,NULL);
INSERT INTO "analiz_oneri" VALUES(5,2,4,NULL);
INSERT INTO "analiz_oneri" VALUES(5,9,5,NULL);
INSERT INTO "analiz_oneri" VALUES(6,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(6,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(6,2,3,NULL);
INSERT INTO "analiz_oneri" VALUES(6,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(6,8,5,NULL);
INSERT INTO "analiz_oneri" VALUES(7,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(7,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(7,2,3,NULL);
INSERT INTO "analiz_oneri" VALUES(7,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(7,8,5,NULL);
INSERT INTO "analiz_oneri" VALUES(8,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(8,5,2,NULL);
INSERT INTO "analiz_oneri" VALUES(8,2,3,NULL);
INSERT INTO "analiz_oneri" VALUES(8,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(8,8,5,NULL);
INSERT INTO "analiz_oneri" VALUES(9,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(9,5,2,NULL);
INSERT INTO "analiz_oneri" VALUES(9,4,3,NULL);
INSERT INTO "analiz_oneri" VALUES(9,2,4,NULL);
INSERT INTO "analiz_oneri" VALUES(9,9,5,NULL);
INSERT INTO "analiz_oneri" VALUES(10,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(10,2,2,NULL);
INSERT INTO "analiz_oneri" VALUES(10,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(10,8,4,NULL);
INSERT INTO "analiz_oneri" VALUES(11,3,1,NULL);
INSERT INTO "analiz_oneri" VALUES(11,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(11,8,3,NULL);
INSERT INTO "analiz_oneri" VALUES(12,3,1,NULL);
INSERT INTO "analiz_oneri" VALUES(12,2,2,NULL);
INSERT INTO "analiz_oneri" VALUES(12,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(12,8,4,NULL);
INSERT INTO "analiz_oneri" VALUES(13,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(13,2,2,NULL);
INSERT INTO "analiz_oneri" VALUES(13,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(13,8,4,NULL);
INSERT INTO "analiz_oneri" VALUES(14,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(14,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(14,2,3,NULL);
INSERT INTO "analiz_oneri" VALUES(14,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(14,8,5,NULL);
INSERT INTO "analiz_oneri" VALUES(15,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(15,5,2,NULL);
INSERT INTO "analiz_oneri" VALUES(15,3,3,NULL);
INSERT INTO "analiz_oneri" VALUES(15,2,4,NULL);
INSERT INTO "analiz_oneri" VALUES(15,9,5,NULL);
INSERT INTO "analiz_oneri" VALUES(16,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(16,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(16,2,3,NULL);
INSERT INTO "analiz_oneri" VALUES(16,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(16,8,5,NULL);
INSERT INTO "analiz_oneri" VALUES(17,3,1,NULL);
INSERT INTO "analiz_oneri" VALUES(17,2,2,NULL);
INSERT INTO "analiz_oneri" VALUES(17,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(17,8,4,NULL);
INSERT INTO "analiz_oneri" VALUES(18,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(18,2,2,NULL);
INSERT INTO "analiz_oneri" VALUES(18,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(18,8,4,NULL);
INSERT INTO "analiz_oneri" VALUES(19,5,1,NULL);
INSERT INTO "analiz_oneri" VALUES(19,2,2,NULL);
INSERT INTO "analiz_oneri" VALUES(19,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(19,8,4,NULL);
INSERT INTO "analiz_oneri" VALUES(20,3,1,NULL);
INSERT INTO "analiz_oneri" VALUES(20,2,2,NULL);
INSERT INTO "analiz_oneri" VALUES(20,9,3,NULL);
INSERT INTO "analiz_oneri" VALUES(20,8,4,NULL);
INSERT INTO "analiz_oneri" VALUES(21,6,1,NULL);
INSERT INTO "analiz_oneri" VALUES(21,1,2,NULL);
INSERT INTO "analiz_oneri" VALUES(21,3,3,NULL);
INSERT INTO "analiz_oneri" VALUES(21,2,4,NULL);
INSERT INTO "analiz_oneri" VALUES(21,9,5,NULL);
INSERT INTO "analiz_oneri" VALUES(22,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(22,5,2,NULL);
INSERT INTO "analiz_oneri" VALUES(22,3,3,NULL);
INSERT INTO "analiz_oneri" VALUES(22,4,4,NULL);
INSERT INTO "analiz_oneri" VALUES(22,2,5,NULL);
INSERT INTO "analiz_oneri" VALUES(23,2,1,NULL);
INSERT INTO "analiz_oneri" VALUES(23,9,2,NULL);
INSERT INTO "analiz_oneri" VALUES(23,8,3,NULL);
INSERT INTO "analiz_oneri" VALUES(24,1,1,NULL);
INSERT INTO "analiz_oneri" VALUES(24,3,2,NULL);
INSERT INTO "analiz_oneri" VALUES(24,2,3,NULL);
INSERT INTO "analiz_oneri" VALUES(24,9,4,NULL);
INSERT INTO "analiz_oneri" VALUES(24,8,5,NULL);
CREATE TABLE kullanici (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    ad_soyad      TEXT    NOT NULL CHECK (length(trim(ad_soyad)) >= 2),
    eposta        TEXT    NOT NULL UNIQUE CHECK (eposta LIKE '%_@_%._%'),
    sifre_hash    TEXT    NOT NULL,                     -- siteye giriş parolasının tuzlu hash'i
    kayit_tarihi  TEXT    NOT NULL DEFAULT (datetime('now'))
, rol TEXT NOT NULL DEFAULT 'kullanici'
    CHECK (rol IN ('kullanici', 'yonetici')), basarisiz_giris INTEGER NOT NULL DEFAULT 0
    CHECK (basarisiz_giris >= 0), kilit_bitis TEXT);
INSERT INTO "kullanici" VALUES(1,'Demo Yönetici','yonetici@ornek.test','scrypt:32768:8:1$HHM8rpHjdvVVPwk0$6e3c924b56b31a391589535e39c0eb66fff8e9fb5edc17f46ad4b118b329edd91545d3fb9bace7c90968d6cbe9bc99d001d06f8c80b03fd4077bf7751b799e3f','2026-11-05 19:45:43','yonetici',0,NULL);
INSERT INTO "kullanici" VALUES(2,'Demo Kullanıcı','kullanici@ornek.test','scrypt:32768:8:1$YREJrJIunYnu9yze$81786880b45de7fd34e55fa6e4b6b5e2ac54863658c4fbfc253fdf49e5a57712b7536d2797f688db718528170cac86b8d2751e8504fb5682a82ebda0b713cf72','2026-11-05 19:45:43','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(3,'Test Kullanıcı 1','test1@ornek.test','scrypt:32768:8:1$OFslXMq0RD7zagcX$fe44ef5881137e288ca47cdfd59ee6770eb6e385451dc464387759225c2f4a25e038e3fd5d4d91f2c7783eb9ae5555382bcb99384cb6b627e5b04c99bf648e9b','2026-11-05 19:45:43','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(4,'Test Kullanıcı 2','test2@ornek.test','scrypt:32768:8:1$0Y4nPDEj4LRpuy8Q$5df49cd3357ab88ed77743b8e8b924714474f9d23ecb57ff5f259f3dcf1297bfaf8b56c10ee71af3973b25f1d3157eb8e3e478cfb68d15cdae2830d81404f805','2026-11-05 19:45:43','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(5,'Test Kullanıcı 3','test3@ornek.test','scrypt:32768:8:1$UwGovSK8NUEzJF8K$452aefcbdec830faf4f073e8ed1294ca7f00953743c64227ea7fd808816a1bcf85d95fa6f3aff10193f315492b969d310f2e1343cbf81ad2a5dd157798756d3f','2026-11-05 19:45:43','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(6,'Test Kullanıcı 4','test4@ornek.test','scrypt:32768:8:1$c67Q2mf4PtMXokQO$2d3252b5172ffb0d2bac0e68fd395ef4e3a11dc1e940a4585c64f5a25542c3b16eab445221d64fe3f7563204d33f5969d179b8335533e94e19bf9252f226b1c3','2026-11-05 19:45:43','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(7,'Test Kullanıcı 5','test5@ornek.test','scrypt:32768:8:1$wVB4Sn6UIJxtywc0$4f4924e7acc23f2613b2126a5a500d32d7dcc1210870fa7b42c32463ab1605bdad3e463840498d1965e53aea1466e07b2570fb6dbd00107203dda9aa063359ed','2026-11-05 19:45:43','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(8,'Test Kullanıcı 6','test6@ornek.test','scrypt:32768:8:1$DXzO40cb0OKYWQmk$b94ecfcaaf3000c9f18aac801c3abff51da2afe3e07d64911aeaec714831e25065b5bf540aefb09c82af92006c5c9f3438a7490ba8848d32c4ab92e21976e047','2026-11-05 19:45:43','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(9,'Test Kullanıcı 7','test7@ornek.test','scrypt:32768:8:1$jMrvmeTDvVRgkFb5$49cc3559808da7d06573d5e153f939c113499f8e242dcd261370c8d0bbd842471db543701f2f29b74ef6176a46e8735b0b385470c327363742bd8ea9813c765f','2026-11-05 19:45:44','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(10,'Test Kullanıcı 8','test8@ornek.test','scrypt:32768:8:1$tPnXa5VXRfj2IPL0$7d5f1f6c9ec1679701615677abd8da96ea5e3caabe22d576cf588e63c6ee34c4689c49854d9cd1c1af2daea9f6f9673a2996aa21d5ed269f30f26be48f45cd06','2026-11-05 19:45:44','kullanici',0,NULL);
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
INSERT INTO "oneri" VALUES(10,'YAYGIN_PAROLA','Yaygın parola kullanmayın','Bu parola (veya içindeki kelime) en sık kullanılan parolalar arasında. Saldırganlar ilk önce bu listeyi dener.','sizinti');
INSERT INTO "oneri" VALUES(11,'KISISEL_BILGI','Kişisel bilgilerinizi kullanmayın','Adınız, soyadınız veya e-posta adresiniz gibi bilgiler kolayca tahmin edilir.','genel');
INSERT INTO "oneri" VALUES(12,'DESEN_KACIN','Tahmin edilebilir desenlerden kaçının','"abc", "123", "qwerty", "aaa" veya doğum yılı gibi desenler parolayı uzun olsa bile zayıflatır.','genel');
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
INSERT INTO "quiz_sonucu" VALUES(1,2,4,10,40,'2026-11-05 19:45:43');
INSERT INTO "quiz_sonucu" VALUES(2,2,5,10,50,'2026-11-05 19:45:43');
INSERT INTO "quiz_sonucu" VALUES(3,4,7,10,70,'2026-11-05 19:45:43');
INSERT INTO "quiz_sonucu" VALUES(4,5,5,10,50,'2026-11-05 19:45:43');
INSERT INTO "quiz_sonucu" VALUES(5,6,6,10,60,'2026-11-05 19:45:43');
INSERT INTO "quiz_sonucu" VALUES(6,8,10,10,100,'2026-11-05 19:45:43');
INSERT INTO "quiz_sonucu" VALUES(7,10,6,10,60,'2026-11-05 19:45:44');
INSERT INTO "quiz_sonucu" VALUES(8,10,7,10,70,'2026-11-05 19:45:44');
CREATE TABLE schema_surumu (
               surum            INTEGER PRIMARY KEY,
               dosya            TEXT NOT NULL,
               uygulanma_tarihi TEXT NOT NULL DEFAULT (datetime('now'))
           );
INSERT INTO "schema_surumu" VALUES(1,'001_ilk_sema.sql','2026-11-05 19:45:43');
INSERT INTO "schema_surumu" VALUES(2,'002_oneri_katalogu.sql','2026-11-05 19:45:43');
INSERT INTO "schema_surumu" VALUES(3,'003_kimlik_dogrulama.sql','2026-11-05 19:45:43');
INSERT INTO "schema_surumu" VALUES(4,'004_parola_analizi.sql','2026-11-05 19:45:43');
CREATE INDEX ix_analiz_kullanici_tarih ON analiz_kaydi (kullanici_id, analiz_tarihi DESC);
CREATE INDEX ix_analiz_oneri_oneri ON analiz_oneri (oneri_id);
CREATE INDEX ix_quiz_kullanici ON quiz_sonucu (kullanici_id);
CREATE INDEX ix_oturum_kullanici ON oturum (kullanici_id);
DELETE FROM "sqlite_sequence";
INSERT INTO "sqlite_sequence" VALUES('oneri',12);
INSERT INTO "sqlite_sequence" VALUES('kullanici',10);
INSERT INTO "sqlite_sequence" VALUES('analiz_kaydi',24);
INSERT INTO "sqlite_sequence" VALUES('quiz_sonucu',8);
COMMIT;
