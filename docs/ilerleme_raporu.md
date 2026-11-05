# Ara Sürüm İlerleme Raporu: v0.8.0 (Vize, Hafta 8)

**Proje:** P25, Parola Güvenliği ve Sızıntı Farkındalık Aracı
**Depo:** https://github.com/nehir-atilgan/parola-guvenlik · **Etiket:** `v0.8.0`
**Canlı sürüm:** bkz. README, "Canlı demo"

## Özet

Kullanıcı yönetimi, veritabanı ve iki çekirdek modül (Parola Gücü Analizi, Farkındalık Rehberi + Quiz) uçtan uca entegre edildi ve çalışır durumda. Site internetten tek bir link ile açılabiliyor. 121 otomatik testin tamamı geçiyor.

## Planlanan modüllerin durumu

| Modül | Durum | Hafta |
|---|---|---|
| Kayıt, giriş, rol tabanlı erişim | ✅ Tamamlandı | 5 |
| Parola gücü analizi | ✅ Tamamlandı | 6 |
| Öneri ve rehber | ✅ Tamamlandı (kural tabanlı öneriler + rehber). Yapay zekâ ile kişiselleştirme sonraki aşamada. | 6–7 |
| Farkındalık quizi | ✅ Tamamlandı | 7 |
| Sızıntı kontrolü (HIBP) | ⏳ Hafta 9. Veri modeli hazır (`sizinti_sayisi`, `SIZINTI_DEGISTIR`). | 9 |
| Kişisel skor ve rapor | ⏳ Sonraki haftalar. Panel ilk sürümü hazır. | — |

## Sayılarla

| | |
|---|---|
| Migration dosyası | 6 |
| Tablo | 11 (+ migration kayıt tablosu `schema_surumu`) |
| API uç noktası | 19 |
| Sayfa | 8 |
| Otomatik test | 121 (birim + API + uçtan uca) |

## Zorluklar ve çözümler

1. **Doğru cevapların gizlenmesi (quiz):** En basit yöntem, soruları doğru cevaplarıyla birlikte tarayıcıya gönderip puanı orada hesaplamaktır. Ancak bu durumda geliştirici araçlarıyla hile yapılabilir. Bu yüzden deneme kavramı eklendi: sorular sunucuda seçilip kaydediliyor, cevaplar sunucuda puanlanıyor. Bunun bedeli, iki ek tablo (`quiz_deneme`, `quiz_deneme_soru`) ve süre/tek açık deneme kurallarıdır.
2. **Hafta 4 tablosunu bozmadan quiz eklemek:** `quiz_sonucu.puan` alanı `NOT NULL`; devam eden bir quizin henüz puanı yok. Mevcut tabloyu değiştirmek yerine ayrı bir `quiz_deneme` tablosu eklendi ve gönderimde ikisi bağlandı. Önceki migration dosyaları hiç değiştirilmedi.
3. **Canlıya alma:** Frontend ve backend iki ayrı adreste çalışıyordu ve frontend'de backend adresi sabit yazılmıştı. Flask'ın frontend'i de sunması sağlandı; `config.js` adresi kendisi seçiyor.
4. **Yuvarlama hatası:** Testler sırasında `round(12.5) == 12` olduğu fark edildi ve düzeltildi (CHANGELOG).

## Bilinen sınırlamalar

- Ücretsiz sunucu 15 dakika kullanılmayınca uykuya geçer; ilk açılış 30–60 saniye sürebilir.
- Canlı sunucudaki SQLite veritabanı yeniden başlatmada sıfırlanır (demo hesapları otomatik yeniden yüklenir).
- IP bazlı istek sınırlaması (rate limiting) yok; hesap bazlı kilitleme var.

## Sonraki aşama planı (Hafta 9 ve sonrası)

1. **Hafta 9:** Have I Been Pwned "Pwned Passwords" API'si ile k-anonimlik yöntemiyle sızıntı sorgusu. Parola tarayıcıda SHA-1 ile özetlenecek ve yalnızca ilk 5 karakter gönderilecek. Sonuç `analiz_kaydi.sizinti_sayisi` alanına yazılacak.
2. Yapay zekâ destekli kişisel öneriler (`analiz_oneri.kisisel_not` alanı hazır).
3. Kişisel güvenlik skoru ve rapor sayfası (analiz + sızıntı + quiz birleşik skor).
4. Dönem sonunda `v1.0.0`.
