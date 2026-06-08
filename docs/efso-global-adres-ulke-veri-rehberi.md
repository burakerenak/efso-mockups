# EFSO — Global Adres: Ülke Kırılım & Posta Kodu Veri Rehberi

> Kaynak modeli: `geographic.locations` (level ağacı) + `geographic.addresses` (postal_code). Bu doküman, ülkeye göre **seviye-caption** + **posta kodu formatı/aralığı** referansı ve **gerçek veriyi yükleme planı**dır. 2026-06-07.

---

## 0. Mevcut durum (paylaşılan `geographic_backup.sql`)
- **Yapı doğru ve generic:** `locations(id, name, level, country_code, code, parent_id, …)` + `addresses(id, country_code, location_id, address_line1/2, postal_code, latitude, longitude, …)`.
- **Veri (33.471 satır):**
  - **Türkiye TAM:** 81 İl → 1.010 İlçe → 32.281 Mahalle.
  - **Diğer 98 ülke:** yalnız **Level 1** (ülke düğümü) var; alt kırılım yok.
- **Posta kodu** `locations`'ta değil, **`addresses.postal_code`**'ta tutuluyor (her adres için). → Posta kodu = adres-seviyesi alan; bu doküman ülke bazında **format/aralık kuralını** verir, doğrulama (regex) için kullanılır.

> ⚠️ Tüm dünyanın İl/İlçe/Mahalle düğüm verisi **elle üretilmez** (milyonlarca satır). Yetkili veri setinden **import** edilir (bkz. §4). Bu doküman: referans kuralları + import planı.

---

## 1. Seviye → Türkçe caption mantığı (hatırlatma)
Level 1 = **Ülke**. Alt seviyeler ülkeye göre değişir; UI'da **Türkçe caption** gösterilir, yapı (level) sabittir.

| Genel anlam | Tipik Türkçe caption(lar) |
|---|---|
| Level 2 (Region/State) | İl · Eyalet · Bölge · Emirlik · Kontluk |
| Level 3 (Sub-region) | İlçe · County · Vilayet · Departman |
| Level 4 (Locality) | Şehir · Belediye · Mahalle/Semt |
| Level 5 (Neighborhood) | Mahalle · Semt |

---

## 2. Ülke bazında kırılım + posta kodu formatı (referans)
> Posta formatında: `N`=rakam, `A`=harf. "Aralık/Not" ulusal genel aralığı/kuralı verir. Caption'lar Türkçe.

### 2.1 Avrupa
| ISO2 | Ülke | L2 | L3 | L4 | Posta formatı | Örnek | Aralık / Not |
|---|---|---|---|---|---|---|---|
| TR | Türkiye | İl | İlçe | Mahalle | NNNNN | 34710 | 01000–81999 · ilk 2 = il plaka |
| DE | Almanya | Eyalet | İlçe (Kreis) | Şehir | NNNNN | 10115 | 01067–99998 · ilk hane bölge 0–9 |
| FR | Fransa | Bölge | İl (Département) | Belediye | NNNNN | 75008 | 01000–98890 · ilk 2 = département |
| GB | İngiltere | Kontluk | İlçe | Şehir/Kasaba | AANA NAA | SW1A 1AA | Alfanümerik (outward+inward), aralık yok |
| IT | İtalya | Bölge | İl | Belediye | NNNNN | 00184 | 00010–98168 |
| ES | İspanya | Özerk Bölge | İl | Belediye | NNNNN | 28013 | 01001–52080 · ilk 2 = provincia |
| NL | Hollanda | İl | Belediye | Şehir | NNNN AA | 1011 AB | 1000–9999 + 2 harf |
| BE | Belçika | Bölge | İl | Belediye | NNNN | 1000 | 1000–9992 |
| PT | Portekiz | Bölge | İl | Belediye | NNNN-NNN | 1100-148 | — |
| CH | İsviçre | Kanton | İlçe | Belediye | NNNN | 8001 | 1000–9658 |
| AT | Avusturya | Eyalet | İlçe | Belediye | NNNN | 1010 | 1000–9992 |
| PL | Polonya | Voyvodalık | İlçe (Powiat) | Belediye | NN-NNN | 00-001 | — |
| SE | İsveç | İl (Län) | Belediye | — | NNN NN | 114 55 | — |
| NO | Norveç | İl (Fylke) | Belediye | — | NNNN | 0010 | 0001–9991 |
| DK | Danimarka | Bölge | Belediye | — | NNNN | 1050 | 1000–9990 |
| FI | Finlandiya | Bölge | Belediye | — | NNNNN | 00100 | — |
| GR | Yunanistan | Bölge | İl | Belediye | NNN NN | 104 31 | — |
| RU | Rusya | Federal Birim/Oblast | İlçe (Raion) | Şehir | NNNNNN | 101000 | — |
| UA | Ukrayna | Oblast | İlçe | Şehir | NNNNN | 01001 | — |
| RO | Romanya | İl (Județ) | — | Belediye | NNNNNN | 010011 | — |
| CZ | Çekya | Bölge | İlçe (Okres) | Belediye | NNN NN | 110 00 | — |
| HU | Macaristan | İl (Megye) | İlçe (Járás) | Şehir | NNNN | 1051 | 1000–9985 |
| BG | Bulgaristan | İl (Oblast) | Belediye | — | NNNN | 1000 | — |
| HR | Hırvatistan | İl (Županija) | Belediye | — | NNNNN | 10000 | — |
| RS | Sırbistan | Bölge | İlçe | Belediye | NNNNN | 11000 | — |
| IE | İrlanda | Kontluk | Şehir | — | ANN ANNA | A65 F4E2 | Eircode (alfanümerik) |

