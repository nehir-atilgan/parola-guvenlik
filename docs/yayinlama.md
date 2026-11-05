# Canlı Yayın (Render.com)

Uygulama tek bir web servisi olarak yayınlanır. Flask hem API'yi (`/api/...`) hem de `frontend/` klasöründeki sayfaları sunar. Böylece hoca ve diğer kullanıcılar tek bir link ile siteyi açabilir.

## Bir kerelik kurulum (yaklaşık 5 dakika)

1. Bu bağlantıyı açın: **https://render.com/deploy?repo=https://github.com/nehir-atilgan/parola-guvenlik**
2. **GitHub ile giriş yapın** (Sign in with GitHub). Render ücretsizdir ve kredi kartı istemez.
3. Render, depodaki `render.yaml` dosyasını okur ve `parola-guvenlik` adında bir web servisi önerir. **Deploy Blueprint** / **Apply** düğmesine basın.
4. Kurulum 2–4 dakika sürer. Bitince servis sayfasında `https://parola-guvenlik-xxxx.onrender.com` biçiminde bir adres çıkar. **Canlı link budur.**
5. Bu adresi README'deki "Canlı demo" satırına yazın.

`render.yaml` sayesinde Render ayarları kendisi yapar:

| Ayar | Değer | Neden |
|---|---|---|
| Kök klasör | `backend` | Python uygulaması burada |
| Kurulum | `pip install -r requirements.txt` | |
| Başlatma | `gunicorn run:app --workers 1 --threads 4` | Gunicorn üretim için uygun sunucudur. SQLite tek dosya olduğu için tek işlem kullanılır. |
| `SECRET_KEY` | Render rastgele üretir | Gizli anahtar depoda yer almaz |
| `ORNEK_VERI=1` | Açılışta demo hesapları yüklenir | Hoca hemen giriş yapabilsin |
| Sağlık kontrolü | `/api/saglik` | Render, uygulama çalışmıyorsa yeniden başlatır |

Depoya her `git push` yapıldığında Render siteyi **otomatik olarak günceller** (`autoDeploy: true`).

## Ücretsiz planın bilinmesi gereken iki özelliği

- **Uyku modu:** 15 dakika kimse girmezse sunucu uykuya geçer. Bir sonraki ziyarette ilk açılış **30–60 saniye** sürebilir; sonrası hızlıdır. Sunumdan birkaç dakika önce linki bir kez açmak yeterlidir.
- **Veritabanı kalıcı değildir:** SQLite dosyası sunucunun diskindedir ve sunucu yeniden başladığında veya güncellendiğinde sıfırlanır. Açılışta demo hesapları ve örnek veri yeniden yüklenir. Demo için bu yeterlidir. Kalıcı veri gerekirse Render'ın PostgreSQL servisine geçilebilir; ancak bu ders kapsamı dışındadır.

## Hocanın kullanacağı bilgiler

| | |
|---|---|
| Canlı site | `https://...onrender.com` (yukarıdaki 4. adımda çıkan adres) |
| Kaynak kod | https://github.com/nehir-atilgan/parola-guvenlik |
| Yönetici hesabı | `yonetici@ornek.test` / `Yonetici123` |
| Kullanıcı hesabı | `kullanici@ornek.test` / `Kullanici123` |

Herkes kendi hesabını da oluşturabilir (Kayıt ol).

## Yerelde canlı sürümle aynı şekilde çalıştırmak

```bash
cd backend
python run.py          # http://127.0.0.1:5000 → hem site hem API
```

Frontend'i ayrı sunucudan açmak (`python -m http.server 8000`) da çalışmaya devam eder. `js/config.js` hangi adresten açıldığını algılayıp API adresini kendisi seçer.
