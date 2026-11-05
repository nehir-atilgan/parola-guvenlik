# 🔐 Parola Güvenliği ve Sızıntı Farkındalık Aracı

Kullanıcıların parola gücünü analiz eden, parolanın bilinen veri sızıntılarında yer alıp almadığını kontrol eden ve kişiye özel güvenlik önerileri sunan bir **web uygulaması**.

> Bilgisayar Uygulamaları I — Proje Tabanlı Ders · Proje P25 (Siber Güvenlik – Savunma/Farkındalık)

## Problem

Kullanıcılar zayıf ve birden çok hesapta tekrar eden parolalar kullanıyor ve parolalarının sızıntılarda ele geçirildiğinden habersiz kalıyor. Zayıf parola en yaygın güvenlik açığıdır; farkındalık, savunmanın ilk adımıdır.

## Hedef kullanıcılar

Bireysel kullanıcılar ve kurum çalışanları.

## 🌐 Canlı demo

| | |
|---|---|
| **Canlı site** | _Render'da yayınlandıktan sonra buraya eklenecek_ → kurulum: [docs/yayinlama.md](docs/yayinlama.md) |
| Yönetici hesabı | `yonetici@ornek.test` / `Yonetici123` |
| Kullanıcı hesabı | `kullanici@ornek.test` / `Kullanici123` |

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/nehir-atilgan/parola-guvenlik)

> Ücretsiz sunucu 15 dakika kullanılmayınca uyur; ilk açılış 30–60 saniye sürebilir.

## Modüller

| Modül | Durum |
|---|---|
| Kayıt, giriş ve rol tabanlı erişim | ✅ Hafta 5 |
| Parola gücü analizi | ✅ Hafta 6 |
| Farkındalık rehberi (7 konu) + öneri → rehber bağlantısı | ✅ Hafta 7 |
| Farkındalık quizi (21 soruluk banka, 10 soru, 30 dk) | ✅ Hafta 7 |
| **Ara sürüm v0.8.0** (uçtan uca entegrasyon, canlı yayın) | ✅ Hafta 8 |
| Sızıntı kontrolü (Have I Been Pwned API) | ⏳ Hafta 9 |
| Yapay zekâ ile kişisel öneriler, kişisel skor ve rapor | ⏳ Planlandı |

## Teknolojiler