### 2.2 Orta Doğu & Körfez
| ISO2 | Ülke | L2 | L3 | L4 | Posta formatı | Örnek | Aralık / Not |
|---|---|---|---|---|---|---|---|
| AE | BAE | Emirlik | — | Şehir/Bölge | **— (yok)** | — | Posta kodu yok → **PO Box** |
| SA | S. Arabistan | Bölge | İl (Governorate) | Şehir/Mahalle | NNNNN(-NNNN) | 12214 | Yeni sistem 5(+4) hane |
| QA | Katar | Belediye | — | Bölge | **— (yok)** | — | Posta kodu yok |
| KW | Kuveyt | Vilayet | Bölge | — | NNNNN | 13001 | — |
| BH | Bahreyn | Vilayet | Blok | — | NNN/NNNN | 317 | 3–4 hane |
| OM | Umman | Vilayet | İlçe | — | NNN | 100 | 3 hane |
| IL | İsrail | Bölge | İl | Şehir | NNNNNNN | 9100001 | 7 hane |
| JO | Ürdün | İl | İlçe | — | NNNNN | 11118 | — |
| LB | Lübnan | Vilayet | İlçe (Kaza) | — | NNNN NNNN | 1107 2020 | — |
| IR | İran | Eyalet (Ostan) | İl | Şehir | NNNNN-NNNNN | 11369-13141 | 10 hane |
| IQ | Irak | Vilayet | İlçe | — | NNNNN | 10001 | — |

### 2.3 Asya
| ISO2 | Ülke | L2 | L3 | L4 | Posta formatı | Örnek | Aralık / Not |
|---|---|---|---|---|---|---|---|
| CN | Çin | Eyalet (Sheng) | Şehir | İlçe (Qu) | NNNNNN | 100000 | 6 hane · ilk 2 il |
| JP | Japonya | Eyalet (Prefecture) | Şehir (Shi) | İlçe (Ku) | NNN-NNNN | 100-0001 | 7 hane |
| KR | G. Kore | Bölge | Şehir | İlçe (Gu) | NNNNN | 03187 | 2015'ten 5 hane |
| IN | Hindistan | Eyalet | İl (District) | Şehir | NNNNNN | 110001 | PIN · ilk hane bölge |
| PK | Pakistan | Eyalet | İlçe | Şehir | NNNNN | 44000 | — |
| BD | Bangladeş | Bölge | İlçe (Zila) | — | NNNN | 1000 | — |
| TH | Tayland | İl (Changwat) | İlçe (Amphoe) | — | NNNNN | 10100 | ilk 2 il |
| VN | Vietnam | İl | İlçe | — | NNNNNN | 100000 | 6 hane (2020+) |
| ID | Endonezya | İl (Provinsi) | İlçe (Kabupaten) | Şehir | NNNNN | 10110 | — |
| MY | Malezya | Eyalet | İlçe | — | NNNNN | 50000 | — |
| SG | Singapur | — | — | Bölge | NNNNNN | 238801 | 6 hane (sektör) |
| PH | Filipinler | Bölge | İl | Şehir | NNNN | 1000 | — |

