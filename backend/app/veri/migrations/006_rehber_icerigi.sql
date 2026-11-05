-- =====================================================================
-- Migration 006: Farkındalık Rehberi içeriği ve quiz soru bankası (Hafta 7)
-- 7 konu, 21 soru, her soruda 4 seçenek ve tek doğru cevap.
-- Sorular metinleriyle, seçenekler soru metni üzerinden bağlanır (id'ler sabit kodlanmaz).
-- =====================================================================

-- 1. Güçlü parola nasıl oluşturulur?
INSERT INTO rehber_konu (slug, baslik, ozet, icerik, anahtar_noktalar, sira) VALUES (
  'guclu-parola', 'Güçlü parola nasıl oluşturulur?', 'Uzunluk, çeşitlilik ve tahmin edilemezlik bir parolayı güçlü yapar.',
  'Saldırganlar parolaları iki yolla bulmaya çalışır: olası tüm kombinasyonları tek tek dener (kaba kuvvet) ya da daha önce sızmış parola ve sözlük listelerini dener. Güçlü bir parola her iki yönteme de dayanıklı olmalıdır.

Uzunluk en önemli etkendir. Her ek karakter, denenmesi gereken kombinasyon sayısını katlayarak artırır. Bu yüzden 8 karakterlik bir parolayı kırmak, aynı türden 16 karakterlik bir parolayı kırmaktan milyarlarca kat daha kolaydır.

Büyük harf, küçük harf, rakam ve özel karakter kullanmak karakter havuzunu büyütür. Ancak "Parola1!" gibi bilinen bir kalıba sıkıştırılmış çeşitlilik pek işe yaramaz. Adınız, doğum yılınız, tuttuğunuz takım, "123" veya "qwerty" gibi tahmin edilebilir parçalardan kaçının. Harfleri benzer simgelerle değiştirmek ("P@r0la") de yeterli değildir; saldırı araçları bu değişiklikleri otomatik olarak dener.',
  'En az 12, tercihen 16 karakter kullanın.
Kişisel bilgi, takım adı ve sözlük kelimesi kullanmayın.
Klavye ve sayı dizilerinden (qwerty, 123456) kaçının.
Her hesap için farklı bir parola kullanın.', 1);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'guclu-parola'), 'Bir parolanın gücünü en çok artıran özellik hangisidir?', 'Her ek karakter olası kombinasyon sayısını katlayarak artırır; uzunluk tek başına en etkili ölçüttür.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Bir parolanın gücünü en çok artıran özellik hangisidir?'), 'Uzunluğu', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Bir parolanın gücünü en çok artıran özellik hangisidir?'), 'Sonuna ünlem işareti eklenmesi', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Bir parolanın gücünü en çok artıran özellik hangisidir?'), 'İlk harfinin büyük yazılması', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Bir parolanın gücünü en çok artıran özellik hangisidir?'), 'İçinde doğum yılının bulunması', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'guclu-parola'), 'Aşağıdakilerden hangisi en güçlü parola adayıdır?', 'Uzun ve birbiriyle ilgisiz kelimelerden oluşuyor. Diğerleri yaygın bir kelime, bilinen bir simge değişikliği veya kişisel bilgi içeriyor.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi en güçlü parola adayıdır?'), 'mavi-kalem-rüzgar-otobüs-71', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi en güçlü parola adayıdır?'), 'Galatasaray1905', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi en güçlü parola adayıdır?'), 'P@ssw0rd!', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi en güçlü parola adayıdır?'), 'Ahmet1990', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'guclu-parola'), '"Parola" kelimesinin harflerini simgelerle değiştirmek ("P@r0la") parolayı neden yeterince güçlü yapmaz?', 'Harf–simge değişiklikleri (a→@, o→0) o kadar yaygındır ki sözlük saldırısı araçları bunları kendiliğinden dener.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = '"Parola" kelimesinin harflerini simgelerle değiştirmek ("P@r0la") parolayı neden yeterince güçlü yapmaz?'), 'Saldırı araçları bu tür değişiklikleri otomatik olarak dener', 1),
  ((SELECT id FROM quiz_soru WHERE metin = '"Parola" kelimesinin harflerini simgelerle değiştirmek ("P@r0la") parolayı neden yeterince güçlü yapmaz?'), 'Özel karakterler sitelerde kabul edilmez', 0),
  ((SELECT id FROM quiz_soru WHERE metin = '"Parola" kelimesinin harflerini simgelerle değiştirmek ("P@r0la") parolayı neden yeterince güçlü yapmaz?'), 'Simgeler parolayı kısaltır', 0),
  ((SELECT id FROM quiz_soru WHERE metin = '"Parola" kelimesinin harflerini simgelerle değiştirmek ("P@r0la") parolayı neden yeterince güçlü yapmaz?'), 'Büyük harf içermediği için', 0);

