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
| Parola gücü analizi | ⏳ Planlandı |
| Sızıntı kontrolü (Have I Been Pwned API) | ⏳ Planlandı |
| Öneri ve rehber (yapay zekâ destekli) | ⏳ Planlandı |
| Farkındalık quizi | ⏳ Planlandı |
| Kişisel skor ve rapor | ⏳ Planlandı |

## Teknolojiler

- **Backend:** Python 3, Flask (REST API, JSON)
- **Frontend:** HTML, CSS, JavaScript (fetch ile API'ye bağlanır)
- **Veritabanı:** PostgreSQL (yerel geliştirmede SQLite), SQLAlchemy ORM
- **Harici servisler:** Have I Been Pwned (Pwned Passwords), LLM API

## Klasör yapısı

```
parola-guvenlik/
├── backend/                     # BACKEND — Flask REST API
│   ├── app/
│   │   ├── __init__.py          #   Uygulama fabrikası + CORS
│   │   ├── config.py            #   Ayarlar (.env'den okunur)
│   │   ├── api/                 #   API KATMANI: /api/... uç noktaları
│   │   ├── servisler/           #   İŞ KATMANI: analiz, sızıntı, öneri, quiz, rapor
│   │   └── veri/                #   VERİ KATMANI
│   │       └── models.py        #     Veritabanı tabloları
│   ├── tests/                   #   Otomatik testler
│   ├── .env.example             #   Örnek ortam değişkenleri
│   ├── requirements.txt
│   └── run.py                   #   Backend'i başlatır
├── frontend/                    # FRONTEND — web sitesi
│   ├── index.html
│   ├── css/stil.css
│   └── js/
│       ├── config.js            #   Backend adresi
│       ├── api.js               #   Backend ile konuşan tek dosya
│       └── app.js               #   Sayfa mantığı
└── docs/
    ├── er_diyagrami.md          # ER diyagramı + normalizasyon
    └── mimari.md                # Mimari şema
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
python run.py                  # http://127.0.0.1:5000
```

**2. Terminal — Frontend**

```bash
cd frontend
python -m http.server 8000     # http://127.0.0.1:8000
```

Tarayıcıda **http://127.0.0.1:8000** adresini açın. Sağ üstte "● Backend bağlı" yazısı görünmelidir.

Backend testleri: `backend` klasöründe `pytest`

## Belgeler

- [ER diyagramı ve veri modeli](docs/er_diyagrami.md)
- [Mimari şema](docs/mimari.md)

## Gizlilik ilkesi

Analiz edilen parolalar **hiçbir zaman saklanmaz**. Sızıntı kontrolünde parolanın kendisi değil, SHA-1 özetinin yalnızca ilk 5 karakteri gönderilir (k-anonimlik).

## Haftalık ilerleme

| Hafta | Konu | Durum |
|---|---|---|
| 3 | Kurulum, mimari ve veri modeli | ✅ |