### 2.4 Amerika
| ISO2 | Ülke | L2 | L3 | L4 | Posta formatı | Örnek | Aralık / Not |
|---|---|---|---|---|---|---|---|
| US | ABD | Eyalet | İlçe (County) | Şehir | NNNNN(-NNNN) | 10001 | 00501–99950 · ilk hane bölge (bkz §3.2) |
| CA | Kanada | Eyalet | — | Şehir | ANA NAN | K1A 0B1 | ilk harf = bölge |
| MX | Meksika | Eyalet | Belediye | — | NNNNN | 06000 | — |
| BR | Brezilya | Eyalet | Şehir | Mahalle (Bairro) | NNNNN-NNN | 01310-100 | CEP |
| AR | Arjantin | İl | İlçe (Partido) | — | ANNNNAAA | C1425DKG | — |
| CL | Şili | Bölge | İl | Belediye | NNNNNNN | 8320000 | 7 hane |
| CO | Kolombiya | İl (Departamento) | Belediye | — | NNNNNN | 110111 | — |
| PE | Peru | Bölge | İl | İlçe | NNNNN | 15001 | — |

### 2.5 Afrika & Okyanusya
| ISO2 | Ülke | L2 | L3 | L4 | Posta formatı | Örnek | Aralık / Not |
|---|---|---|---|---|---|---|---|
| EG | Mısır | Vilayet | İlçe | — | NNNNN | 11511 | — |
| ZA | G. Afrika | Eyalet | Belediye | — | NNNN | 0001 | 0001–9999 |
| MA | Fas | Bölge | İl | Şehir | NNNNN | 10000 | — |
| DZ | Cezayir | Vilayet (Wilaya) | İlçe | — | NNNNN | 16000 | ilk 2 wilaya |
| TN | Tunus | Vilayet | İlçe | — | NNNN | 1000 | — |
| NG | Nijerya | Eyalet | Bölge | — | NNNNNN | 100001 | — |
| KE | Kenya | Kontluk (County) | İlçe | — | NNNNN | 00100 | — |
| GH | Gana | Bölge | İlçe | — | AANNNNNNNN | GA1840312 | GhanaPostGPS (dijital) |
| ET | Etiyopya | Bölge | Zon | — | **— (yok)** | — | Genel posta kodu yok |
| AU | Avustralya | Eyalet | — | Şehir/Suburb | NNNN | 2000 | 0200–9944 · ilk hane eyalet |
| NZ | Y. Zelanda | Bölge | İlçe | — | NNNN | 6011 | — |

> Listede olmayan ülkeler aynı mantıkla GeoNames'te mevcut (bkz. §4). Posta kodu **olmayan** ülkeler: BAE, Katar, Etiyopya, bazı Körfez/Afrika/Pasifik — bu ülkelerde `addresses.postal_code` opsiyonel/boş, **PO Box** kullanılır.

---

## 3. Posta kodu → bölge eşlemesi (kesin aralıklar)

### 3.1 🇹🇷 Türkiye — İl plaka = posta kodu prefix (00–81)
Posta kodu **NNNNN**; **ilk 2 hane = il plaka kodu**. Bir ilin aralığı = `PP000–PP999`.