-- 2. Parola cümlesi: uzun ama akılda kalıcı
INSERT INTO rehber_konu (slug, baslik, ozet, icerik, anahtar_noktalar, sira) VALUES (
  'parola-cumlesi', 'Parola cümlesi: uzun ama akılda kalıcı', 'Rastgele seçilmiş birkaç kelime, karmaşık kısa parolalardan hem daha güçlü hem daha kolay hatırlanır.',
  'Parola cümlesi, birbiriyle anlam ilişkisi olmayan 4–6 kelimenin birleştirilmesiyle oluşturulur; örneğin "turuncu-vapur-kaktüs-defter". Böyle bir parola hem uzundur hem de karmaşık simgelerden oluşan kısa parolalara göre çok daha kolay hatırlanır.

Kelimeler rastgele seçilmelidir. Bilinen bir şarkı sözü, atasözü veya film repliği sözlük saldırısı listelerinde yer alır ve parola cümlesinin avantajını ortadan kaldırır.

Site kuralları rakam veya özel karakter istiyorsa kelimelerin arasına ayraç (-, .) ve bir rakam eklenebilir. Parola cümlesinin asıl gücünü ise rastgele seçilmiş kelimelerin sayısı sağlar.',
  '4–6 rastgele ve birbiriyle ilgisiz kelime seçin.
Şarkı sözü, atasözü ve replik kullanmayın.
Gerekirse kelimeler arasına ayraç ve rakam ekleyin.', 2);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'parola-cumlesi'), 'Aşağıdakilerden hangisi iyi bir parola cümlesidir?', 'Rastgele ve ilgisiz kelimelerden oluşuyor. Atasözleri ve sık kullanılan ifadeler sözlük listelerinde yer alır; tekrar eden harfler de kolay tahmin edilir.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi iyi bir parola cümlesidir?'), 'kedi-bulut-çekiç-mavi-elma', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi iyi bir parola cümlesidir?'), 'Ağaç yaş iken eğilir', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi iyi bir parola cümlesidir?'), 'seni çok seviyorum', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi iyi bir parola cümlesidir?'), 'aaaa-bbbb-cccc-dddd', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'parola-cumlesi'), 'Bir parola cümlesinin gücünü asıl sağlayan nedir?', 'Her rastgele kelime, tahmin edilmesi gereken olasılık sayısını büyük ölçüde artırır.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Bir parola cümlesinin gücünü asıl sağlayan nedir?'), 'Rastgele seçilmiş kelimelerin sayısı', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Bir parola cümlesinin gücünü asıl sağlayan nedir?'), 'İçindeki özel karakter sayısı', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Bir parola cümlesinin gücünü asıl sağlayan nedir?'), 'Kelimelerin Türkçe olması', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Bir parola cümlesinin gücünü asıl sağlayan nedir?'), 'Kelimelerin büyük harfle başlaması', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'parola-cumlesi'), 'Parola cümlesi için kelimeler nasıl seçilmelidir?', 'Anlamlı bir cümle veya kişisel isimler tahmin edilebilir; rastgelelik parolayı güçlü kılar.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola cümlesi için kelimeler nasıl seçilmelidir?'), 'Birbiriyle ilgisiz ve rastgele', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola cümlesi için kelimeler nasıl seçilmelidir?'), 'Sevdiğiniz bir şarkının ilk dizesinden', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola cümlesi için kelimeler nasıl seçilmelidir?'), 'Aile üyelerinizin isimlerinden', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola cümlesi için kelimeler nasıl seçilmelidir?'), 'Aynı kelimeyi birkaç kez tekrarlayarak', 0);

