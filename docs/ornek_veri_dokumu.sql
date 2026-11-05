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
INSERT INTO "analiz_kaydi" VALUES(1,1,6,56,'orta',1,1,1,1,52125,'2026-11-05 20:22:47',39);
INSERT INTO "analiz_kaydi" VALUES(2,1,12,64,'orta',1,1,0,0,0,'2026-11-05 20:22:47',68);
INSERT INTO "analiz_kaydi" VALUES(3,1,10,56,'orta',0,1,1,0,0,'2026-11-05 20:22:47',52);
INSERT INTO "analiz_kaydi" VALUES(4,1,7,60,'orta',1,1,1,1,0,'2026-11-05 20:22:47',46);
INSERT INTO "analiz_kaydi" VALUES(5,2,8,48,'orta',0,1,1,0,0,'2026-11-05 20:22:47',41);
INSERT INTO "analiz_kaydi" VALUES(6,2,11,68,'orta',0,1,1,1,0,'2026-11-05 20:22:47',67);
INSERT INTO "analiz_kaydi" VALUES(7,2,7,44,'orta',0,0,1,1,0,'2026-11-05 20:22:47',38);
INSERT INTO "analiz_kaydi" VALUES(8,2,10,64,'orta',1,1,1,0,0,'2026-11-05 20:22:47',60);
INSERT INTO "analiz_kaydi" VALUES(9,3,10,56,'orta',1,1,0,0,0,'2026-11-05 20:22:47',57);
INSERT INTO "analiz_kaydi" VALUES(10,3,6,56,'orta',1,1,1,1,0,'2026-11-05 20:22:47',39);
INSERT INTO "analiz_kaydi" VALUES(11,4,17,84,'guclu',0,0,1,1,0,'2026-11-05 20:22:47',92);
INSERT INTO "analiz_kaydi" VALUES(12,4,13,76,'guclu',0,1,1,1,0,'2026-11-05 20:22:47',79);
INSERT INTO "analiz_kaydi" VALUES(13,4,9,68,'orta',1,1,1,1,0,'2026-11-05 20:22:47',59);
INSERT INTO "analiz_kaydi" VALUES(14,4,10,64,'orta',0,1,1,1,0,'2026-11-05 20:22:47',61);
INSERT INTO "analiz_kaydi" VALUES(15,5,8,48,'orta',0,1,1,0,0,'2026-11-05 20:22:47',41);
INSERT INTO "analiz_kaydi" VALUES(16,6,5,36,'zayif',0,0,1,1,0,'2026-11-05 20:22:47',27);
INSERT INTO "analiz_kaydi" VALUES(17,6,14,80,'guclu',0,1,1,1,0,'2026-11-05 20:22:47',86);
INSERT INTO "analiz_kaydi" VALUES(18,6,10,64,'orta',1,0,1,1,0,'2026-11-05 20:22:47',61);
INSERT INTO "analiz_kaydi" VALUES(19,6,15,84,'guclu',1,1,1,0,0,'2026-11-05 20:22:47',89);
INSERT INTO "analiz_kaydi" VALUES(20,7,12,64,'orta',0,0,1,1,0,'2026-11-05 20:22:47',65);
INSERT INTO "analiz_kaydi" VALUES(21,8,9,52,'orta',0,0,1,1,159015,'2026-11-05 20:22:47',49);
INSERT INTO "analiz_kaydi" VALUES(22,8,11,44,'orta',0,0,0,0,0,'2026-11-05 20:22:47',0);
INSERT INTO "analiz_kaydi" VALUES(23,9,12,80,'guclu',1,1,1,1,0,'2026-11-05 20:22:48',79);
INSERT INTO "analiz_kaydi" VALUES(24,10,7,52,'orta',0,1,1,1,0,'2026-11-05 20:22:48',43);
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
INSERT INTO "kullanici" VALUES(1,'Demo Yönetici','yonetici@ornek.test','scrypt:32768:8:1$BbsHLJsVZeEcEWTD$781a3053fd725107adc297c48e4669c763b963d85a9f2ab982f73226b4a82d10a8fb9d95a7b8ab0aa6506eb480e25a9814b4585a060e2b847aee26300b27eb19','2026-11-05 20:22:47','yonetici',0,NULL);
INSERT INTO "kullanici" VALUES(2,'Demo Kullanıcı','kullanici@ornek.test','scrypt:32768:8:1$D5G9q42zv39ZL9Cs$05fbad4138d56fe98cacbc081a612e9228081b3195dde79948333ee01d8f360927206083dfa2cbef3cb529cabfac90268829409de4e358d30bf31dd9078eeb9b','2026-11-05 20:22:47','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(3,'Test Kullanıcı 1','test1@ornek.test','scrypt:32768:8:1$izXZfokDTpE9YZnE$0ebb809e659d39009aa26795f20d100315bff27bf50fe30a2eb7b1bc8aced3589effaef4ba1b63bd415acbc8493866ee6c949ea6113013cd7c311d69d397a279','2026-11-05 20:22:47','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(4,'Test Kullanıcı 2','test2@ornek.test','scrypt:32768:8:1$kOQxsrNMPJPVjnki$f7b6bc3017eb8ae28b4c978f2418594e83e1d511c88ba984b41121c174ca5fe0c7e994e3759bdf7b28e0a4f26dc19dbdf114961c4536e8329342546ed621ad9d','2026-11-05 20:22:47','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(5,'Test Kullanıcı 3','test3@ornek.test','scrypt:32768:8:1$d4u48ESPzSunY1Rk$fec97087adbbd083bbb7945863037f5c198bc3b536bfb5046c9334e0140d12e441f4de2f83bcd2e6b4793d4050a6e7ae88931e676eb523e7de3fcd46ddbeb3bc','2026-11-05 20:22:47','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(6,'Test Kullanıcı 4','test4@ornek.test','scrypt:32768:8:1$JCBrBpO1ZAB1Bur9$59a7d1c79d042be1344426a656312de0e5ba93af4f20799a7be3e147954ceaaed2c4e09bb0ed49e0f0235c2af0c6b31102a3e65660ebdd3be9635f2de85587d4','2026-11-05 20:22:47','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(7,'Test Kullanıcı 5','test5@ornek.test','scrypt:32768:8:1$v70XwgSKTz0UNwjx$fa724eb0b64d150016261f4877da46a30348434d3087c93810dad69077c1f34f735307ccaea5e9048259cbe04e974f9fc8424c60f1898853b91a3c139180896e','2026-11-05 20:22:47','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(8,'Test Kullanıcı 6','test6@ornek.test','scrypt:32768:8:1$j9gv5uhYCTGTKZhj$5c59f849b811db88736c5139ecc871c3a7395112beaaed79fffd63d170f4adb5308a438b8e09af5b1173f4867fda3200f71addfed2f2f640d26c81479790b428','2026-11-05 20:22:47','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(9,'Test Kullanıcı 7','test7@ornek.test','scrypt:32768:8:1$8QsNHfHr4O0tQ18E$21d3d3491c6f93355778cf827d8032abc48aa4127f27eab51bd59e80fd550c86a89956e5f844ad7d9341335b785a08e825a4c6bbc5b0c03c09a51e24cc9ea006','2026-11-05 20:22:48','kullanici',0,NULL);
INSERT INTO "kullanici" VALUES(10,'Test Kullanıcı 8','test8@ornek.test','scrypt:32768:8:1$iIH8sVjfeyZJx7za$9d90873a6a2b973a6cf64609aed1e373ae87c0c3cf3f4c38d877a6139b8d57d0d83f5683146e1d479af426aa634cbecadd0b0fc0a737a91f45c28f7f61abe583','2026-11-05 20:22:48','kullanici',0,NULL);
CREATE TABLE oneri (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    kod       TEXT NOT NULL UNIQUE,                     -- ör. UZUNLUK_ARTIR
    baslik    TEXT NOT NULL,
    aciklama  TEXT NOT NULL,
    kategori  TEXT NOT NULL CHECK (kategori IN ('uzunluk', 'cesitlilik', 'sizinti', 'tekrar', '2fa', 'genel'))
, rehber_konu_id INTEGER REFERENCES rehber_konu(id));
INSERT INTO "oneri" VALUES(1,'UZUNLUK_ARTIR','Parolanızı uzatın','En az 12, tercihen 16 karakterlik parolalar kullanın. Uzunluk, parola gücünü en çok artıran etkendir.','uzunluk',1);
INSERT INTO "oneri" VALUES(2,'PAROLA_CUMLESI','Parola cümlesi kullanın','Birbiriyle ilgisiz 4-5 kelimeden oluşan bir cümle hem güçlü hem de akılda kalıcıdır.','uzunluk',2);
INSERT INTO "oneri" VALUES(3,'BUYUK_HARF_EKLE','Büyük harf ekleyin','Büyük harf kullanmak olası karakter sayısını artırır.','cesitlilik',1);
INSERT INTO "oneri" VALUES(4,'RAKAM_EKLE','Rakam ekleyin','Rakamları başa veya sona değil, parolanın içine dağıtın.','cesitlilik',1);
INSERT INTO "oneri" VALUES(5,'OZEL_KARAKTER','Özel karakter ekleyin','!, ?, #, % gibi özel karakterler tahmin edilmeyi zorlaştırır.','cesitlilik',1);
INSERT INTO "oneri" VALUES(6,'SIZINTI_DEGISTIR','Parolanızı hemen değiştirin','Bu parola bilinen veri sızıntılarında görülmüş. Kullandığınız her hesapta değiştirin.','sizinti',4);
INSERT INTO "oneri" VALUES(7,'TEKRAR_KULLANMA','Her hesapta farklı parola kullanın','Bir sitede sızan parola, aynı parolayı kullandığınız tüm hesapları tehlikeye atar.','tekrar',3);
INSERT INTO "oneri" VALUES(8,'PAROLA_YONETICI','Parola yöneticisi kullanın','Parola yöneticisi her site için güçlü ve benzersiz parola üretip saklar.','genel',7);
INSERT INTO "oneri" VALUES(9,'IKI_FAKTOR','İki adımlı doğrulamayı açın','Parolanız ele geçirilse bile 2FA hesabınıza girilmesini engeller.','2fa',5);
INSERT INTO "oneri" VALUES(10,'YAYGIN_PAROLA','Yaygın parola kullanmayın','Bu parola (veya içindeki kelime) en sık kullanılan parolalar arasında. Saldırganlar ilk önce bu listeyi dener.','sizinti',1);
INSERT INTO "oneri" VALUES(11,'KISISEL_BILGI','Kişisel bilgilerinizi kullanmayın','Adınız, soyadınız veya e-posta adresiniz gibi bilgiler kolayca tahmin edilir.','genel',1);
INSERT INTO "oneri" VALUES(12,'DESEN_KACIN','Tahmin edilebilir desenlerden kaçının','"abc", "123", "qwerty", "aaa" veya doğum yılı gibi desenler parolayı uzun olsa bile zayıflatır.','genel',1);
CREATE TABLE oturum (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    kullanici_id    INTEGER NOT NULL REFERENCES kullanici(id) ON DELETE CASCADE,
    token_ozeti     TEXT    NOT NULL UNIQUE,
    olusturma       TEXT    NOT NULL DEFAULT (datetime('now')),
    bitis           TEXT    NOT NULL,                        -- bu andan sonra geçersiz
    iptal_edildi    INTEGER NOT NULL DEFAULT 0 CHECK (iptal_edildi IN (0, 1))
);
CREATE TABLE quiz_deneme (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    kullanici_id  INTEGER NOT NULL REFERENCES kullanici(id) ON DELETE CASCADE,
    baslangic     TEXT    NOT NULL DEFAULT (datetime('now')),
    son_teslim    TEXT    NOT NULL,              -- bu andan sonra cevap kabul edilmez
    sonuc_id      INTEGER UNIQUE REFERENCES quiz_sonucu(id) ON DELETE CASCADE  -- NULL = devam ediyor
);
CREATE TABLE quiz_deneme_soru (
    deneme_id           INTEGER NOT NULL REFERENCES quiz_deneme(id) ON DELETE CASCADE,
    soru_id             INTEGER NOT NULL REFERENCES quiz_soru(id)   ON DELETE RESTRICT,
    sira                INTEGER NOT NULL CHECK (sira > 0),
    secilen_secenek_id  INTEGER REFERENCES quiz_secenek(id),          -- gönderilene kadar NULL
    dogru_mu            INTEGER CHECK (dogru_mu IN (0, 1)),
    PRIMARY KEY (deneme_id, soru_id),            -- aynı soru bir denemede iki kez çıkmaz
    UNIQUE (deneme_id, sira)
);
CREATE TABLE quiz_secenek (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    soru_id  INTEGER NOT NULL REFERENCES quiz_soru(id) ON DELETE CASCADE,
    metin    TEXT    NOT NULL,
    dogru    INTEGER NOT NULL DEFAULT 0 CHECK (dogru IN (0, 1)),
    UNIQUE (soru_id, metin)                      -- aynı soruda aynı seçenek iki kez olamaz
);
INSERT INTO "quiz_secenek" VALUES(1,1,'Uzunluğu',1);
INSERT INTO "quiz_secenek" VALUES(2,1,'Sonuna ünlem işareti eklenmesi',0);
INSERT INTO "quiz_secenek" VALUES(3,1,'İlk harfinin büyük yazılması',0);
INSERT INTO "quiz_secenek" VALUES(4,1,'İçinde doğum yılının bulunması',0);
INSERT INTO "quiz_secenek" VALUES(5,2,'mavi-kalem-rüzgar-otobüs-71',1);
INSERT INTO "quiz_secenek" VALUES(6,2,'Galatasaray1905',0);
INSERT INTO "quiz_secenek" VALUES(7,2,'P@ssw0rd!',0);
INSERT INTO "quiz_secenek" VALUES(8,2,'Ahmet1990',0);
INSERT INTO "quiz_secenek" VALUES(9,3,'Saldırı araçları bu tür değişiklikleri otomatik olarak dener',1);
INSERT INTO "quiz_secenek" VALUES(10,3,'Özel karakterler sitelerde kabul edilmez',0);
INSERT INTO "quiz_secenek" VALUES(11,3,'Simgeler parolayı kısaltır',0);
INSERT INTO "quiz_secenek" VALUES(12,3,'Büyük harf içermediği için',0);
INSERT INTO "quiz_secenek" VALUES(13,4,'kedi-bulut-çekiç-mavi-elma',1);
INSERT INTO "quiz_secenek" VALUES(14,4,'Ağaç yaş iken eğilir',0);
INSERT INTO "quiz_secenek" VALUES(15,4,'seni çok seviyorum',0);
INSERT INTO "quiz_secenek" VALUES(16,4,'aaaa-bbbb-cccc-dddd',0);
INSERT INTO "quiz_secenek" VALUES(17,5,'Rastgele seçilmiş kelimelerin sayısı',1);
INSERT INTO "quiz_secenek" VALUES(18,5,'İçindeki özel karakter sayısı',0);
INSERT INTO "quiz_secenek" VALUES(19,5,'Kelimelerin Türkçe olması',0);
INSERT INTO "quiz_secenek" VALUES(20,5,'Kelimelerin büyük harfle başlaması',0);
INSERT INTO "quiz_secenek" VALUES(21,6,'Birbiriyle ilgisiz ve rastgele',1);
INSERT INTO "quiz_secenek" VALUES(22,6,'Sevdiğiniz bir şarkının ilk dizesinden',0);
INSERT INTO "quiz_secenek" VALUES(23,6,'Aile üyelerinizin isimlerinden',0);
INSERT INTO "quiz_secenek" VALUES(24,6,'Aynı kelimeyi birkaç kez tekrarlayarak',0);
INSERT INTO "quiz_secenek" VALUES(25,7,'Sızan e-posta–parola çiftlerinin başka sitelerde denenmesi',1);
INSERT INTO "quiz_secenek" VALUES(26,7,'Parolanın tüm kombinasyonlarının tek tek denenmesi',0);
INSERT INTO "quiz_secenek" VALUES(27,7,'Sahte bir e-postayla parola istenmesi',0);
INSERT INTO "quiz_secenek" VALUES(28,7,'Klavye tuş vuruşlarının kaydedilmesi',0);
INSERT INTO "quiz_secenek" VALUES(29,8,'Bir sitedeki sızıntı diğer hesaplarınızı da tehlikeye atar',1);
INSERT INTO "quiz_secenek" VALUES(30,8,'Parola güçlü olduğu için risk oluşmaz',0);
INSERT INTO "quiz_secenek" VALUES(31,8,'Yalnızca sızıntının olduğu sitedeki hesap etkilenir',0);
INSERT INTO "quiz_secenek" VALUES(32,8,'Siteler aynı parolanın kullanılmasına izin vermez',0);
INSERT INTO "quiz_secenek" VALUES(33,9,'Her hesap için parola yöneticisinin ürettiği farklı bir parola',1);
INSERT INTO "quiz_secenek" VALUES(34,9,'Ana parolanın sonuna site adını eklemek',0);
INSERT INTO "quiz_secenek" VALUES(35,9,'Önemsiz siteler için hep aynı parolayı kullanmak',0);
INSERT INTO "quiz_secenek" VALUES(36,9,'Parolaları masadaki bir kâğıda yazmak',0);
INSERT INTO "quiz_secenek" VALUES(37,10,'Parola özetinin yalnızca ilk 5 karakterini',1);
INSERT INTO "quiz_secenek" VALUES(38,10,'Parolanın kendisini',0);
INSERT INTO "quiz_secenek" VALUES(39,10,'Parolanın şifrelenmiş tam halini',0);
INSERT INTO "quiz_secenek" VALUES(40,10,'E-posta adresinizi ve parolanızı',0);
INSERT INTO "quiz_secenek" VALUES(41,11,'Bu parolayı kullandığınız tüm hesaplarda değiştirmelisiniz',1);
INSERT INTO "quiz_secenek" VALUES(42,11,'Yalnızca sızıntının olduğu sitede değiştirmelisiniz',0);
INSERT INTO "quiz_secenek" VALUES(43,11,'Parolanın sonuna bir rakam eklemelisiniz',0);
INSERT INTO "quiz_secenek" VALUES(44,11,'Sızıntı eskiyse bir şey yapmanıza gerek yoktur',0);
INSERT INTO "quiz_secenek" VALUES(45,12,'Saldırganlar sızıntı listelerini sürekli yeni saldırılarda kullanır',1);
INSERT INTO "quiz_secenek" VALUES(46,12,'Sızıntılar bir süre sonra kendiliğinden silinir',0);
INSERT INTO "quiz_secenek" VALUES(47,12,'Eski parolalar kırılamaz',0);
INSERT INTO "quiz_secenek" VALUES(48,12,'Siteler eski parolaları kabul etmez',0);
INSERT INTO "quiz_secenek" VALUES(49,13,'Parola ele geçirilse bile hesaba girişi engeller',1);
INSERT INTO "quiz_secenek" VALUES(50,13,'Parolayı daha uzun hale getirir',0);
INSERT INTO "quiz_secenek" VALUES(51,13,'Parolayı hatırlamayı kolaylaştırır',0);
INSERT INTO "quiz_secenek" VALUES(52,13,'Veri sızıntılarını tamamen önler',0);
INSERT INTO "quiz_secenek" VALUES(53,14,'SMS ile gelen kod',1);
INSERT INTO "quiz_secenek" VALUES(54,14,'Doğrulama uygulaması',0);
INSERT INTO "quiz_secenek" VALUES(55,14,'Fiziksel güvenlik anahtarı',0);
INSERT INTO "quiz_secenek" VALUES(56,14,'Geçiş anahtarı (passkey)',0);
INSERT INTO "quiz_secenek" VALUES(57,15,'Kodu vermeden aramayı bitirip bankayı resmi numarasından aramalısınız',1);
INSERT INTO "quiz_secenek" VALUES(58,15,'Bankadan aradığı için kodu söylemelisiniz',0);
INSERT INTO "quiz_secenek" VALUES(59,15,'Kodun yalnızca yarısını söylemelisiniz',0);
INSERT INTO "quiz_secenek" VALUES(60,15,'Kodu SMS ile göndermelisiniz',0);
INSERT INTO "quiz_secenek" VALUES(61,16,'"Hesabınız 24 saat içinde kapatılacak, hemen giriş yapın" gibi aciliyet',1);
INSERT INTO "quiz_secenek" VALUES(62,16,'Mesajda sizin adınızın geçmesi',0);
INSERT INTO "quiz_secenek" VALUES(63,16,'Mesajda kurum logosunun bulunması',0);
INSERT INTO "quiz_secenek" VALUES(64,16,'Mesajın Türkçe yazılmış olması',0);
INSERT INTO "quiz_secenek" VALUES(65,17,'Kurumun sitesine adresi kendiniz yazarak gitmek',1);
INSERT INTO "quiz_secenek" VALUES(66,17,'Bağlantıya tıklayıp sayfanın tasarımına bakmak',0);
INSERT INTO "quiz_secenek" VALUES(67,17,'E-postadaki telefon numarasını aramak',0);
INSERT INTO "quiz_secenek" VALUES(68,17,'Sayfada kilit simgesi varsa güvenmek',0);
INSERT INTO "quiz_secenek" VALUES(69,18,'Kayıtlı parolayı yalnızca doğru alan adında otomatik doldurur',1);
INSERT INTO "quiz_secenek" VALUES(70,18,'Sahte e-postaları otomatik olarak siler',0);
INSERT INTO "quiz_secenek" VALUES(71,18,'Bağlantılara tıklamayı engeller',0);
INSERT INTO "quiz_secenek" VALUES(72,18,'Parolayı her gün değiştirir',0);
INSERT INTO "quiz_secenek" VALUES(73,19,'Ana parola',1);
INSERT INTO "quiz_secenek" VALUES(74,19,'E-posta parolanız',0);
INSERT INTO "quiz_secenek" VALUES(75,19,'Banka parolanız',0);
INSERT INTO "quiz_secenek" VALUES(76,19,'Hiçbiri, parola gerekmez',0);
INSERT INTO "quiz_secenek" VALUES(77,20,'Başka yerde kullanılmayan uzun bir parola cümlesi',1);
INSERT INTO "quiz_secenek" VALUES(78,20,'E-posta parolanızla aynı parola',0);
INSERT INTO "quiz_secenek" VALUES(79,20,'Kısa ama özel karakterli bir parola',0);
INSERT INTO "quiz_secenek" VALUES(80,20,'Doğum tarihiniz',0);
INSERT INTO "quiz_secenek" VALUES(81,21,'Her site için güçlü ve benzersiz parolaları üretip saklaması',1);
INSERT INTO "quiz_secenek" VALUES(82,21,'Parolaları kısaltması',0);
INSERT INTO "quiz_secenek" VALUES(83,21,'Veri sızıntılarını tamamen engellemesi',0);
INSERT INTO "quiz_secenek" VALUES(84,21,'İki adımlı doğrulamayı gereksiz kılması',0);
CREATE TABLE quiz_sonucu (
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    kullanici_id       INTEGER NOT NULL REFERENCES kullanici(id) ON DELETE CASCADE,
    dogru_sayisi       INTEGER NOT NULL CHECK (dogru_sayisi >= 0),
    soru_sayisi        INTEGER NOT NULL CHECK (soru_sayisi > 0),
    puan               INTEGER NOT NULL CHECK (puan BETWEEN 0 AND 100),
    tamamlanma_tarihi  TEXT    NOT NULL DEFAULT (datetime('now')),
    CHECK (dogru_sayisi <= soru_sayisi)                 -- tablo düzeyinde kısıt
);
INSERT INTO "quiz_sonucu" VALUES(1,2,4,10,40,'2026-11-05 20:22:47');
INSERT INTO "quiz_sonucu" VALUES(2,2,5,10,50,'2026-11-05 20:22:47');
INSERT INTO "quiz_sonucu" VALUES(3,4,7,10,70,'2026-11-05 20:22:47');
INSERT INTO "quiz_sonucu" VALUES(4,5,5,10,50,'2026-11-05 20:22:47');
INSERT INTO "quiz_sonucu" VALUES(5,6,6,10,60,'2026-11-05 20:22:47');
INSERT INTO "quiz_sonucu" VALUES(6,8,10,10,100,'2026-11-05 20:22:47');
INSERT INTO "quiz_sonucu" VALUES(7,10,6,10,60,'2026-11-05 20:22:48');
INSERT INTO "quiz_sonucu" VALUES(8,10,7,10,70,'2026-11-05 20:22:48');
CREATE TABLE quiz_soru (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    konu_id   INTEGER NOT NULL REFERENCES rehber_konu(id) ON DELETE RESTRICT,
    metin     TEXT    NOT NULL UNIQUE,
    aciklama  TEXT    NOT NULL,                  -- cevaptan sonra gösterilen açıklama
    aktif     INTEGER NOT NULL DEFAULT 1 CHECK (aktif IN (0, 1))
);
INSERT INTO "quiz_soru" VALUES(1,1,'Bir parolanın gücünü en çok artıran özellik hangisidir?','Her ek karakter olası kombinasyon sayısını katlayarak artırır; uzunluk tek başına en etkili ölçüttür.',1);
INSERT INTO "quiz_soru" VALUES(2,1,'Aşağıdakilerden hangisi en güçlü parola adayıdır?','Uzun ve birbiriyle ilgisiz kelimelerden oluşuyor. Diğerleri yaygın bir kelime, bilinen bir simge değişikliği veya kişisel bilgi içeriyor.',1);
INSERT INTO "quiz_soru" VALUES(3,1,'"Parola" kelimesinin harflerini simgelerle değiştirmek ("P@r0la") parolayı neden yeterince güçlü yapmaz?','Harf–simge değişiklikleri (a→@, o→0) o kadar yaygındır ki sözlük saldırısı araçları bunları kendiliğinden dener.',1);
INSERT INTO "quiz_soru" VALUES(4,2,'Aşağıdakilerden hangisi iyi bir parola cümlesidir?','Rastgele ve ilgisiz kelimelerden oluşuyor. Atasözleri ve sık kullanılan ifadeler sözlük listelerinde yer alır; tekrar eden harfler de kolay tahmin edilir.',1);
INSERT INTO "quiz_soru" VALUES(5,2,'Bir parola cümlesinin gücünü asıl sağlayan nedir?','Her rastgele kelime, tahmin edilmesi gereken olasılık sayısını büyük ölçüde artırır.',1);
INSERT INTO "quiz_soru" VALUES(6,2,'Parola cümlesi için kelimeler nasıl seçilmelidir?','Anlamlı bir cümle veya kişisel isimler tahmin edilebilir; rastgelelik parolayı güçlü kılar.',1);
INSERT INTO "quiz_soru" VALUES(7,3,'"Credential stuffing" saldırısı nedir?','Saldırgan parolayı tahmin etmez; bir sitede sızan bilgileri, aynı parolanın kullanıldığı diğer sitelerde dener.',1);
INSERT INTO "quiz_soru" VALUES(8,3,'Aynı güçlü parolayı tüm hesaplarınızda kullanırsanız ne olur?','Parola sızdığında gücü önemini yitirir; saldırgan onu bildiği için diğer hesaplarda doğrudan kullanabilir.',1);
INSERT INTO "quiz_soru" VALUES(9,3,'Aşağıdakilerden hangisi güvenli bir yaklaşımdır?','Her hesapta benzersiz ve rastgele bir parola, bir sızıntının diğer hesaplara yayılmasını engeller.',1);
INSERT INTO "quiz_soru" VALUES(10,4,'Sızıntı kontrolü yapan servisler k-anonimlik yöntemiyle ne gönderir?','Yalnızca özetin kısa bir öneki gönderildiği için servis hangi parolanın sorgulandığını bilemez.',1);
INSERT INTO "quiz_soru" VALUES(11,4,'Parolanızın bir sızıntıda yer aldığını öğrendiniz. Ne yapmalısınız?','Sızan parola listeleri tüm sitelerde denenir; aynı parolanın kullanıldığı her hesap risk altındadır.',1);
INSERT INTO "quiz_soru" VALUES(12,4,'Sızan parolalar neden yıllar sonra bile tehlikelidir?','Sızıntı listeleri birleştirilip yeniden paylaşılır; değiştirilmemiş parolalar yıllar sonra da işe yarar.',1);
INSERT INTO "quiz_soru" VALUES(13,5,'İki adımlı doğrulamanın temel faydası nedir?','Saldırgan parolayı bilse bile ikinci kanıta (kod, anahtar) sahip olmadığı için giriş yapamaz.',1);
INSERT INTO "quiz_soru" VALUES(14,5,'Aşağıdaki 2FA yöntemlerinden hangisi genellikle en zayıf olanıdır?','SMS kodları SIM kart kopyalama gibi yöntemlerle ele geçirilebilir; yine de hiç 2FA kullanmamaktan iyidir.',1);
INSERT INTO "quiz_soru" VALUES(15,5,'Arayan biri "Bankadan arıyorum, size gelen doğrulama kodunu söyler misiniz?" diyor. Ne yapmalısınız?','Kurumlar doğrulama kodunu asla telefonla istemez; bu bir sosyal mühendislik girişimidir.',1);
INSERT INTO "quiz_soru" VALUES(16,6,'Aşağıdakilerden hangisi oltalama mesajının tipik bir işaretidir?','Saldırganlar düşünmeden hareket etmeniz için aciliyet ve korku yaratır. Logo ve ad gibi ayrıntılar kolayca taklit edilebilir.',1);
INSERT INTO "quiz_soru" VALUES(17,6,'Bir e-postadaki bağlantının gerçek olup olmadığından emin olmak için en doğru yol hangisidir?','Sahte sayfalar birebir kopyalanabilir ve kilit simgesine sahip olabilir; adresi kendiniz yazmak sahte bağlantıyı devre dışı bırakır.',1);
INSERT INTO "quiz_soru" VALUES(18,6,'Parola yöneticisi oltalamaya karşı nasıl korur?','Sahte "paypa1.com" sitesinde parola yöneticisi doldurma önermez; bu da bir uyarı işaretidir.',1);
INSERT INTO "quiz_soru" VALUES(19,7,'Parola yöneticisi kullanırken hatırlamanız gereken tek parola hangisidir?','Diğer tüm parolalar ana parolayla korunan kasada saklanır.',1);
INSERT INTO "quiz_soru" VALUES(20,7,'Ana parola için en uygun seçim hangisidir?','Ana parola tüm kasayı korur; uzun, benzersiz ve tahmin edilemez olmalıdır.',1);
INSERT INTO "quiz_soru" VALUES(21,7,'Parola yöneticisinin en büyük faydası nedir?','Benzersiz parolalar sayesinde bir sitedeki sızıntı diğer hesaplarınızı etkilemez.',1);
CREATE TABLE rehber_konu (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    slug              TEXT    NOT NULL UNIQUE CHECK (slug NOT GLOB '*[^a-z0-9-]*' AND length(slug) >= 3),
    baslik            TEXT    NOT NULL,
    ozet              TEXT    NOT NULL,
    icerik            TEXT    NOT NULL,          -- paragraflar boş satırla ayrılır
    anahtar_noktalar  TEXT    NOT NULL,          -- her satır bir madde
    sira              INTEGER NOT NULL UNIQUE CHECK (sira > 0)
);
INSERT INTO "rehber_konu" VALUES(1,'guclu-parola','Güçlü parola nasıl oluşturulur?','Uzunluk, çeşitlilik ve tahmin edilemezlik bir parolayı güçlü yapar.','Saldırganlar parolaları iki yolla bulmaya çalışır: olası tüm kombinasyonları tek tek dener (kaba kuvvet) ya da daha önce sızmış parola ve sözlük listelerini dener. Güçlü bir parola her iki yönteme de dayanıklı olmalıdır.

Uzunluk en önemli etkendir. Her ek karakter, denenmesi gereken kombinasyon sayısını katlayarak artırır. Bu yüzden 8 karakterlik bir parolayı kırmak, aynı türden 16 karakterlik bir parolayı kırmaktan milyarlarca kat daha kolaydır.

Büyük harf, küçük harf, rakam ve özel karakter kullanmak karakter havuzunu büyütür. Ancak "Parola1!" gibi bilinen bir kalıba sıkıştırılmış çeşitlilik pek işe yaramaz. Adınız, doğum yılınız, tuttuğunuz takım, "123" veya "qwerty" gibi tahmin edilebilir parçalardan kaçının. Harfleri benzer simgelerle değiştirmek ("P@r0la") de yeterli değildir; saldırı araçları bu değişiklikleri otomatik olarak dener.','En az 12, tercihen 16 karakter kullanın.
Kişisel bilgi, takım adı ve sözlük kelimesi kullanmayın.
Klavye ve sayı dizilerinden (qwerty, 123456) kaçının.
Her hesap için farklı bir parola kullanın.',1);
INSERT INTO "rehber_konu" VALUES(2,'parola-cumlesi','Parola cümlesi: uzun ama akılda kalıcı','Rastgele seçilmiş birkaç kelime, karmaşık kısa parolalardan hem daha güçlü hem daha kolay hatırlanır.','Parola cümlesi, birbiriyle anlam ilişkisi olmayan 4–6 kelimenin birleştirilmesiyle oluşturulur; örneğin "turuncu-vapur-kaktüs-defter". Böyle bir parola hem uzundur hem de karmaşık simgelerden oluşan kısa parolalara göre çok daha kolay hatırlanır.

Kelimeler rastgele seçilmelidir. Bilinen bir şarkı sözü, atasözü veya film repliği sözlük saldırısı listelerinde yer alır ve parola cümlesinin avantajını ortadan kaldırır.

Site kuralları rakam veya özel karakter istiyorsa kelimelerin arasına ayraç (-, .) ve bir rakam eklenebilir. Parola cümlesinin asıl gücünü ise rastgele seçilmiş kelimelerin sayısı sağlar.','4–6 rastgele ve birbiriyle ilgisiz kelime seçin.
Şarkı sözü, atasözü ve replik kullanmayın.
Gerekirse kelimeler arasına ayraç ve rakam ekleyin.',2);
INSERT INTO "rehber_konu" VALUES(3,'tekrar-kullanim','Aynı parolayı tekrar kullanmanın riski','Tek bir sızıntı, aynı parolayı kullandığınız tüm hesapları tehlikeye atar.','Bir site saldırıya uğrayıp kullanıcı bilgileri sızdığında, saldırganlar bu e-posta ve parola çiftlerini başka sitelerde de otomatik olarak dener. Bu saldırıya "credential stuffing" (kimlik bilgisi doldurma) denir.

Aynı parolayı birden çok hesapta kullanan biri için tek bir sızıntı; e-posta, sosyal medya ve bankacılık hesaplarının hepsinin ele geçirilmesi anlamına gelebilir. Parolanın güçlü olması bu durumda koruma sağlamaz, çünkü saldırgan parolayı tahmin etmez; onu zaten bilir.

Bu yüzden her hesabın kendine özgü bir parolası olmalıdır. "Parola1-facebook", "Parola1-gmail" gibi küçük değişiklikler de güvenli değildir; saldırganlar bu kalıpları kolayca dener.','Her hesap için ayrı bir parola kullanın.
Tek bir sızıntı tüm hesapları riske atabilir.
Parolaya site adı eklemek gibi küçük değişiklikler yeterli değildir.
Parola yöneticisi bu işi kolaylaştırır.',3);
INSERT INTO "rehber_konu" VALUES(4,'veri-sizintilari','Veri sızıntıları ve sızıntı kontrolü','Sızan parolalar yıllarca kullanılır; parolanızın sızıp sızmadığı, parolanız paylaşılmadan kontrol edilebilir.','Veri sızıntısı, bir kurumun sakladığı kullanıcı bilgilerinin yetkisiz kişilerin eline geçmesidir. Sızan veriler çoğu zaman internette paylaşılır veya satılır ve yıllarca yeni saldırılarda kullanılır.

Have I Been Pwned gibi servisler, bilinen sızıntılarda yer alan yüz milyonlarca parolayı bir araya getirir. Parolanız kontrol edilirken k-anonimlik yöntemi kullanılır: parolanın kendisi değil, özetinin (hash) yalnızca ilk 5 karakteri gönderilir. Servis bu önekle başlayan tüm özetleri döndürür ve eşleşme sizin tarafınızda aranır. Böylece servis parolanızı hiçbir zaman öğrenmez.

Parolanız bir sızıntıda görünüyorsa, onu kullandığınız her hesapta hemen değiştirin ve bu parolayı bir daha kullanmayın. Önemli hesaplarınızda iki adımlı doğrulamayı da açın.','Sızan parolalar yıllarca saldırılarda kullanılır.
k-anonimlik: parolanın kendisi hiçbir zaman gönderilmez.
Sızmış bir parolayı kullandığınız her yerde değiştirin.',4);
INSERT INTO "rehber_konu" VALUES(5,'iki-adimli-dogrulama','İki adımlı doğrulama (2FA)','Parolanız ele geçirilse bile ikinci bir kanıt istenerek hesabınız korunur.','İki adımlı doğrulama, giriş yaparken parolanın yanında ikinci bir kanıt ister: telefonunuzdaki doğrulama uygulamasının ürettiği kod, bir güvenlik anahtarı veya SMS ile gelen kod. Parolanız ele geçirilse bile saldırgan bu ikinci adımı geçemez.

Yöntemlerin güvenlik düzeyi farklıdır. Fiziksel güvenlik anahtarları ve doğrulama uygulamaları SMS''e göre daha güvenlidir; çünkü SMS kodları SIM kart kopyalama (SIM swap) gibi yöntemlerle ele geçirilebilir. Yine de SMS ile 2FA, hiç kullanmamaktan çok daha iyidir.

Doğrulama kodunu kimseyle paylaşmayın. Banka, kargo şirketi veya "destek ekibi" olduğunu söyleyen biri sizden bu kodu istiyorsa bu bir dolandırıcılık girişimidir.','Parolaya ek olarak ikinci bir kanıt istenir.
Doğrulama uygulaması ve güvenlik anahtarı SMS''ten daha güvenlidir.
Doğrulama kodunu asla kimseyle paylaşmayın.
Önce e-posta ve bankacılık hesaplarında açın.',5);
INSERT INTO "rehber_konu" VALUES(6,'oltalama','Oltalama (phishing) saldırılarını tanıma','En güçlü parola bile sahte bir sayfaya yazıldığında saldırganın eline geçer.','Oltalama, saldırganın güvenilir bir kurum gibi davranarak sizi sahte bir sayfaya yönlendirmesi ve parolanızı ya da kart bilgilerinizi girmenizi sağlamasıdır. Parolanız ne kadar güçlü olursa olsun, sahte bir sayfaya yazıldığında saldırganın eline geçer.

Uyarı işaretleri şunlardır: aciliyet ve tehdit ("hesabınız 24 saat içinde kapatılacak"), beklenmedik ödül veya kargo bildirimleri, yazım hataları ve gerçeğine çok benzeyen ama farklı alan adları (ör. "paypa1.com"). Adres çubuğundaki kilit simgesi yalnızca bağlantının şifreli olduğunu gösterir; sitenin gerçek olduğunu kanıtlamaz.

Şüpheli bir mesajdaki bağlantıya tıklamak yerine kurumun sitesine adresi kendiniz yazarak gidin. Parola yöneticileri de yardımcı olur: kayıtlı parolayı yalnızca doğru alan adında otomatik doldururlar.','Aciliyet ve tehdit dili bir uyarı işaretidir.
Alan adını harf harf kontrol edin.
Kilit simgesi sitenin gerçek olduğunu kanıtlamaz.
Bağlantıya tıklamak yerine adresi kendiniz yazın.',6);
INSERT INTO "rehber_konu" VALUES(7,'parola-yoneticisi','Parola yöneticileri','Tek bir güçlü ana parolayla, her site için benzersiz parolalar kullanmanın en kolay yolu.','Parola yöneticisi, tüm parolalarınızı şifreli bir kasada saklayan bir uygulamadır. Siz yalnızca tek bir güçlü ana parolayı hatırlarsınız; yönetici her site için uzun, rastgele ve benzersiz parolalar üretir ve sizin yerinize doldurur.

Kasa, ana parolanızdan türetilen bir anahtarla şifrelenir. İyi tasarlanmış yöneticilerde hizmet sağlayıcı bile kasanızın içeriğini göremez. Tarayıcıların yerleşik parola yöneticileri de hiç kullanmamaktan iyidir.

Ana parola bir parola cümlesi olmalı, başka hiçbir yerde kullanılmamalı ve parola yöneticisi hesabında iki adımlı doğrulama mutlaka açık olmalıdır.','Tek bir güçlü ana parola, her site için benzersiz bir parola.
Ana parola için parola cümlesi kullanın.
Parola yöneticisi hesabında 2FA açın.',7);
CREATE TABLE schema_surumu (
               surum            INTEGER PRIMARY KEY,
               dosya            TEXT NOT NULL,
               uygulanma_tarihi TEXT NOT NULL DEFAULT (datetime('now'))
           );
INSERT INTO "schema_surumu" VALUES(1,'001_ilk_sema.sql','2026-11-05 20:22:47');
INSERT INTO "schema_surumu" VALUES(2,'002_oneri_katalogu.sql','2026-11-05 20:22:47');
INSERT INTO "schema_surumu" VALUES(3,'003_kimlik_dogrulama.sql','2026-11-05 20:22:47');
INSERT INTO "schema_surumu" VALUES(4,'004_parola_analizi.sql','2026-11-05 20:22:47');
INSERT INTO "schema_surumu" VALUES(5,'005_rehber_quiz.sql','2026-11-05 20:22:47');
INSERT INTO "schema_surumu" VALUES(6,'006_rehber_icerigi.sql','2026-11-05 20:22:47');
CREATE INDEX ix_analiz_kullanici_tarih ON analiz_kaydi (kullanici_id, analiz_tarihi DESC);
CREATE INDEX ix_analiz_oneri_oneri ON analiz_oneri (oneri_id);
CREATE INDEX ix_quiz_kullanici ON quiz_sonucu (kullanici_id);
CREATE INDEX ix_oturum_kullanici ON oturum (kullanici_id);
CREATE INDEX ix_soru_konu ON quiz_soru (konu_id);
CREATE UNIQUE INDEX ux_secenek_tek_dogru ON quiz_secenek (soru_id) WHERE dogru = 1;
CREATE INDEX ix_deneme_kullanici ON quiz_deneme (kullanici_id);
DELETE FROM "sqlite_sequence";
INSERT INTO "sqlite_sequence" VALUES('oneri',12);
INSERT INTO "sqlite_sequence" VALUES('rehber_konu',7);
INSERT INTO "sqlite_sequence" VALUES('quiz_soru',21);
INSERT INTO "sqlite_sequence" VALUES('quiz_secenek',84);
INSERT INTO "sqlite_sequence" VALUES('kullanici',10);
INSERT INTO "sqlite_sequence" VALUES('analiz_kaydi',24);
INSERT INTO "sqlite_sequence" VALUES('quiz_sonucu',8);
COMMIT;