| Plaka/Prefix | İl | Aralık | | Plaka/Prefix | İl | Aralık |
|---|---|---|---|---|---|---|
| 01 | Adana | 01000–01999 | | 42 | Konya | 42000–42999 |
| 02 | Adıyaman | 02000–02999 | | 43 | Kütahya | 43000–43999 |
| 03 | Afyonkarahisar | 03000–03999 | | 44 | Malatya | 44000–44999 |
| 04 | Ağrı | 04000–04999 | | 45 | Manisa | 45000–45999 |
| 05 | Amasya | 05000–05999 | | 46 | Kahramanmaraş | 46000–46999 |
| 06 | Ankara | 06000–06999 | | 47 | Mardin | 47000–47999 |
| 07 | Antalya | 07000–07999 | | 48 | Muğla | 48000–48999 |
| 08 | Artvin | 08000–08999 | | 49 | Muş | 49000–49999 |
| 09 | Aydın | 09000–09999 | | 50 | Nevşehir | 50000–50999 |
| 10 | Balıkesir | 10000–10999 | | 51 | Niğde | 51000–51999 |
| 11 | Bilecik | 11000–11999 | | 52 | Ordu | 52000–52999 |
| 12 | Bingöl | 12000–12999 | | 53 | Rize | 53000–53999 |
| 13 | Bitlis | 13000–13999 | | 54 | Sakarya | 54000–54999 |
| 14 | Bolu | 14000–14999 | | 55 | Samsun | 55000–55999 |
| 15 | Burdur | 15000–15999 | | 56 | Siirt | 56000–56999 |
| 16 | Bursa | 16000–16999 | | 57 | Sinop | 57000–57999 |
| 17 | Çanakkale | 17000–17999 | | 58 | Sivas | 58000–58999 |
| 18 | Çankırı | 18000–18999 | | 59 | Tekirdağ | 59000–59999 |
| 19 | Çorum | 19000–19999 | | 60 | Tokat | 60000–60999 |
| 20 | Denizli | 20000–20999 | | 61 | Trabzon | 61000–61999 |
| 21 | Diyarbakır | 21000–21999 | | 62 | Tunceli | 62000–62999 |
| 22 | Edirne | 22000–22999 | | 63 | Şanlıurfa | 63000–63999 |
| 23 | Elazığ | 23000–23999 | | 64 | Uşak | 64000–64999 |
| 24 | Erzincan | 24000–24999 | | 65 | Van | 65000–65999 |
| 25 | Erzurum | 25000–25999 | | 66 | Yozgat | 66000–66999 |
| 26 | Eskişehir | 26000–26999 | | 67 | Zonguldak | 67000–67999 |
| 27 | Gaziantep | 27000–27999 | | 68 | Aksaray | 68000–68999 |
| 28 | Giresun | 28000–28999 | | 69 | Bayburt | 69000–69999 |
| 29 | Gümüşhane | 29000–29999 | | 70 | Karaman | 70000–70999 |
| 30 | Hakkari | 30000–30999 | | 71 | Kırıkkale | 71000–71999 |
| 31 | Hatay | 31000–31999 | | 72 | Batman | 72000–72999 |
| 32 | Isparta | 32000–32999 | | 73 | Şırnak | 73000–73999 |
| 33 | Mersin | 33000–33999 | | 74 | Bartın | 74000–74999 |
| 34 | İstanbul | 34000–34999 | | 75 | Ardahan | 75000–75999 |
| 35 | İzmir | 35000–35999 | | 76 | Iğdır | 76000–76999 |
| 36 | Kars | 36000–36999 | | 77 | Yalova | 77000–77999 |
| 37 | Kastamonu | 37000–37999 | | 78 | Karabük | 78000–78999 |
| 38 | Kayseri | 38000–38999 | | 79 | Kilis | 79000–79999 |
| 39 | Kırklareli | 39000–39999 | | 80 | Osmaniye | 80000–80999 |
| 40 | Kırşehir | 40000–40999 | | 81 | Düzce | 81000–81999 |
| 41 | Kocaeli | 41000–41999 | | | | |

### 3.2 🇺🇸 ABD — ZIP ilk hane = bölge + büyük eyalet 3-hane prefiksleri
ZIP **NNNNN**; ilk hane coğrafi bölge:

| İlk hane | Bölge (eyaletler) |
|---|---|
| 0 | CT, MA, ME, NH, NJ, RI, VT, NY(bazı), PR |
| 1 | DE, NY, PA |
| 2 | DC, MD, NC, SC, VA, WV |
| 3 | AL, FL, GA, MS, TN |
| 4 | IN, KY, MI, OH |
| 5 | IA, MN, MT, ND, SD, WI |
| 6 | IL, KS, MO, NE |
| 7 | AR, LA, OK, TX |
| 8 | AZ, CO, ID, NM, NV, UT, WY |
| 9 | AK, CA, HI, OR, WA |

