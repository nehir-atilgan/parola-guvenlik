# Veritabanı Tasarımı ve Veri Erişim Katmanı (Hafta 4)

## Kullanılan yaklaşım: saf SQL + SQLite

| Karar | Gerekçe |
|---|---|
| **SQLite** | Python ile birlikte gelir, sunucu kurulumu gerekmez, veritabanı tek dosyadır. Ders projesinin ölçeği için yeterlidir. Kullanıcı sayısı büyürse migration dosyaları küçük değişikliklerle PostgreSQL'e taşınabilir. |
| **Saf SQL (ORM yerine)** | Her sorgu açıkça görülür ve açıklanabilir. Ek kütüphane gerekmez. ORM (ör. SQLAlchemy) kodu kısaltır ama arka planda üretilen SQL'i gizler; öğrenme aşamasında SQL'i doğrudan yazmak tercih edildi. |
| **Parametreli sorgular (`?`)** | Kullanıcı girdisi SQL metnine asla birleştirilmez. Bu, SQL enjeksiyonunu engeller. |

## Migration nedir, neden kullanıldı?

Migration, veritabanı şemasındaki her değişikliğin **numaralı ve sıralı bir dosya** olarak saklanmasıdır. Kod Git'te nasıl sürümleniyorsa şema da migration'larla sürümlenir.

```
backend/app/veri/migrations/
├── 001_ilk_sema.sql        → 5 tablo, ilişkiler, kısıtlar, indeksler
└── 002_oneri_katalogu.sql  → öneri kataloğunun başlangıç kayıtları
```

- `migrator.py` dosyası uygulama her başladığında bekleyen migration'ları sırayla uygular.
- Uygulananlar `schema_surumu` tablosuna yazılır, bu yüzden hiçbir dosya iki kez çalışmaz.
- Her migration tek bir **işlem (transaction)** içinde çalışır. Ortada bir hata olursa o dosyanın hiçbir değişikliği kalmaz.
- Şema değişeceği zaman eski dosya düzenlenmez; yeni bir dosya eklenir (ör. `003_...sql`). Böylece ekipteki herkesin veritabanı aynı adımlardan geçer.

## Kısıtlar (constraints)

| Kısıt | Nerede | Ne sağlar |
|---|---|---|
| `PRIMARY KEY` | Tüm tablolarda `id`; `analiz_oneri`'de (`analiz_id`, `oneri_id`) | Her satır benzersiz tanımlanır; aynı öneri bir analize iki kez eklenemez. |
| `FOREIGN KEY ... REFERENCES` | `analiz_kaydi.kullanici_id`, `quiz_sonucu.kullanici_id`, `analiz_oneri.*` | Var olmayan bir kullanıcıya analiz eklenemez (referans bütünlüğü). |
| `ON DELETE CASCADE` | Kullanıcı → analiz, quiz; analiz → analiz_oneri | Kullanıcı silinince ona ait tüm kayıtlar da silinir; sahipsiz kayıt kalmaz. |
| `ON DELETE RESTRICT` | `analiz_oneri.oneri_id` | Bir analizde kullanılmış öneri katalogdan silinemez. |
| `UNIQUE` | `kullanici.eposta`, `oneri.kod` | Aynı e-postayla iki hesap açılamaz. |
| `NOT NULL` | Zorunlu alanlar | Eksik veri girilemez. |
| `CHECK` | `guc_skoru BETWEEN 0 AND 100`, `guc_seviyesi IN ('zayif','orta','guclu')`, `dogru_sayisi <= soru_sayisi` vb. | Mantıksız değerler veritabanı seviyesinde reddedilir. |

> SQLite'ta yabancı anahtar kontrolü **varsayılan olarak kapalıdır**. Bu yüzden her bağlantıda `PRAGMA foreign_keys = ON` çalıştırılır (`app/veri/__init__.py`).

## İndeksler

| İndeks | Hızlandırdığı sorgu |
|---|---|
| `ix_analiz_kullanici_tarih (kullanici_id, analiz_tarihi DESC)` | "Kullanıcının analizlerini en yeniden eskiye getir." Raporda ve geçmiş ekranında en sık çalışan sorgu budur. |
| `ix_analiz_oneri_oneri (oneri_id)` | "Bu öneri hangi analizlerde verildi?" Bileşik anahtar `analiz_id` ile başladığı için bu sorgu o anahtarı kullanamaz. |
| `ix_quiz_kullanici (kullanici_id)` | Kullanıcının quiz sonuçları. |

İndeks okumayı hızlandırır ama her eklemede güncellenmesi gerekir ve yer kaplar. Bu yüzden yalnızca sık çalışan `WHERE`/`ORDER BY` sorgularına indeks eklendi. `oneri` tablosuna indeks eklenmedi, çünkü yalnızca 9 satır var. `UNIQUE` sütunlara (eposta, kod) SQLite indeksi zaten otomatik oluşturur.

Doğrulama: `EXPLAIN QUERY PLAN` çıktısında `USING INDEX ix_analiz_kullanici_tarih` görülür (`docs/ornek_sorgular.sql`, sorgu 8).

## Elle yazılmış ilişki açıklaması: Analiz ↔ Öneri (N-N)

