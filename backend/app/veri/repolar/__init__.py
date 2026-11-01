"""CRUD fonksiyonları. Her tablo için ayrı bir modül vardır.

Tüm fonksiyonlar ilk parametre olarak bir veritabanı bağlantısı (con) alır.
Bu sayede aynı fonksiyonlar hem web isteklerinde hem testlerde hem de
örnek veri betiğinde kullanılabilir.

Güvenlik: SQL'e değerler HER ZAMAN `?` yer tutucularıyla verilir,
asla metin birleştirme (f-string) ile eklenmez → SQL enjeksiyonu engellenir.
"""