-- 3. Aynı parolayı tekrar kullanmanın riski
INSERT INTO rehber_konu (slug, baslik, ozet, icerik, anahtar_noktalar, sira) VALUES (
  'tekrar-kullanim', 'Aynı parolayı tekrar kullanmanın riski', 'Tek bir sızıntı, aynı parolayı kullandığınız tüm hesapları tehlikeye atar.',
  'Bir site saldırıya uğrayıp kullanıcı bilgileri sızdığında, saldırganlar bu e-posta ve parola çiftlerini başka sitelerde de otomatik olarak dener. Bu saldırıya "credential stuffing" (kimlik bilgisi doldurma) denir.

Aynı parolayı birden çok hesapta kullanan biri için tek bir sızıntı; e-posta, sosyal medya ve bankacılık hesaplarının hepsinin ele geçirilmesi anlamına gelebilir. Parolanın güçlü olması bu durumda koruma sağlamaz, çünkü saldırgan parolayı tahmin etmez; onu zaten bilir.

Bu yüzden her hesabın kendine özgü bir parolası olmalıdır. "Parola1-facebook", "Parola1-gmail" gibi küçük değişiklikler de güvenli değildir; saldırganlar bu kalıpları kolayca dener.',
  'Her hesap için ayrı bir parola kullanın.
Tek bir sızıntı tüm hesapları riske atabilir.
Parolaya site adı eklemek gibi küçük değişiklikler yeterli değildir.
Parola yöneticisi bu işi kolaylaştırır.', 3);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'tekrar-kullanim'), '"Credential stuffing" saldırısı nedir?', 'Saldırgan parolayı tahmin etmez; bir sitede sızan bilgileri, aynı parolanın kullanıldığı diğer sitelerde dener.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = '"Credential stuffing" saldırısı nedir?'), 'Sızan e-posta–parola çiftlerinin başka sitelerde denenmesi', 1),
  ((SELECT id FROM quiz_soru WHERE metin = '"Credential stuffing" saldırısı nedir?'), 'Parolanın tüm kombinasyonlarının tek tek denenmesi', 0),
  ((SELECT id FROM quiz_soru WHERE metin = '"Credential stuffing" saldırısı nedir?'), 'Sahte bir e-postayla parola istenmesi', 0),
  ((SELECT id FROM quiz_soru WHERE metin = '"Credential stuffing" saldırısı nedir?'), 'Klavye tuş vuruşlarının kaydedilmesi', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'tekrar-kullanim'), 'Aynı güçlü parolayı tüm hesaplarınızda kullanırsanız ne olur?', 'Parola sızdığında gücü önemini yitirir; saldırgan onu bildiği için diğer hesaplarda doğrudan kullanabilir.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Aynı güçlü parolayı tüm hesaplarınızda kullanırsanız ne olur?'), 'Bir sitedeki sızıntı diğer hesaplarınızı da tehlikeye atar', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aynı güçlü parolayı tüm hesaplarınızda kullanırsanız ne olur?'), 'Parola güçlü olduğu için risk oluşmaz', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aynı güçlü parolayı tüm hesaplarınızda kullanırsanız ne olur?'), 'Yalnızca sızıntının olduğu sitedeki hesap etkilenir', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aynı güçlü parolayı tüm hesaplarınızda kullanırsanız ne olur?'), 'Siteler aynı parolanın kullanılmasına izin vermez', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'tekrar-kullanim'), 'Aşağıdakilerden hangisi güvenli bir yaklaşımdır?', 'Her hesapta benzersiz ve rastgele bir parola, bir sızıntının diğer hesaplara yayılmasını engeller.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi güvenli bir yaklaşımdır?'), 'Her hesap için parola yöneticisinin ürettiği farklı bir parola', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi güvenli bir yaklaşımdır?'), 'Ana parolanın sonuna site adını eklemek', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi güvenli bir yaklaşımdır?'), 'Önemsiz siteler için hep aynı parolayı kullanmak', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi güvenli bir yaklaşımdır?'), 'Parolaları masadaki bir kâğıda yazmak', 0);