Bir analize birden çok öneri verilir (ör. "uzunluğu artır" + "2FA aç"). Aynı öneri de birçok analizde kullanılır. Bu, **çoka-çok (N-N)** ilişkidir.

İlişkisel veritabanında N-N doğrudan kurulamaz. Önerileri analiz tablosunda `"UZUNLUK_ARTIR,IKI_FAKTOR"` gibi tek bir metin alanına yazmak **1NF'yi bozar** (sütun atomik olmaz, sorgulanamaz). Bu yüzden ilişki, iki adet 1-N ilişkiye bölünür ve arada bir **ara tablo** kurulur:

```sql
CREATE TABLE analiz_oneri (
    analiz_id    INTEGER NOT NULL REFERENCES analiz_kaydi(id) ON DELETE CASCADE,
    oneri_id     INTEGER NOT NULL REFERENCES oneri(id)        ON DELETE RESTRICT,
    oncelik      INTEGER NOT NULL DEFAULT 1 CHECK (oncelik BETWEEN 1 AND 5),
    kisisel_not  TEXT,
    PRIMARY KEY (analiz_id, oneri_id)
);
```

- Her satır "şu analize şu öneri verildi" bilgisidir.
- `PRIMARY KEY (analiz_id, oneri_id)` bileşik anahtardır ve aynı eşleşmenin iki kez eklenmesini engeller.
- `oncelik` ve `kisisel_not` ne yalnızca analize ne de yalnızca öneriye aittir; **eşleşmenin kendisine** aittir. Bu yüzden ara tabloda durur (2NF).
- Analiz silinirse eşleşmeler de silinir (`CASCADE`). Öneri ise kullanımdayken silinemez (`RESTRICT`), çünkü geçmiş raporlar bozulmasın.

Okurken iki `JOIN` ile birleştirilir:

```sql
SELECT o.baslik, ao.oncelik
FROM analiz_oneri ao
JOIN oneri o ON o.id = ao.oneri_id
WHERE ao.analiz_id = ?;
```

## CRUD veri erişim fonksiyonları

`backend/app/veri/repolar/` klasöründe her tablo için bir modül vardır:

| Modül | Create | Read | Update | Delete |
|---|---|---|---|---|
| `kullanici_repo` | `olustur` | `getir`, `eposta_ile_getir`, `listele` | `guncelle` | `sil` |
| `analiz_repo` | `olustur`, `oneri_ekle` | `getir`, `kullanici_analizleri`, `analiz_onerileri` | `sizinti_guncelle` | `sil` |
| `oneri_repo` | `olustur` | `listele`, `kod_ile_getir` | `guncelle` | `sil` |
| `quiz_repo` | `olustur` | `kullanici_sonuclari`, `en_iyi_puan` | – | `sil` |

### Örnek: bir CRUD işleminin SQL'i (kullanıcı ekleme)

```python
con.execute(
    "INSERT INTO kullanici (ad_soyad, eposta, sifre_hash) VALUES (?, ?, ?)",
    (ad_soyad, eposta.strip().lower(), sifre_hash),
)
con.commit()
```

1. `INSERT INTO kullanici (...)` komutu hangi tabloya ve hangi sütunlara yazılacağını belirtir. `id` ve `kayit_tarihi` yazılmaz, çünkü veritabanı bunları kendisi üretir (`AUTOINCREMENT`, `DEFAULT`).
2. `VALUES (?, ?, ?)` yer tutucudur. Değerler ayrı bir parametre olarak gönderilir ve SQL metnine eklenmez. Bu sayede `eposta` alanına zararlı SQL yazılsa bile komut olarak çalışmaz.
3. E-posta küçük harfe çevrilir; `UNIQUE` kısıtı aynı adresin büyük harfli bir kopyasını da yakalar.
4. `commit()` işlemi kalıcı hale getirir. Kısıtlardan biri bozulursa (ör. e-posta zaten varsa) `IntegrityError` oluşur ve kayıt eklenmez.

## Örnek (sentetik) veri — KVKK uyumu

`flask --app run ornek-veri` komutu 10 kullanıcı (2 demo hesabı + 8 test kullanıcısı), 24 analiz, 108 analiz–öneri eşleşmesi ve 8 quiz sonucu üretir.

- Adlar "Test Kullanıcı N" şeklindedir; e-postalar `@ornek.test` alan adındadır. `.test` alan adı internette ayrılmıştır ve gerçek posta alamaz.
- Analiz kayıtları gerçek parolalardan değil, rastgele üretilmiş ölçümlerden oluşur.
- Sabit tohum (`seed=42`) kullanıldığı için her çalıştırmada aynı veri oluşur.
- Veri dökümü `docs/ornek_veri_dokumu.sql` dosyasındadır.

## DDL / DML

- **DDL** (Data Definition Language), yapıyı tanımlar: `CREATE TABLE`, `CREATE INDEX`, `ALTER`, `DROP`. Migration 001 baştan sona DDL'dir.
- **DML** (Data Manipulation Language), veriyi işler: `INSERT`, `SELECT`, `UPDATE`, `DELETE`. Migration 002 ve repo fonksiyonlarının hepsi DML'dir.