- **Backend:** Python 3, Flask (REST API, JSON)
- **Frontend:** HTML, CSS, JavaScript (fetch ile API'ye bağlanır)
- **Veritabanı:** SQLite, saf SQL ve sürümlü migration dosyaları
- **Yayın:** Render.com (gunicorn), `render.yaml`
- **Harici servisler:** Have I Been Pwned (Pwned Passwords), LLM API

## Klasör yapısı

```
parola-guvenlik/
├── backend/                     # BACKEND — Flask REST API
│   ├── app/
│   │   ├── __init__.py          #   Uygulama fabrikası, frontend'i sunma, güvenlik başlıkları
│   │   ├── config.py            #   Ayarlar (.env'den okunur)
│   │   ├── api/                 #   API KATMANI: /api/... uç noktaları, yetki.py (401/403)
│   │   ├── servisler/           #   İŞ KATMANI: kimlik_servisi (kayıt/giriş/oturum),
│   │   │                        #     parola_analiz (güç ölçütleri, iş kuralları, skor),
│   │   │                        #     quiz_servisi (soru seçimi, cevap doğrulama, puan)
│   │   └── veri/                #   VERİ KATMANI
│   │       ├── migrations/      #     Sürümlü şema dosyaları (001 … 006)
│   │       ├── migrator.py      #     Migration çalıştırıcısı
│   │       ├── repolar/         #     CRUD fonksiyonları (her tablo için)
│   │       └── ornek_veri.py    #     Sentetik örnek veri (KVKK uyumlu)
│   ├── tests/                   #   Otomatik testler
│   ├── .env.example             #   Örnek ortam değişkenleri
│   ├── requirements.txt
│   └── run.py                   #   Backend'i başlatır
├── frontend/                    # FRONTEND — web sitesi
│   ├── index.html               #   Ana sayfa
│   ├── kayit.html / giris.html  #   Kayıt ve giriş
│   ├── panel.html               #   Kullanıcı paneli (giriş gerekli)
│   ├── yonetici.html            #   Kullanıcı yönetimi (yalnızca yönetici)
│   ├── analiz.html              #   Parola Gücü Analizi
│   ├── rehber.html              #   Farkındalık Rehberi (konu listesi ve konu sayfası)
│   ├── quiz.html                #   Farkındalık Quizi
│   ├── css/stil.css
│   └── js/
│       ├── config.js            #   Backend adresi (yerel/canlı otomatik)
│       ├── api.js               #   Backend ile konuşan tek dosya
│       ├── oturum.js            #   Token saklama, menü, sayfa koruma
│       ├── analiz.js            #   Analiz sayfasının mantığı
│       ├── quiz.js              #   Quiz ekranları (giriş, soru, sonuç)
│       └── app.js               #   Sayfa mantığı
├── render.yaml                  # Canlı yayın tanımı (Render.com)
├── CHANGELOG.md                 # Sürüm geçmişi (semantic versioning)
└── docs/
    ├── er_diyagrami.md          # ER diyagramı + normalizasyon
    ├── mimari.md                # Mimari şema
    ├── veritabani.md            # Kısıtlar, indeksler, migration, CRUD açıklaması
    ├── guvenlik_notu.md         # Hash/tuz, oturum, rol tabanlı erişim, OWASP
    ├── parola_gucu_analizi.md   # Analiz modülü: ölçütler, iş kuralları, veri modeli, entegrasyon
    ├── rehber_quiz.md           # Rehber ve quiz: veri modeli, iş kuralları, entegrasyon
    ├── yayinlama.md             # Canlı yayın adımları
    ├── demo_senaryosu.md        # Vize demo akışı
    ├── ilerleme_raporu.md       # v0.8.0 ilerleme raporu
    ├── ai_kullanim_gunlugu.md   # Yapay zekâ kullanım günlüğü
    ├── ornek_sorgular.sql       # Örnek veriyle çalışan sorgular
    └── ornek_veri_dokumu.sql    # Örnek veriyle dolu veritabanının dökümü
```

## Kurulum ve çalıştırma (yerel)

```bash
cd backend
python -m venv venv
venv\Scripts\activate          # macOS/Linux: source venv/bin/activate
pip install -r requirements.txt
copy .env.example .env         # macOS/Linux: cp .env.example .env
flask --app run ornek-veri     # sentetik örnek veriyi ve demo hesaplarını yükler (bir kez)
python run.py
```

Tarayıcıda **http://127.0.0.1:5000** adresini açın. Backend, site sayfalarını da sunar; tek terminal yeterlidir. "● Backend bağlı · sürüm 0.8.0" yazısı görünmelidir.

> Frontend'i ayrı bir sunucudan açmak isterseniz ikinci bir terminalde `cd frontend` ve `python -m http.server 8000` komutlarını çalıştırıp **http://127.0.0.1:8000** adresini açın. `js/config.js` backend adresini kendisi bulur. Dosyayı çift tıklayarak (`file://`) açmak çalışmaz.

**Demo hesapları** (`ornek-veri` komutuyla veya canlıda `ORNEK_VERI=1` ile oluşur; yalnızca demo içindir):

| Rol | E-posta | Parola |
|---|---|---|
| Yönetici | `yonetici@ornek.test` | `Yonetici123` |
| Kullanıcı | `kullanici@ornek.test` | `Kullanici123` |

Kendi hesabınızı yönetici yapmak için: `flask --app run yonetici-yap eposta@adres`

Backend testleri: `backend` klasöründe `pytest`

Veritabanı durumu (uygulanan migration'lar, tablo satır sayıları): `flask --app run db-durum`

Veritabanı ilk çalıştırmada `backend/instance/parola_guvenlik.db` olarak otomatik oluşturulur. İçini görmek için [DB Browser for SQLite](https://sqlitebrowser.org/) kullanılabilir.

## Belgeler

- [ER diyagramı ve veri modeli](docs/er_diyagrami.md)
- [Mimari şema](docs/mimari.md)
- [Veritabanı tasarımı ve veri erişim katmanı](docs/veritabani.md)
- [Örnek sorgular](docs/ornek_sorgular.sql)
- [Güvenlik notu (kimlik doğrulama ve yetkilendirme)](docs/guvenlik_notu.md)
- [Parola Gücü Analizi modülü](docs/parola_gucu_analizi.md)
- [Farkındalık Rehberi ve Quiz modülü](docs/rehber_quiz.md)
- [Canlı yayın](docs/yayinlama.md) · [Demo senaryosu](docs/demo_senaryosu.md) · [İlerleme raporu](docs/ilerleme_raporu.md) · [Yapay zekâ kullanım günlüğü](docs/ai_kullanim_gunlugu.md)
- [Değişiklik günlüğü](CHANGELOG.md)

## Gizlilik ilkesi

Analiz edilen parolalar **hiçbir zaman saklanmaz**. Sızıntı kontrolünde parolanın kendisi değil, SHA-1 özetinin yalnızca ilk 5 karakteri gönderilir (k-anonimlik).

## Haftalık ilerleme

| Hafta | Konu | Durum |
|---|---|---|
| 3 | Kurulum, mimari ve veri modeli | ✅ |
| 4 | Veritabanı tasarımı ve veri erişim katmanı | ✅ |
| 5 | Kullanıcı yönetimi ve kimlik doğrulama | ✅ |
| 6 | Çekirdek Modül A: Parola Gücü Analizi | ✅ |
| 7 | Çekirdek Modül B: Farkındalık Rehberi ve Quiz + Entegrasyon | ✅ |
| 8 | **Vize:** Ara sürüm `v0.8.0`, entegrasyon, canlı yayın | ✅ |
