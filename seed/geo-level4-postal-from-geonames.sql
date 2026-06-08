-- =====================================================================
-- EFSO — Level 4 (Mahalle) + Posta kodu yükleyici  (GeoNames -> geographic)
-- OPERASYONEL ülke bazında çalışır (ülke-parametreli). #126'nın alt-işi.
-- Kaynak: GeoNames (CC BY 4.0)
--   - Dump:   download.geonames.org/export/dump/<CC>.zip   -> <CC>.txt  (19 kolon)
--   - Postal: download.geonames.org/export/zip/<CC>.zip    -> <CC>.txt  (12 kolon)
--
-- Çalıştırma:  psql -v cc=TR -f geo-level4-postal-from-geonames.sql
--   (TR örnek; her operasyonel ülke için cc değiştir.)
--
-- NOT: Operasyonel ülkede tutarlı kod sistemi için L2/L3'ü de GeoNames'ten
--      yeniden kuruyoruz (dr5hn ile karışmasın). admin1/admin2 koduyla parent bağlanır.
-- =====================================================================
\set ON_ERROR_STOP on
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------
-- 0) STAGING tabloları (bir kez) + GeoNames dosyalarını \copy ile yükle
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.geonames_raw (
  geonameid bigint, name text, asciiname text, alternatenames text,
  latitude double precision, longitude double precision,
  feature_class text, feature_code text, country_code text, cc2 text,
  admin1_code text, admin2_code text, admin3_code text, admin4_code text,
  population bigint, elevation int, dem int, timezone text, modification_date text
);
CREATE TABLE IF NOT EXISTS public.geonames_postal (
  country_code text, postal_code text, place_name text,
  admin_name1 text, admin_code1 text, admin_name2 text, admin_code2 text,
  admin_name3 text, admin_code3 text, latitude double precision, longitude double precision, accuracy int
);
-- Yükleme (psql istemcisinde, dosya yolunu düzelt — sekme ayraçlı, tırnaksız):
--   \copy public.geonames_raw    FROM 'TR_dump.txt'   WITH (FORMAT csv, DELIMITER E'\t', QUOTE E'\x01', NULL '')
--   \copy public.geonames_postal FROM 'TR_postal.txt' WITH (FORMAT csv, DELIMITER E'\t', QUOTE E'\x01', NULL '')

BEGIN;

-- ülke düğümü (Level 1)
\set cc :cc
-- (Opsiyonel) Aynı ülkede önceki dr5hn L2/L3/L4'ü pasifле (kod sistemi karışmasın).
-- DİKKAT: bu ülkeye bağlı mevcut adres location_id'leri varsa önce yeniden eşle!
-- UPDATE geographic.locations SET is_deleted=true
--   WHERE country_code = :'cc' AND level IN (2,3,4) AND is_deleted=false;

-- pre-uuid staging (parent bağlamak için)
CREATE TEMP TABLE s_l2 ON COMMIT DROP AS
  SELECT gen_random_uuid() uuid, name, admin1_code a1
  FROM public.geonames_raw
  WHERE country_code = :'cc' AND feature_code = 'ADM1';
CREATE TEMP TABLE s_l3 ON COMMIT DROP AS
  SELECT gen_random_uuid() uuid, name, admin1_code a1, admin2_code a2
  FROM public.geonames_raw
  WHERE country_code = :'cc' AND feature_code = 'ADM2';
CREATE TEMP TABLE s_l4 ON COMMIT DROP AS
  SELECT gen_random_uuid() uuid, geonameid, name, admin1_code a1, admin2_code a2
  FROM public.geonames_raw
  WHERE country_code = :'cc' AND feature_code IN ('ADM3','ADM4','PPLX');  -- mahalle/alt-yerleşim (ülkeye göre ayarla)

-- Level 2
INSERT INTO geographic.locations (id,name,level,country_code,code,parent_id,created_at,is_deleted,concurrency_token)
SELECT s.uuid, left(s.name,100), 2, upper(:'cc'), left(s.a1,10),
       c1.id, now(), false, gen_random_uuid()
FROM s_l2 s
JOIN geographic.locations c1 ON c1.level=1 AND upper(c1.country_code)=upper(:'cc') AND c1.is_deleted=false;

-- Level 3 (parent = L2, admin1 eşleşmesi)
INSERT INTO geographic.locations (id,name,level,country_code,code,parent_id,created_at,is_deleted,concurrency_token)
SELECT s.uuid, left(s.name,100), 3, upper(:'cc'), left(s.a2,10),
       p.uuid, now(), false, gen_random_uuid()
FROM s_l3 s JOIN s_l2 p ON p.a1 = s.a1;

-- Level 4 (parent = L3, admin1+admin2 eşleşmesi)
INSERT INTO geographic.locations (id,name,level,country_code,code,parent_id,created_at,is_deleted,concurrency_token)
SELECT s.uuid, left(s.name,100), 4, upper(:'cc'), left(s.geonameid::text,10),
       p.uuid, now(), false, gen_random_uuid()
FROM s_l4 s JOIN s_l3 p ON p.a1 = s.a1 AND p.a2 = s.a2;

-- ---------------------------------------------------------------------
-- POSTA KODU referans tablosu (doğrulama + posta->yer lookup)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS geographic.postal_codes (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  country_code char(2) NOT NULL, postal_code varchar(20) NOT NULL,
  place_name text, admin_code1 text, admin_code2 text,
  latitude double precision, longitude double precision
);
INSERT INTO geographic.postal_codes (country_code, postal_code, place_name, admin_code1, admin_code2, latitude, longitude)
SELECT upper(p.country_code), p.postal_code, p.place_name, p.admin_code1, p.admin_code2, p.latitude, p.longitude
FROM public.geonames_postal p
WHERE upper(p.country_code) = upper(:'cc')
  AND NOT EXISTS (SELECT 1 FROM geographic.postal_codes e
                  WHERE upper(e.country_code)=upper(p.country_code) AND e.postal_code=p.postal_code);

COMMIT;

-- Özet
SELECT level, count(*) FROM geographic.locations
WHERE country_code = upper(:'cc') AND is_deleted=false GROUP BY level ORDER BY level;
SELECT 'posta kodu', count(*) FROM geographic.postal_codes WHERE country_code=upper(:'cc');

-- =====================================================================
-- NOTLAR
--  * feature_code seçimi ülkeye göre ayarlanır: bazı ülkelerde mahalle 'ADM4',
--    bazılarında 'ADM3' veya 'PPLX'tir. Veriyi inceleyip WHERE listesini güncelle.
--  * code varchar(10): geonameid (<=8 hane) ve admin kodları sığar.
--  * addresses.postal_code doğrulaması ülke-bazlı regex ile (veri rehberi §5).
--    postal_codes tablosu opsiyonel "posta->il/ilçe otomatik doldurma" için kullanılır.
--  * DİKKAT: bir ülkeyi GeoNames'e geçirirken o ülkenin dr5hn L2/L3'ünü pasifле;
--    mevcut adres location_id eşlemelerini go-live öncesi migrate et.
-- =====================================================================
