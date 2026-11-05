# Değişiklik Günlüğü

Sürümler [Semantic Versioning](https://semver.org/lang/tr/) kuralına göre numaralanır: **MAJOR.MINOR.PATCH**

- **MAJOR (1.x.x):** Geriye uyumsuz değişiklik. `1.0.0`, dönem sonu sürümü olacak.
- **MINOR (x.8.x):** Yeni özellik. Bu projede MINOR numarası ders haftasıyla eşleşir.
- **PATCH (x.x.1):** Yalnızca hata düzeltmesi.

`1.0.0`'dan önceki `0.x` sürümleri geliştirme aşamasını gösterir.

## [0.8.0] — 2026-11-05 · Vize ara sürümü (Git etiketi: `v0.8.0`)

### Eklenenler
- **Farkındalık Rehberi** (Hafta 7): 7 konu, konu sayfaları, önceki/sonraki gezinme.
- **Farkındalık Quizi** (Hafta 7): 21 soruluk banka, her quizde 10 soru, 30 dakika süre, soru soru geri bildirim, sayfa yenilenince kaldığı yerden devam.
- Analiz önerilerinden ilgili rehber konusuna bağlantı (Hafta 6 ↔ 7 entegrasyonu).
- **Canlı yayın:** `render.yaml`. Flask frontend'i de sunar ve site tek adresten çalışır.
- `ORNEK_VERI=1` ortam değişkeni: veritabanı boşsa açılışta demo hesaplarını yükler.
- `/api/saglik` yanıtında sürüm numarası; ana sayfada sürüm gösterimi.
- Uçtan uca entegrasyon testi (`tests/test_entegrasyon.py`).
- Belgeler: `rehber_quiz.md`, `yayinlama.md`, `demo_senaryosu.md`, `ai_kullanim_gunlugu.md`, `ilerleme_raporu.md`.

### Düzeltilenler (entegrasyonda bulunan hatalar)
- **Quiz puanı yanlış yuvarlanıyordu:** Python'un `round()` fonksiyonu 0,5'i çift sayıya yuvarlar (`round(12.5) == 12`). 8 sorudan 1 doğru 13 yerine 12 puan veriyordu. Bunun yerine tamsayı aritmetiğiyle "yarım yukarı" yuvarlayan `puan_hesapla` eklendi.
- **Backend adresi sabit yazılmıştı:** `config.js` her zaman `127.0.0.1:5000` adresine bağlanıyordu ve canlı sunucuda site çalışmazdı. Adres artık sayfanın açıldığı yere göre seçiliyor.
- **API yanıtları tarayıcı önbelleğine alınabiliyordu:** Panel ve analiz geçmişi gibi kişisel veriler ortak bilgisayarda önbellekte kalabilirdi. `/api/` yanıtlarına `Cache-Control: no-store` ve `X-Content-Type-Options: nosniff` başlıkları eklendi.
- **Ana sayfadaki hata mesajı** canlı sitede ziyaretçiye "`python run.py` çalıştırın" diyordu. Mesaj artık ortama göre değişiyor (canlıda "sunucu uyanıyor olabilir").
- `flask db-durum` komutu Hafta 7 tablolarını göstermiyordu.

### Değişenler
- `quiz_repo.kullanici_sonuclari` artık sonucu üreten deneme numarasını da döndürüyor.

## [0.6.0] — 2026-11-05 · Hafta 6
- Parola Gücü Analizi modülü: ölçütler, desen tespiti, skor, kırılma süresi, öneriler, analiz geçmişi.

## [0.5.0] — 2026-11-01 · Hafta 5
- Kayıt, giriş, çıkış; scrypt ile parola hash'leme; sunucu tarafında oturum; rol tabanlı erişim; hesap kilitleme.

## [0.4.0] — 2026-11-01 · Hafta 4
- Sürümlü migration'lar, kısıtlar, indeksler, CRUD repoları, KVKK uyumlu örnek veri.

## [0.3.0] — 2026-11-01 · Hafta 3
- Proje iskeleti, frontend/backend ayrımı, katmanlı mimari, ER diyagramı.