-- 4. Veri sızıntıları ve sızıntı kontrolü
INSERT INTO rehber_konu (slug, baslik, ozet, icerik, anahtar_noktalar, sira) VALUES (
  'veri-sizintilari', 'Veri sızıntıları ve sızıntı kontrolü', 'Sızan parolalar yıllarca kullanılır; parolanızın sızıp sızmadığı, parolanız paylaşılmadan kontrol edilebilir.',
  'Veri sızıntısı, bir kurumun sakladığı kullanıcı bilgilerinin yetkisiz kişilerin eline geçmesidir. Sızan veriler çoğu zaman internette paylaşılır veya satılır ve yıllarca yeni saldırılarda kullanılır.

Have I Been Pwned gibi servisler, bilinen sızıntılarda yer alan yüz milyonlarca parolayı bir araya getirir. Parolanız kontrol edilirken k-anonimlik yöntemi kullanılır: parolanın kendisi değil, özetinin (hash) yalnızca ilk 5 karakteri gönderilir. Servis bu önekle başlayan tüm özetleri döndürür ve eşleşme sizin tarafınızda aranır. Böylece servis parolanızı hiçbir zaman öğrenmez.

Parolanız bir sızıntıda görünüyorsa, onu kullandığınız her hesapta hemen değiştirin ve bu parolayı bir daha kullanmayın. Önemli hesaplarınızda iki adımlı doğrulamayı da açın.',
  'Sızan parolalar yıllarca saldırılarda kullanılır.
k-anonimlik: parolanın kendisi hiçbir zaman gönderilmez.
Sızmış bir parolayı kullandığınız her yerde değiştirin.', 4);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'veri-sizintilari'), 'Sızıntı kontrolü yapan servisler k-anonimlik yöntemiyle ne gönderir?', 'Yalnızca özetin kısa bir öneki gönderildiği için servis hangi parolanın sorgulandığını bilemez.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Sızıntı kontrolü yapan servisler k-anonimlik yöntemiyle ne gönderir?'), 'Parola özetinin yalnızca ilk 5 karakterini', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Sızıntı kontrolü yapan servisler k-anonimlik yöntemiyle ne gönderir?'), 'Parolanın kendisini', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Sızıntı kontrolü yapan servisler k-anonimlik yöntemiyle ne gönderir?'), 'Parolanın şifrelenmiş tam halini', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Sızıntı kontrolü yapan servisler k-anonimlik yöntemiyle ne gönderir?'), 'E-posta adresinizi ve parolanızı', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'veri-sizintilari'), 'Parolanızın bir sızıntıda yer aldığını öğrendiniz. Ne yapmalısınız?', 'Sızan parola listeleri tüm sitelerde denenir; aynı parolanın kullanıldığı her hesap risk altındadır.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Parolanızın bir sızıntıda yer aldığını öğrendiniz. Ne yapmalısınız?'), 'Bu parolayı kullandığınız tüm hesaplarda değiştirmelisiniz', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parolanızın bir sızıntıda yer aldığını öğrendiniz. Ne yapmalısınız?'), 'Yalnızca sızıntının olduğu sitede değiştirmelisiniz', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parolanızın bir sızıntıda yer aldığını öğrendiniz. Ne yapmalısınız?'), 'Parolanın sonuna bir rakam eklemelisiniz', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parolanızın bir sızıntıda yer aldığını öğrendiniz. Ne yapmalısınız?'), 'Sızıntı eskiyse bir şey yapmanıza gerek yoktur', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'veri-sizintilari'), 'Sızan parolalar neden yıllar sonra bile tehlikelidir?', 'Sızıntı listeleri birleştirilip yeniden paylaşılır; değiştirilmemiş parolalar yıllar sonra da işe yarar.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Sızan parolalar neden yıllar sonra bile tehlikelidir?'), 'Saldırganlar sızıntı listelerini sürekli yeni saldırılarda kullanır', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Sızan parolalar neden yıllar sonra bile tehlikelidir?'), 'Sızıntılar bir süre sonra kendiliğinden silinir', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Sızan parolalar neden yıllar sonra bile tehlikelidir?'), 'Eski parolalar kırılamaz', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Sızan parolalar neden yıllar sonra bile tehlikelidir?'), 'Siteler eski parolaları kabul etmez', 0);

