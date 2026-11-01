# Güvenlik Notu — Kimlik Doğrulama ve Yetkilendirme (Hafta 5)

## Kimlik doğrulama ve yetkilendirme farkı

| | Soru | Bu projede | Başarısızsa |
|---|---|---|---|
| **Kimlik doğrulama** (authentication) | "Sen kimsin?" | E-posta + parola ile giriş, ardından her istekte token | `401 Unauthorized` |
| **Yetkilendirme** (authorization) | "Bunu yapmaya iznin var mı?" | Rol kontrolü (`kullanici` / `yonetici`) | `403 Forbidden` |

## 1. Parola saklama: hash + tuz

Parolalar **düz metin olarak saklanmaz**. Kayıtta `werkzeug.security.generate_password_hash` ile **scrypt** algoritmasından geçirilir. Veritabanına şöyle bir değer yazılır:

```
scrypt:32768:8:1$Qg1z0DKYjWsuwmzF$e72dfe...
└─ algoritma ve maliyet ─┘└── tuz ──┘└─ hash ─┘
```

- **Hash tek yönlüdür:** Hash'ten parola geri elde edilemez. Girişte, girilen parola aynı tuzla tekrar hash'lenir ve sonuç karşılaştırılır.
- **Tuz (salt):** Her parola için üretilen rastgele bir değerdir. Aynı parola iki kullanıcıda **farklı** hash üretir; önceden hesaplanmış tablolar (rainbow table) işe yaramaz. Bu durum `test_ayni_parola_farkli_hash_uretir` testiyle doğrulanır.
- **Neden scrypt (MD5/SHA-256 değil)?** MD5 ve SHA-256 hızlı çalışmak üzere tasarlanmıştır; saniyede milyarlarca deneme yapılabilir. scrypt ise bilerek yavaştır ve bellek ister, bu da kaba kuvvet saldırısını çok pahalı hale getirir. bcrypt da aynı amaçla kullanılan bir algoritmadır. scrypt Flask ile birlikte gelen kütüphanede hazır bulunduğu için ek bağımlılık gerektirmedi.
- **Site parolası kuralı:** En az 8 karakter, en az bir harf ve bir rakam. Kural backend'de uygulanır.

## 2. Oturum (token) yönetimi

Girişte sunucu, `secrets.token_urlsafe(32)` ile tahmin edilemez **256 bitlik** bir token üretir. Tarayıcı bu token'ı her istekte `Authorization: Bearer <token>` başlığıyla gönderir.

| Önlem | Nasıl |
|---|---|
| Token veritabanında açık saklanmaz | `oturum` tablosunda yalnızca **SHA-256 özeti** tutulur. Veritabanı sızsa bile oturum çalınamaz. |
| Süre sınırı | Her oturum **2 saat** sonra geçersiz olur (`bitis` sütunu). Süresi dolunca kullanıcı giriş sayfasına yönlendirilir. |
| Gerçek çıkış | Çıkışta oturum sunucuda **iptal edilir** (`iptal_edildi = 1`). Token bir yerde kopyalanmış olsa bile artık çalışmaz. |
| Rol değişince oturum kapanır | Yönetici bir kullanıcının rolünü değiştirdiğinde o kullanıcının açık oturumları kapatılır. Eski yetkiyle işlem yapılamaz. |
| Tarayıcı tarafı | Token `sessionStorage`'da tutulur ve sekme kapanınca silinir. |

### Oturum ve token farkı (neden bu yöntem seçildi?)

| | Sunucu oturumu (cookie) | JWT (imzalı token) | **Bu proje** |
|---|---|---|---|
| Durum nerede? | Sunucuda | Token'ın içinde (sunucu bir şey tutmaz) | Sunucuda (`oturum` tablosu) |
| Nasıl gönderilir? | Cookie, otomatik | `Authorization` başlığı | `Authorization` başlığı |
| Çıkış / iptal | Kolay | Zor: token süresi dolana kadar geçerli kalır | Kolay |
| Farklı adresteki frontend | Cookie ayarları gerekir | Kolay | Kolay |

