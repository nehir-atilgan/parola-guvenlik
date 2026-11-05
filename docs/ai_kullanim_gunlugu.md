# Yapay Zekâ Kullanım Günlüğü

Ders kuralı: Yapay zekâdan alınan her kod parçası **öğrenci tarafından açıklanabilmelidir**. Bu günlük hangi işte yapay zekânın kullanıldığını, ne ürettiğini ve öğrencinin neyi doğrulaması ya da kendisi yapması gerektiğini kayıt altına alır.

- **Kullanılan araç:** Claude (Anthropic)
- **Kullanım biçimi:** Haftalık ders tablosu yapay zekâya verildi. Kod, test ve belgelerin ilk sürümü yapay zekâ tarafından üretildi, otomatik testlerle ve tarayıcıda denenerek doğrulandı, ardından GitHub'a yüklendi.

> ⚠️ **Öğrenciye not:** Ders tablosundaki "Öğrencinin Kendi Geliştireceği Bölümler" satırları, o bölümlerin öğrenci tarafından yazılmasını veya en azından satır satır anlaşılıp gerekçelendirilmesini bekler. Aşağıdaki "Öğrencinin yapması gerekenler" sütununu doldurup sözlüden önce ilgili dosyaları kendiniz açıklayabilecek hale gelin. Bu belgeyi dürüst tutmak, değerlendirmede sizin lehinizedir.

## Haftalık kayıt

| Hafta | Yapay zekânın ürettiği | Doğrulama | Öğrencinin yapması gerekenler / yaptıkları |
|---|---|---|---|
| 3 | Klasör yapısı, frontend/backend ayrımı, ER diyagramı, mimari şema, README, `.gitignore` | Uygulamanın açıldığı tarayıcıda görüldü | Varlıkları ve ilişkileri kendi cümleleriyle açıklayabilmek; klasör/katman yapısını gerekçelendirmek. _(doldurun)_ |
| 4 | Migration 001–002, migration çalıştırıcısı, CRUD repoları, örnek veri, 21 test | `pytest`, örnek sorgular çalıştırıldı | En az bir ilişkiyi (Analiz ↔ Öneri, N-N) elle açıklamak: `docs/veritabani.md`. _(doldurun)_ |
| 5 | Kimlik servisi, oturum tablosu, `@giris_gerekli` / `@rol_gerekli`, giriş/kayıt/panel/yönetici sayfaları | 42 test, tarayıcıda kayıt → giriş → yetkisiz erişim → çıkış | Hash + tuz akışını ve rol kontrolünü kendi başına anlatabilmek. _(doldurun)_ |
| 6 | Parola analiz servisi (ölçütler, desenler, skor), analiz sayfası, migration 004 | 82 test, tarayıcıda örnek parolalar | **Çekirdek mantık:** skor formülünü ve iş kurallarını satır satır açıklamak (`parola_analiz.py`). _(doldurun)_ |
| 7 | Rehber içeriği (7 konu, 21 soru), migration 005–006, quiz servisi, rehber/quiz sayfaları | 115 test, tarayıcıda tam quiz, yenileme sonrası devam, mobil görünüm | **Çekirdek mantık:** soru seçimi, cevap doğrulama ve puanlama (`quiz_servisi.py`). Rehber metinlerini okuyup gerekirse kendi ifadelerinizle düzenleyin. _(doldurun)_ |
| 8 | Entegrasyon testi, Render yayın dosyası, hata düzeltmeleri, `v0.8.0` etiketi, demo senaryosu, bu günlük, ilerleme raporu | 121 test, tarayıcıda uçtan uca senaryo | Demo senaryosunu kendiniz sunmak; canlı linki Render'da açmak. _(doldurun)_ |

## Yapay zekâ önerisinin değiştirildiği / reddedildiği yerler

Bu bölüm, yapay zekânın ilk önerisinin neden değiştirildiğini gösterir. Sözlüde "yapay zekâya körü körüne güvenmedim" demenin kanıtıdır. Kendi örneklerinizi de ekleyin.

| Konu | İlk öneri / durum | Son karar | Neden |
|---|---|---|---|
| Veritabanı | PostgreSQL + SQLAlchemy ORM (Hafta 3) | SQLite + saf SQL (Hafta 4) | Kurulum gerektirmez; SQL açıkça görülür ve açıklanabilir. |
| Proje yapısı | Tek Flask uygulaması, sunucu tarafında HTML (Hafta 3) | `frontend/` + `backend/` ayrımı | Öğrencinin isteği; bağımsız katmanlar. |
| Quiz puanı | `round(d * 100 / n)` | `(d*200 + n) // (2n)` | `round()` 0,5'i çift sayıya yuvarlıyor; test bunu yakaladı (Hafta 8). |
| Canlı yayın | İki ayrı servis (frontend + backend) | Flask frontend'i de sunuyor, tek servis | Tek link, CORS gerekmez, ücretsiz planda tek servis yeterli. |

## Satır satır açıklama örneği (Hafta 8 sözlü sorusu 4)

`backend/app/veri/repolar/quiz_repo.py`:

```python
def puan_hesapla(dogru_sayisi, soru_sayisi):
    if soru_sayisi <= 0:          # 1
        return 0                  # 2
    return (dogru_sayisi * 200 + soru_sayisi) // (2 * soru_sayisi)   # 3
```

1. Sıfıra bölme hatasını önler. Soru yoksa puan 0'dır.
2. Erken dönüş yapılır.
3. Puan normalde `d / n × 100` formülüyle hesaplanır. "Yarım yukarı" yuvarlamak için sonuca 0,5 eklenip aşağı yuvarlanır: `⌊d×100/n + 0,5⌋`. Kesirden kurtulmak için pay ve payda 2 ile çarpılır: `⌊(d×200 + n) / 2n⌋`. `//` tamsayı bölmesidir (aşağı yuvarlar). Örnek: d=1, n=8 → (200+8)//16 = 208//16 = **13** (12,5 → 13).