-- 5. İki adımlı doğrulama (2FA)
INSERT INTO rehber_konu (slug, baslik, ozet, icerik, anahtar_noktalar, sira) VALUES (
  'iki-adimli-dogrulama', 'İki adımlı doğrulama (2FA)', 'Parolanız ele geçirilse bile ikinci bir kanıt istenerek hesabınız korunur.',
  'İki adımlı doğrulama, giriş yaparken parolanın yanında ikinci bir kanıt ister: telefonunuzdaki doğrulama uygulamasının ürettiği kod, bir güvenlik anahtarı veya SMS ile gelen kod. Parolanız ele geçirilse bile saldırgan bu ikinci adımı geçemez.

Yöntemlerin güvenlik düzeyi farklıdır. Fiziksel güvenlik anahtarları ve doğrulama uygulamaları SMS''e göre daha güvenlidir; çünkü SMS kodları SIM kart kopyalama (SIM swap) gibi yöntemlerle ele geçirilebilir. Yine de SMS ile 2FA, hiç kullanmamaktan çok daha iyidir.

Doğrulama kodunu kimseyle paylaşmayın. Banka, kargo şirketi veya "destek ekibi" olduğunu söyleyen biri sizden bu kodu istiyorsa bu bir dolandırıcılık girişimidir.',
  'Parolaya ek olarak ikinci bir kanıt istenir.
Doğrulama uygulaması ve güvenlik anahtarı SMS''ten daha güvenlidir.
Doğrulama kodunu asla kimseyle paylaşmayın.
Önce e-posta ve bankacılık hesaplarında açın.', 5);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'iki-adimli-dogrulama'), 'İki adımlı doğrulamanın temel faydası nedir?', 'Saldırgan parolayı bilse bile ikinci kanıta (kod, anahtar) sahip olmadığı için giriş yapamaz.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'İki adımlı doğrulamanın temel faydası nedir?'), 'Parola ele geçirilse bile hesaba girişi engeller', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'İki adımlı doğrulamanın temel faydası nedir?'), 'Parolayı daha uzun hale getirir', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'İki adımlı doğrulamanın temel faydası nedir?'), 'Parolayı hatırlamayı kolaylaştırır', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'İki adımlı doğrulamanın temel faydası nedir?'), 'Veri sızıntılarını tamamen önler', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'iki-adimli-dogrulama'), 'Aşağıdaki 2FA yöntemlerinden hangisi genellikle en zayıf olanıdır?', 'SMS kodları SIM kart kopyalama gibi yöntemlerle ele geçirilebilir; yine de hiç 2FA kullanmamaktan iyidir.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdaki 2FA yöntemlerinden hangisi genellikle en zayıf olanıdır?'), 'SMS ile gelen kod', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdaki 2FA yöntemlerinden hangisi genellikle en zayıf olanıdır?'), 'Doğrulama uygulaması', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdaki 2FA yöntemlerinden hangisi genellikle en zayıf olanıdır?'), 'Fiziksel güvenlik anahtarı', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdaki 2FA yöntemlerinden hangisi genellikle en zayıf olanıdır?'), 'Geçiş anahtarı (passkey)', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'iki-adimli-dogrulama'), 'Arayan biri "Bankadan arıyorum, size gelen doğrulama kodunu söyler misiniz?" diyor. Ne yapmalısınız?', 'Kurumlar doğrulama kodunu asla telefonla istemez; bu bir sosyal mühendislik girişimidir.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Arayan biri "Bankadan arıyorum, size gelen doğrulama kodunu söyler misiniz?" diyor. Ne yapmalısınız?'), 'Kodu vermeden aramayı bitirip bankayı resmi numarasından aramalısınız', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Arayan biri "Bankadan arıyorum, size gelen doğrulama kodunu söyler misiniz?" diyor. Ne yapmalısınız?'), 'Bankadan aradığı için kodu söylemelisiniz', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Arayan biri "Bankadan arıyorum, size gelen doğrulama kodunu söyler misiniz?" diyor. Ne yapmalısınız?'), 'Kodun yalnızca yarısını söylemelisiniz', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Arayan biri "Bankadan arıyorum, size gelen doğrulama kodunu söyler misiniz?" diyor. Ne yapmalısınız?'), 'Kodu SMS ile göndermelisiniz', 0);

