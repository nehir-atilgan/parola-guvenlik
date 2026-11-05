-- =====================================================================
-- Migration 004: Parola Gücü Analizi modülü
--  - analiz_kaydi tablosuna tahmini entropi (bit) sütunu
--  - analizde tespit edilen desenler için yeni öneriler
-- Not: Parolanın kendisi yine HİÇBİR sütunda saklanmaz.
-- =====================================================================

ALTER TABLE analiz_kaydi ADD COLUMN entropi_bit INTEGER NOT NULL DEFAULT 0
    CHECK (entropi_bit >= 0);

INSERT INTO oneri (kod, baslik, aciklama, kategori) VALUES
('YAYGIN_PAROLA', 'Yaygın parola kullanmayın',
 'Bu parola (veya içindeki kelime) en sık kullanılan parolalar arasında. Saldırganlar ilk önce bu listeyi dener.', 'sizinti'),
('KISISEL_BILGI', 'Kişisel bilgilerinizi kullanmayın',
 'Adınız, soyadınız veya e-posta adresiniz gibi bilgiler kolayca tahmin edilir.', 'genel'),
('DESEN_KACIN',   'Tahmin edilebilir desenlerden kaçının',
 '"abc", "123", "qwerty", "aaa" veya doğum yılı gibi desenler parolayı uzun olsa bile zayıflatır.', 'genel');
