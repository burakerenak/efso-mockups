-- =====================================================================
-- EFSO — Global coğrafya yükleyici (dr5hn countries-states-cities -> geographic.locations)
-- Kaynak: https://github.com/dr5hn/countries-states-cities-database  (PostgreSQL dump)
-- Hedef şema: geographic.locations (level ağacı). TR'ye DOKUNMAZ, idempotenttir.
--
-- ÖN KOŞUL: dr5hn PostgreSQL dump'ı AYNI veritabanına yüklenmiş olmalı:
--   public.countries , public.states , public.cities  (staging tabloları)
-- Çalıştırma adımları için dosyanın sonundaki "NASIL ÇALIŞTIRILIR" notuna bak.
--
-- Eşleme:  ülke -> Level 1 | eyalet/il (states) -> Level 2 | şehir (cities) -> Level 3
--          code: ülke=ISO2, il='S'+kaynak_id, şehir='C'+kaynak_id  (parent join için)
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- gen_random_uuid() garantisi (PG<13 için)

BEGIN;

-- ---------------------------------------------------------------------
-- FAZ 1 — Eksik ÜLKELERİ ekle (mevcut 99 ülke dışındakiler).
-- Mevcut ülkelerine DOKUNMAZ (NOT EXISTS). İstemiyorsan bu bloğu yorum satırı yap.
-- ---------------------------------------------------------------------
INSERT INTO geographic.locations
  (id, name, level, country_code, code, parent_id, created_at, is_deleted, concurrency_token)
SELECT gen_random_uuid(), left(co.name,100), 1, upper(co.iso2), upper(co.iso2),
       NULL, now(), false, gen_random_uuid()
FROM public.countries co
WHERE co.iso2 IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM geographic.locations l
    WHERE l.level = 1 AND upper(l.country_code) = upper(co.iso2) AND l.is_deleted = false
  );

-- ---------------------------------------------------------------------
-- FAZ 2 — EYALET / İL (Level 2).
-- Sadece henüz Level 2 verisi OLMAYAN ülkeler için (TR zaten dolu -> atlanır).
-- ---------------------------------------------------------------------
INSERT INTO geographic.locations
  (id, name, level, country_code, code, parent_id, created_at, is_deleted, concurrency_token)
SELECT gen_random_uuid(), left(s.name,100), 2, upper(s.country_code),
       left('S'||s.id::text,10),
       c1.id, now(), false, gen_random_uuid()
FROM public.states s
JOIN geographic.locations c1
     ON c1.level = 1 AND upper(c1.country_code) = upper(s.country_code) AND c1.is_deleted = false
WHERE NOT EXISTS (
    SELECT 1 FROM geographic.locations e
    WHERE e.level = 2 AND upper(e.country_code) = upper(s.country_code) AND e.is_deleted = false
);

-- ---------------------------------------------------------------------
-- FAZ 3 — ŞEHİR (Level 3).
-- Sadece henüz Level 3 verisi OLMAYAN ülkeler için (TR zaten dolu -> atlanır).
-- Parent = ilgili il (Faz 2'de eklenen, code='S'+state_id).
-- ---------------------------------------------------------------------
INSERT INTO geographic.locations
  (id, name, level, country_code, code, parent_id, created_at, is_deleted, concurrency_token)
SELECT gen_random_uuid(), left(ci.name,100), 3, upper(ci.country_code),
       left('C'||ci.id::text,10),
       st.id, now(), false, gen_random_uuid()
FROM public.cities ci
JOIN geographic.locations st
     ON st.level = 2 AND st.code = left('S'||ci.state_id::text,10) AND st.is_deleted = false
WHERE ci.state_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM geographic.locations e
    WHERE e.level = 3 AND upper(e.country_code) = upper(ci.country_code) AND e.is_deleted = false
);

COMMIT;

-- ---------------------------------------------------------------------
-- ÖZET (yükleme sonrası kontrol)
-- ---------------------------------------------------------------------
SELECT level, count(*) AS adet
FROM geographic.locations WHERE is_deleted = false
GROUP BY level ORDER BY level;

SELECT 'Toplam ülke (L1)' AS metrik, count(*) FROM geographic.locations WHERE level=1 AND is_deleted=false
UNION ALL
SELECT 'L2 olan ülke sayısı', count(DISTINCT country_code) FROM geographic.locations WHERE level=2 AND is_deleted=false
UNION ALL
SELECT 'L3 olan ülke sayısı', count(DISTINCT country_code) FROM geographic.locations WHERE level=3 AND is_deleted=false;

-- =====================================================================
-- NASIL ÇALIŞTIRILIR (psql)
-- ---------------------------------------------------------------------
-- 0) ÖNCE YEDEK AL:  pg_dump -n geographic <db> > yedek.sql
--
-- 1) dr5hn PostgreSQL dosyalarını indir (repo: dr5hn/countries-states-cities-database, /psql klasörü):
--      countries.sql , states.sql , cities.sql   (ya da birleşik world.sql)
--
-- 2) Bunları SENİN veritabanına (geographic'in olduğu DB) yükle -> public.countries/states/cities oluşur:
--      psql -h <host> -U <user> -d <db> -f countries.sql
--      psql -h <host> -U <user> -d <db> -f states.sql
--      psql -h <host> -U <user> -d <db> -f cities.sql
--
-- 3) Bu transform'u çalıştır:
--      psql -h <host> -U <user> -d <db> -f geo-load-from-dr5hn.sql
--
-- 4) (Opsiyonel) Staging tablolarını temizle:
--      DROP TABLE IF EXISTS public.cities, public.states, public.countries CASCADE;
--
-- NOTLAR:
--  * TR ve Level 2/3'ü zaten dolu ülkeler OTOMATİK atlanır (idempotent; tekrar çalıştırılabilir).
--  * Mahalle (Level 4) bu sette YOK -> operasyonel ülkeler için GeoNames'ten ayrıca eklenir.
--  * Eklenen yeni ülke adları İngilizce gelir (dr5hn); istenirse sonradan TR'ye çevrilir.
--  * code alanı 'S'+id / 'C'+id kaynak referansıdır (parent join için); gerçek ISO 3166-2 kodu
--    istenirse ikinci adımda code güncellenebilir.
-- =====================================================================