-- 6. Oltalama (phishing) saldırılarını tanıma
INSERT INTO rehber_konu (slug, baslik, ozet, icerik, anahtar_noktalar, sira) VALUES (
  'oltalama', 'Oltalama (phishing) saldırılarını tanıma', 'En güçlü parola bile sahte bir sayfaya yazıldığında saldırganın eline geçer.',
  'Oltalama, saldırganın güvenilir bir kurum gibi davranarak sizi sahte bir sayfaya yönlendirmesi ve parolanızı ya da kart bilgilerinizi girmenizi sağlamasıdır. Parolanız ne kadar güçlü olursa olsun, sahte bir sayfaya yazıldığında saldırganın eline geçer.

Uyarı işaretleri şunlardır: aciliyet ve tehdit ("hesabınız 24 saat içinde kapatılacak"), beklenmedik ödül veya kargo bildirimleri, yazım hataları ve gerçeğine çok benzeyen ama farklı alan adları (ör. "paypa1.com"). Adres çubuğundaki kilit simgesi yalnızca bağlantının şifreli olduğunu gösterir; sitenin gerçek olduğunu kanıtlamaz.

Şüpheli bir mesajdaki bağlantıya tıklamak yerine kurumun sitesine adresi kendiniz yazarak gidin. Parola yöneticileri de yardımcı olur: kayıtlı parolayı yalnızca doğru alan adında otomatik doldururlar.',
  'Aciliyet ve tehdit dili bir uyarı işaretidir.
Alan adını harf harf kontrol edin.
Kilit simgesi sitenin gerçek olduğunu kanıtlamaz.
Bağlantıya tıklamak yerine adresi kendiniz yazın.', 6);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'oltalama'), 'Aşağıdakilerden hangisi oltalama mesajının tipik bir işaretidir?', 'Saldırganlar düşünmeden hareket etmeniz için aciliyet ve korku yaratır. Logo ve ad gibi ayrıntılar kolayca taklit edilebilir.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi oltalama mesajının tipik bir işaretidir?'), '"Hesabınız 24 saat içinde kapatılacak, hemen giriş yapın" gibi aciliyet', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi oltalama mesajının tipik bir işaretidir?'), 'Mesajda sizin adınızın geçmesi', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi oltalama mesajının tipik bir işaretidir?'), 'Mesajda kurum logosunun bulunması', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Aşağıdakilerden hangisi oltalama mesajının tipik bir işaretidir?'), 'Mesajın Türkçe yazılmış olması', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'oltalama'), 'Bir e-postadaki bağlantının gerçek olup olmadığından emin olmak için en doğru yol hangisidir?', 'Sahte sayfalar birebir kopyalanabilir ve kilit simgesine sahip olabilir; adresi kendiniz yazmak sahte bağlantıyı devre dışı bırakır.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Bir e-postadaki bağlantının gerçek olup olmadığından emin olmak için en doğru yol hangisidir?'), 'Kurumun sitesine adresi kendiniz yazarak gitmek', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Bir e-postadaki bağlantının gerçek olup olmadığından emin olmak için en doğru yol hangisidir?'), 'Bağlantıya tıklayıp sayfanın tasarımına bakmak', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Bir e-postadaki bağlantının gerçek olup olmadığından emin olmak için en doğru yol hangisidir?'), 'E-postadaki telefon numarasını aramak', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Bir e-postadaki bağlantının gerçek olup olmadığından emin olmak için en doğru yol hangisidir?'), 'Sayfada kilit simgesi varsa güvenmek', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'oltalama'), 'Parola yöneticisi oltalamaya karşı nasıl korur?', 'Sahte "paypa1.com" sitesinde parola yöneticisi doldurma önermez; bu da bir uyarı işaretidir.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola yöneticisi oltalamaya karşı nasıl korur?'), 'Kayıtlı parolayı yalnızca doğru alan adında otomatik doldurur', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola yöneticisi oltalamaya karşı nasıl korur?'), 'Sahte e-postaları otomatik olarak siler', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola yöneticisi oltalamaya karşı nasıl korur?'), 'Bağlantılara tıklamayı engeller', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola yöneticisi oltalamaya karşı nasıl korur?'), 'Parolayı her gün değiştirir', 0);