Büyük eyalet 3-hane prefiks aralıkları (SCF): NY `100–149`, CA `900–961`, TX `750–799 + 885`, FL `320–349`, IL `600–629`, PA `150–196`, OH `430–459`, GA `300–319+398–399`, NC `270–289`, MI `480–499`. (Tam SCF listesi USPS'te.)

---

## 4. Gerçek kırılım verisini yükleme planı (98 ülke için)
TR zaten tam. Diğer ülkeler için düğüm verisi **yetkili setten** import edilir; senin `locations` şemana birebir oturur.

### 4.1 Kaynaklar (ücretsiz, açık lisans)
| Set | Ne verir | Level eşlemesi |
|---|---|---|
| **GeoNames** `countryInfo.txt` | Ülkeler (ISO2, ad, başkent…) | Level 1 |
| **GeoNames** `admin1CodesASCII.txt` | Eyalet/İl (ADM1) | **Level 2** |
| **GeoNames** `admin2Codes.txt` | İlçe/County (ADM2) | **Level 3** |
| **GeoNames** `cities500/allCountries` | Yerleşim/şehir/mahalle | **Level 4** |
| **GeoNames postal** (`download/zip/allCountries.zip`) | **posta kodu + yer + admin1/2 + lat/lng** | `addresses.postal_code` doğrulama + yer eşleme |
| **ISO 3166-2** | Resmî Level 2 alt bölümler (temiz) | Level 2 (alternatif) |
| **GADM** | Sınır poligonları (geofence/harita) | (opsiyonel) |

### 4.2 Şema eşlemesi (`locations`)
```
GeoNames ADM1  → locations(level=2, country_code=ISO2, code=admin1Code,  parent_id=ülke düğümü)
GeoNames ADM2  → locations(level=3, country_code=ISO2, code=admin2Code,  parent_id=ADM1 düğümü)
GeoNames place → locations(level=4, country_code=ISO2, code=geonameId,   parent_id=ADM2/ADM1)
id            = yeni UUID (gen_random_uuid())
name          = yerel/UTF-8 ad
```
Posta kodu **node'a yazılmaz**; GeoNames postal seti `addresses.postal_code` doğrulaması ve "posta kodu → location" eşlemesi için kullanılır.

### 4.3 Önerilen yükleme adımları
1. GeoNames'ten hedef ülkelerin `admin1`/`admin2` + postal dosyalarını indir.
2. Bir dönüştürücü script (Python/.NET) ile UUID üret + parent_id bağla → `locations` COPY/INSERT.
3. Önce **Level 2 (tüm 98 ülke)** yükle (en yüksek değer/maliyet oranı). Level 3/4 yalnız **operasyonel ülkeler** için (TR + ilk hedef pazarlar).
4. Posta kodu doğrulama: ülke bazlı **regex** (bu dokümandaki format) + GeoNames postal lookup.

### 4.4 Öncelik önerisi (lojistik için)
- **Faz A:** TR (hazır) + ilk hedef pazarlar (örn. DE, NL, FR, AE, SA) → Level 2+3 tam.
- **Faz B:** Kalan AB + Körfez → Level 2.
- **Faz C:** Global geri kalan → Level 1+2 (talep oldukça Level 3/4).

---

## 5. Posta kodu doğrulama regex'leri (addresses.postal_code)
| Ülke | Regex |
|---|---|
| TR | `^\d{5}$` |
| US | `^\d{5}(-\d{4})?$` |
| DE/ES/IT/FR/FI/MX | `^\d{5}$` |
| NL | `^\d{4}\s?[A-Z]{2}$` |
| GB | `^[A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2}$` |
| CA | `^[A-Z]\d[A-Z]\s?\d[A-Z]\d$` |
| BR | `^\d{5}-?\d{3}$` |
| JP | `^\d{3}-?\d{4}$` |
| CN/IN/RU/VN | `^\d{6}$` |
| AE/QA/ET | *(posta kodu yok — opsiyonel/boş)* |

---

## 6. Sonuç & öneri
- Yapı zaten doğru (locations level tree + addresses postal). **Eksik:** 98 ülkenin alt-kırılımı → **GeoNames/ISO import işi** (elle değil).
- Bu doküman: ülke bazında **caption + posta format/aralık** (doğrulama ve UI için) + TR/US kesin aralıklar + import planı.
- **Sonraki adım önerisi:** İlk hedef pazarları seç (örn. DE/NL/AE/SA), onlar için Level 2(+3) GeoNames import'unu bir göreve bağlayalım; posta regex'lerini `addresses` doğrulamasına ekleyelim.