Frontend (`:8000`) ile backend (`:5000`) ayrı adreslerde çalıştığı için token `Authorization` başlığıyla gönderilir. Token'ın kendisi JWT değil, rastgele bir değerdir ve karşılığı veritabanında tutulur. Bu yöntem JWT'nin ayrı adreslerde çalışma kolaylığını sunucu oturumunun **anında iptal edilebilme** özelliğiyle birleştirir. Başlıkla gönderildiği için tarayıcı token'ı başka sitelere otomatik eklemez; bu da CSRF saldırısına karşı koruma sağlar.

## 3. Rol tabanlı erişim (RBAC)

- İki rol vardır: `kullanici` (varsayılan) ve `yonetici`.
- Kayıtta rol **istekten alınmaz**. İsteğe `"rol": "yonetici"` eklense bile hesap `kullanici` olarak açılır (`test_kayitta_rol_gonderilse_bile_yonetici_olunmaz`).
- Kontrol backend'de dekoratörlerle yapılır (`backend/app/api/yetki.py`):

```python
@bp.get("/yonetici/kullanicilar")
@rol_gerekli("yonetici")          # giriş yoksa 401, rol uygun değilse 403
def kullanicilari_listele(): ...
```

- İlk yönetici terminalden atanır: `flask --app run yonetici-yap eposta@adres`
- Yönetici kendi rolünü değiştiremez; böylece sistem yöneticisiz kalamaz.

**Frontend'deki kontroller yalnızca kullanıcı deneyimi içindir.** Menüde "Yönetici" bağlantısını gizlemek ve sayfayı yönlendirmek kolaylık sağlar ama tarayıcıdaki kod değiştirilebilir. Asıl engel, backend'in her istekte rolü kontrol edip `403` döndürmesidir.

## 4. Başarısız giriş denemeleri

- Hata mesajı **her durumda aynıdır**: "E-posta veya parola hatalı." Saldırgan hangi e-postaların kayıtlı olduğunu öğrenemez.
- Kayıtlı olmayan e-postada da sahte bir hash karşılaştırması yapılır. Böylece yanıt süresinden de bilgi sızmaz.
- Art arda **5 hatalı denemede** hesap **15 dakika kilitlenir** (`429`). Kilit süresince doğru parola da kabul edilmez. Başarılı girişte sayaç sıfırlanır.

## 5. Yetkisiz kullanıcı korumalı sayfaya giderse ne olur?

| Durum | Backend | Frontend |
|---|---|---|
| Giriş yapmamış | `401` | Giriş sayfasına yönlendirir ("Bu sayfayı görmek için giriş yapmalısınız") |
| Oturum süresi dolmuş | `401` | Giriş sayfasına yönlendirir ("Oturumunuzun süresi doldu") |
| Giriş yapmış ama yetkisi yok | `403` | "Erişim engellendi" mesajını gösterir, veri yüklenmez |

## OWASP Top 10 ile ilişkisi

| OWASP riski | Bu projedeki önlem |
|---|---|
| **A01 Broken Access Control** | Her korumalı uç noktada backend'de rol kontrolü; kayıtta rol istekten alınmaz |
| **A02 Cryptographic Failures** | Parolalar scrypt ve tuz ile, token'lar SHA-256 özetiyle saklanır |
| **A03 Injection** | Tüm SQL sorguları parametreli (`?`) |
| **A07 Identification & Authentication Failures** | Parola kuralı, hesap kilitleme, oturum süresi, gerçek çıkış, genel hata mesajı |
| **A05 Security Misconfiguration** | CORS yalnızca izinli frontend adresine açık; gizli değerler `.env` dosyasında |

## Bilinen sınırlar (ileride geliştirilebilir)

- `sessionStorage`'daki token XSS açığı olan bir sayfadan okunabilir. Bu yüzden sayfalarda kullanıcı verisi `innerHTML` ile değil, `textContent` ile basılır.
- Kilitleme hesap bazlıdır; IP bazlı hız sınırlama (rate limiting) eklenmedi.
- Yayına alınırken HTTPS zorunludur. Yerel geliştirmede HTTP kullanılıyor.
- Demo hesaplarının (`yonetici@ornek.test` / `Yonetici123`) parolaları bilinmektedir. Bu hesaplar yalnızca yerel geliştirme içindir.