-- 7. Parola yöneticileri
INSERT INTO rehber_konu (slug, baslik, ozet, icerik, anahtar_noktalar, sira) VALUES (
  'parola-yoneticisi', 'Parola yöneticileri', 'Tek bir güçlü ana parolayla, her site için benzersiz parolalar kullanmanın en kolay yolu.',
  'Parola yöneticisi, tüm parolalarınızı şifreli bir kasada saklayan bir uygulamadır. Siz yalnızca tek bir güçlü ana parolayı hatırlarsınız; yönetici her site için uzun, rastgele ve benzersiz parolalar üretir ve sizin yerinize doldurur.

Kasa, ana parolanızdan türetilen bir anahtarla şifrelenir. İyi tasarlanmış yöneticilerde hizmet sağlayıcı bile kasanızın içeriğini göremez. Tarayıcıların yerleşik parola yöneticileri de hiç kullanmamaktan iyidir.

Ana parola bir parola cümlesi olmalı, başka hiçbir yerde kullanılmamalı ve parola yöneticisi hesabında iki adımlı doğrulama mutlaka açık olmalıdır.',
  'Tek bir güçlü ana parola, her site için benzersiz bir parola.
Ana parola için parola cümlesi kullanın.
Parola yöneticisi hesabında 2FA açın.', 7);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'parola-yoneticisi'), 'Parola yöneticisi kullanırken hatırlamanız gereken tek parola hangisidir?', 'Diğer tüm parolalar ana parolayla korunan kasada saklanır.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola yöneticisi kullanırken hatırlamanız gereken tek parola hangisidir?'), 'Ana parola', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola yöneticisi kullanırken hatırlamanız gereken tek parola hangisidir?'), 'E-posta parolanız', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola yöneticisi kullanırken hatırlamanız gereken tek parola hangisidir?'), 'Banka parolanız', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola yöneticisi kullanırken hatırlamanız gereken tek parola hangisidir?'), 'Hiçbiri, parola gerekmez', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'parola-yoneticisi'), 'Ana parola için en uygun seçim hangisidir?', 'Ana parola tüm kasayı korur; uzun, benzersiz ve tahmin edilemez olmalıdır.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Ana parola için en uygun seçim hangisidir?'), 'Başka yerde kullanılmayan uzun bir parola cümlesi', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Ana parola için en uygun seçim hangisidir?'), 'E-posta parolanızla aynı parola', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Ana parola için en uygun seçim hangisidir?'), 'Kısa ama özel karakterli bir parola', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Ana parola için en uygun seçim hangisidir?'), 'Doğum tarihiniz', 0);
INSERT INTO quiz_soru (konu_id, metin, aciklama) VALUES (
  (SELECT id FROM rehber_konu WHERE slug = 'parola-yoneticisi'), 'Parola yöneticisinin en büyük faydası nedir?', 'Benzersiz parolalar sayesinde bir sitedeki sızıntı diğer hesaplarınızı etkilemez.');
