# Vize Demo Senaryosu (v0.8.0, yaklaşık 6 dakika)

Amaç: **Kullanıcı + veritabanı + çekirdek modüllerin uçtan uca** çalıştığını tek bir akışta göstermek. Her adımda "bu veri nereden geliyor?" sorusunun cevabı da verilir.

> Hazırlık: Sunumdan 2–3 dakika önce canlı linki bir kez açın; ücretsiz sunucu uykudaysa uyanır.

| # | Ekranda yapılacak | Söylenecek | Arkada çalışan |
|---|---|---|---|
| 1 | Ana sayfayı açın | "Frontend ve backend ayrı katmanlar. Canlıda Flask ikisini tek adresten sunuyor. Sağ üstte backend durumu ve sürüm var: 0.8.0." | `GET /api/saglik`, `GET /api/moduller` |
| 2 | **Kayıt ol** → yeni hesap (ör. `deneme@ornek.test`). Önce zayıf parola deneyin. | "Kural backend'de: en az 8 karakter, harf ve rakam. Parola scrypt ve tuz ile hash'lenip saklanıyor." | `POST /api/kayit` → `kimlik_servisi.kayit_ol` → `kullanici` tablosu |
| 3 | **Giriş yap** | "Girişte rastgele bir token üretiliyor; veritabanında token'ın yalnızca SHA-256 özeti duruyor." | `POST /api/giris` → `oturum` tablosu |
| 4 | **Parola Analizi**: `deneme2024` yazın, "kaydet"i işaretleyin | "Skor dökümü: uzunluk, çeşitlilik, benzersizlik, cezalar. E-posta adresimdeki "deneme" parolada geçtiği için kişisel bilgi cezası, "2024" için yıl deseni cezası aldı. Parola hiçbir yerde saklanmıyor; tabloya yalnızca ölçümler yazılıyor." | `POST /api/analiz` → `parola_analiz.analiz_et` → `analiz_kaydi` + `analiz_oneri` (tek işlem) |
| 5 | Önerinin altındaki **Rehberde oku →** | "Öneriler, rehber konularına yabancı anahtarla bağlı. Hafta 6 ile Hafta 7 burada birleşiyor." | `oneri.rehber_konu_id` → `GET /api/rehber/<slug>` |
| 6 | **Quiz** → başlat, 2–3 soru cevaplayın, **sayfayı yenileyin** | "Sayfa yenilense de cevaplar kaybolmuyor ve aynı deneme açılıyor; aynı anda tek açık deneme kuralı. Doğru cevaplar tarayıcıya hiç gelmiyor." | `POST /api/quiz/baslat` → `quiz_deneme`, `quiz_deneme_soru` |
| 7 | Kalanları cevaplayıp **gönderin** | "Puanı sunucu hesaplıyor. Yanlış yaptığım konular rehbere bağlanıyor." | `POST /api/quiz/{id}/gonder` → `quiz_sonucu` |
| 8 | **Panelim** | "Panel, analiz ve quiz modüllerinin verisini tek yerde gösteriyor." | `GET /api/ben` (3 tablodan okur) |
| 9 | Çıkış yapın, adres çubuğuna `…/panel.html` yazın | "Token sunucuda iptal edildi; korumalı sayfa giriş ekranına yönlendiriyor (401)." | `POST /api/cikis` |
| 10 | `yonetici@ornek.test` ile girin → **Yönetici** | "Rol tabanlı erişim: normal kullanıcı bu sayfada 403 alır. Kontrol arayüzde değil backend'de yapılıyor." | `@rol_gerekli("yonetici")` |
| 11 | (İsteğe bağlı) GitHub → **Tags → v0.8.0** ve `pytest` çıktısı | "Ara sürüm etiketlendi. 120'den fazla otomatik test var; uçtan uca senaryo da test ediliyor." | `tests/test_entegrasyon.py` |

## Sık gelebilecek sorular için kısa cevaplar

- **"Hangi modül hangi veriyi nereden alıyor?"** Bkz. [mimari.md](mimari.md), "Modüller arası veri akışı" tablosu.
- **"En çok zorlandığın entegrasyon?"** Bkz. [ilerleme_raporu.md](ilerleme_raporu.md), "Zorluklar".
- **"Bir sonraki aşamanın planı?"** Hafta 9: Have I Been Pwned ile sızıntı sorgusu. `analiz_kaydi.sizinti_sayisi` sütunu ve `SIZINTI_DEGISTIR` önerisi hazır bekliyor.
