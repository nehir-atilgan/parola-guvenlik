-- =====================================================================
-- Migration 002: Öneri kataloğunun başlangıç verisi
-- Bu kayıtlar uygulamanın çalışması için gereklidir (örnek veri değildir).
-- =====================================================================

INSERT INTO oneri (kod, baslik, aciklama, kategori) VALUES
('UZUNLUK_ARTIR',   'Parolanızı uzatın',                 'En az 12, tercihen 16 karakterlik parolalar kullanın. Uzunluk, parola gücünü en çok artıran etkendir.', 'uzunluk'),
('PAROLA_CUMLESI',  'Parola cümlesi kullanın',           'Birbiriyle ilgisiz 4-5 kelimeden oluşan bir cümle hem güçlü hem de akılda kalıcıdır.',              'uzunluk'),
('BUYUK_HARF_EKLE', 'Büyük harf ekleyin',                'Büyük harf kullanmak olası karakter sayısını artırır.',                                             'cesitlilik'),
('RAKAM_EKLE',      'Rakam ekleyin',                     'Rakamları başa veya sona değil, parolanın içine dağıtın.',                                          'cesitlilik'),
('OZEL_KARAKTER',   'Özel karakter ekleyin',             '!, ?, #, % gibi özel karakterler tahmin edilmeyi zorlaştırır.',                                     'cesitlilik'),
('SIZINTI_DEGISTIR','Parolanızı hemen değiştirin',       'Bu parola bilinen veri sızıntılarında görülmüş. Kullandığınız her hesapta değiştirin.',            'sizinti'),
('TEKRAR_KULLANMA', 'Her hesapta farklı parola kullanın','Bir sitede sızan parola, aynı parolayı kullandığınız tüm hesapları tehlikeye atar.',                'tekrar'),
('PAROLA_YONETICI', 'Parola yöneticisi kullanın',        'Parola yöneticisi her site için güçlü ve benzersiz parola üretip saklar.',                         'genel'),
('IKI_FAKTOR',      'İki adımlı doğrulamayı açın',       'Parolanız ele geçirilse bile 2FA hesabınıza girilmesini engeller.',                                 '2fa');
