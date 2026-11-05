# 🔐 Parola Güvenliği ve Sızıntı Farkındalık Aracı

Kullanıcıların parola gücünü analiz eden, parolanın bilinen veri sızıntılarında yer alıp almadığını kontrol eden ve kişiye özel güvenlik önerileri sunan bir **web uygulaması**.

> Bilgisayar Uygulamaları I — Proje Tabanlı Ders · Proje P25 (Siber Güvenlik – Savunma/Farkındalık)

## Problem

Kullanıcılar zayıf ve birden çok hesapta tekrar eden parolalar kullanıyor ve parolalarının sızıntılarda ele geçirildiğinden habersiz kalıyor. Zayıf parola en yaygın güvenlik açığıdır; farkındalık, savunmanın ilk adımıdır.

## Hedef kullanıcılar

Bireysel kullanıcılar ve kurum çalışanları.

## Modüller

| Modül | Durum |
|---|---|
| Parola gücü analizi | ✅ Hafta 6 |
| Sızıntı kontrolü (Have I Been Pwned API) | ⏳ Planlandı |
| Öneri ve rehber (yapay zekâ destekli) | ⏳ Planlandı |
| Kayıt, giriş ve rol tabanlı erişim | ✅ Hafta 5 |
| Farkındalık quizi | ⏳ Planlandı |
| Kişisel skor ve rapor | ⏳ Planlandı |

## Teknolojiler

- **Backend:** Python 3, Flask (REST API, JSON)
- **Frontend:** HTML, CSS, JavaScript (fetch ile API'ye bağlanır)
- **Veritabanı:** SQLite, saf SQL ve sürümlü migration dosyaları
- **Harici servisler:** Have I Been Pwned (Pwned Passwords), LLM API

## Klasör yapısı

```
parola-guvenlik/
├── backend/                     # BACKEND — Flask REST API
│   ├── app/
│   │   ├── __init__.py          #   Uygulama fabrikası + CORS
│   │   ├── config.py            #   Ayarlar (.env'den okunur)
│   │   ├── api/                 #   API KATMANI: /api/... uç noktaları, yetki.py (401/403)
│   │   ├── servisler/           #   İŞ KATMANI: kimlik_servisi (kayıt/giriş/oturum),
│   │   │                        #     parola_analiz (güç ölçütleri, iş kuralları, skor)
│   │   └── veri/                #   VERİ KATMANI
│   │       ├── migrations/      #     Sürümlü şema dosyaları (001, 002 ...)
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
│   ├── css/stil.css
│   └── js/
│       ├── config.js            #   Backend adresi
│       ├── api.js               #   Backend ile konuşan tek dosya
│       ├── oturum.js            #   Token saklama, menü, sayfa koruma
│       ├── analiz.js            #   Analiz sayfasının mantığı
│       └── app.js               #   Sayfa mantığı
└── docs/
    ├── er_diyagrami.md          # ER diyagramı + normalizasyon
    ├── mimari.md                # Mimari şema
    ├── veritabani.md            # Kısıtlar, indeksler, migration, CRUD açıklaması
    ├── guvenlik_notu.md         # Hash/tuz, oturum, rol tabanlı erişim, OWASP
    ├── parola_gucu_analizi.md   # Analiz modülü: ölçütler, iş kuralları, veri modeli, entegrasyon
    ├── ornek_sorgular.sql       # Örnek veriyle çalışan sorgular
    └── ornek_veri_dokumu.sql    # Örnek veriyle dolu veritabanının dökümü
```

## Kurulum ve çalıştırma

İki ayrı terminal açın.

**1. Terminal — Backend**

```bash
cd backend
python -m venv venv
venv\Scripts\activate          # macOS/Linux: source venv/bin/activate
pip install -r requirements.txt
copy .env.example .env         # macOS/Linux: cp .env.example .env
flask --app run ornek-veri     # sentetik örnek veriyi yükler (bir kez)
python run.py                  # http://127.0.0.1:5000
```

**2. Terminal — Frontend**

```bash
cd frontend
python -m http.server 8000     # http://127.0.0.1:8000
```

Tarayıcıda **http://127.0.0.1:8000** adresini açın. "● Backend bağlı" yazısı görünmelidir.

> ⚠️ Frontend'i **127.0.0.1:8000** adresinden açın. `localhost:8000` da izinlidir; dosyayı çift tıklayarak (`file://`) açarsanız backend bağlantısı çalışmaz.

**Demo hesapları** (`ornek-veri` komutuyla oluşur, yalnızca yerel geliştirme içindir):

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

## Gizlilik ilkesi

Analiz edilen parolalar **hiçbir zaman saklanmaz**. Sızıntı kontrolünde parolanın kendisi değil, SHA-1 özetinin yalnızca ilk 5 karakteri gönderilir (k-anonimlik).

## Haftalık ilerleme

| Hafta | Konu | Durum |
|---|---|---|
| 3 | Kurulum, mimari ve veri modeli | ✅ |
| 4 | Veritabanı tasarımı ve veri erişim katmanı | ✅ |
| 5 | Kullanıcı yönetimi ve kimlik doğrulama | ✅ |
| 6 | Çekirdek Modül A: Parola Gücü Analizi | ✅ |
