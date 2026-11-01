-- =====================================================================
-- Örnek sorgular — şema ve örnek veriyle çalışan temel sorgular
-- Çalıştırmak için (backend klasöründe):
--   sqlite3 instance/parola_guvenlik.db < ../docs/ornek_sorgular.sql
-- veya DB Browser for SQLite ile dosyayı açıp "Execute SQL" sekmesine yapıştırın.
-- =====================================================================
.headers on
.mode column

-- 1) CRUD — READ: tüm kullanıcılar
SELECT id, ad_soyad, eposta FROM kullanici;

-- 2) 1-N ilişki + JOIN: her kullanıcının analiz sayısı ve ortalama skoru
SELECT k.ad_soyad,
       COUNT(a.id)              AS analiz_sayisi,
       ROUND(AVG(a.guc_skoru))  AS ortalama_skor
FROM kullanici AS k
LEFT JOIN analiz_kaydi AS a ON a.kullanici_id = k.id
GROUP BY k.id
ORDER BY ortalama_skor DESC;

-- 3) Sızıntıda görülmüş parolaya sahip kullanıcılar
SELECT k.ad_soyad, a.guc_seviyesi, a.sizinti_sayisi
FROM analiz_kaydi AS a
JOIN kullanici AS k ON k.id = a.kullanici_id
WHERE a.sizinti_sayisi > 0
ORDER BY a.sizinti_sayisi DESC;

-- 4) N-N ilişki: 1 numaralı analize verilen öneriler (ara tablo üzerinden iki JOIN)
SELECT ao.oncelik, o.kod, o.baslik
FROM analiz_oneri AS ao
JOIN oneri AS o ON o.id = ao.oneri_id
WHERE ao.analiz_id = 1
ORDER BY ao.oncelik;

-- 5) En sık verilen öneriler
SELECT o.baslik, COUNT(*) AS kac_kez
FROM analiz_oneri AS ao
JOIN oneri AS o ON o.id = ao.oneri_id
GROUP BY o.id
ORDER BY kac_kez DESC;

-- 6) Güç seviyesi dağılımı
SELECT guc_seviyesi, COUNT(*) AS adet
FROM analiz_kaydi
GROUP BY guc_seviyesi;

-- 7) Kullanıcıların en iyi quiz puanı
SELECT k.ad_soyad, MAX(q.puan) AS en_iyi_puan
FROM kullanici AS k
JOIN quiz_sonucu AS q ON q.kullanici_id = k.id
GROUP BY k.id
ORDER BY en_iyi_puan DESC;

-- 8) İndeks kullanımı: sorgu planı "USING INDEX ix_analiz_kullanici_tarih" göstermeli
EXPLAIN QUERY PLAN
SELECT * FROM analiz_kaydi WHERE kullanici_id = 1 ORDER BY analiz_tarihi DESC;