INSERT INTO quiz_secenek (soru_id, metin, dogru) VALUES
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola yöneticisinin en büyük faydası nedir?'), 'Her site için güçlü ve benzersiz parolaları üretip saklaması', 1),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola yöneticisinin en büyük faydası nedir?'), 'Parolaları kısaltması', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola yöneticisinin en büyük faydası nedir?'), 'Veri sızıntılarını tamamen engellemesi', 0),
  ((SELECT id FROM quiz_soru WHERE metin = 'Parola yöneticisinin en büyük faydası nedir?'), 'İki adımlı doğrulamayı gereksiz kılması', 0);

-- Her öneriyi ilgili rehber konusuna bağla (analiz sayfasında "Rehberde oku" bağlantısı)
UPDATE oneri SET rehber_konu_id = (SELECT id FROM rehber_konu WHERE slug = 'guclu-parola') WHERE kod = 'UZUNLUK_ARTIR';
UPDATE oneri SET rehber_konu_id = (SELECT id FROM rehber_konu WHERE slug = 'guclu-parola') WHERE kod = 'BUYUK_HARF_EKLE';
UPDATE oneri SET rehber_konu_id = (SELECT id FROM rehber_konu WHERE slug = 'guclu-parola') WHERE kod = 'RAKAM_EKLE';
UPDATE oneri SET rehber_konu_id = (SELECT id FROM rehber_konu WHERE slug = 'guclu-parola') WHERE kod = 'OZEL_KARAKTER';
UPDATE oneri SET rehber_konu_id = (SELECT id FROM rehber_konu WHERE slug = 'guclu-parola') WHERE kod = 'YAYGIN_PAROLA';
UPDATE oneri SET rehber_konu_id = (SELECT id FROM rehber_konu WHERE slug = 'guclu-parola') WHERE kod = 'KISISEL_BILGI';
UPDATE oneri SET rehber_konu_id = (SELECT id FROM rehber_konu WHERE slug = 'guclu-parola') WHERE kod = 'DESEN_KACIN';
UPDATE oneri SET rehber_konu_id = (SELECT id FROM rehber_konu WHERE slug = 'parola-cumlesi') WHERE kod = 'PAROLA_CUMLESI';
UPDATE oneri SET rehber_konu_id = (SELECT id FROM rehber_konu WHERE slug = 'tekrar-kullanim') WHERE kod = 'TEKRAR_KULLANMA';
UPDATE oneri SET rehber_konu_id = (SELECT id FROM rehber_konu WHERE slug = 'veri-sizintilari') WHERE kod = 'SIZINTI_DEGISTIR';
UPDATE oneri SET rehber_konu_id = (SELECT id FROM rehber_konu WHERE slug = 'iki-adimli-dogrulama') WHERE kod = 'IKI_FAKTOR';
UPDATE oneri SET rehber_konu_id = (SELECT id FROM rehber_konu WHERE slug = 'parola-yoneticisi') WHERE kod = 'PAROLA_YONETICI';
