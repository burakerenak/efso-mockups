# EFSO — Global Adres: Seviye-Bazlı Model + Ülkeye Göre Caption Haritası

> Karar kaynağı: kullanıcı dokümanı (global adres mantığı). Tek geçerli adres-yapı kaynağı. 2026-06-07.

## Karar (özet)
- **DB'de `İl/İlçe/Mahalle` kolonu AÇILMAZ.** Tek **`Locations` ağacı**: `Id, ParentId, CountryCode(ISO2), Level(int), Name, Code, Type`. Adres tablosu yalnız **`LocationId`** tutar (+ `PostalCode, Lat, Lng, AddressLine`).
- **UI SABİT:** tek "cascade" bileşeni (Ülke → Seviye 2 → Seviye 3 → …). **Ülkeye göre değişen tek şey: caption (label) ve gösterilen seviye sayısı.**
- Kullanılmayan seviyeler **gizlenir** (ör. BAE'de "İlçe/County" yok).
- Hazır veri için: **GeoNames / OpenStreetMap / ISO 3166-2** (zaten level + parent-child).

> ⚠️ **Mevcut backend etkisi:** Catalog modülü şu an TR'ye özgü `Province/District/Neighborhood` entity'lerine sahip. Global hedef için bu, **generic `Location` (Level+ParentId)** modeline evrilmeli. Gereksinim/issue olarak işlenmeli (FR-BE catalog refactor).

## Seviye mantığı
| Seviye | Genel anlam | Her zaman |
|---|---|---|
| Level 1 | Ülke / Country | Var |
| Level 2 | Region / State | Çoğu ülke |
| Level 3 | Sub-region | Çoğu ülke (bazıları atlar) |
| Level 4 | Locality / City | Çoğu ülke |
| Level 5 | Neighborhood | Bazı ülkeler |

## Ülkeye göre caption haritası (UI'da gösterilecek etiketler)
> Level 1 her ülkede **"Ülke / Country"**. Aşağıda Level 2–5 + posta kodu etiketi.

| Ülke | Level 2 | Level 3 | Level 4 | Level 5 | Posta kodu |
|---|---|---|---|---|---|
| 🇹🇷 Türkiye | İl | İlçe | Mahalle | — | Posta Kodu |
| 🇺🇸 ABD | State | County | City | — | ZIP Code |
| 🇬🇧 İngiltere | County | District | City / Town | — | Postcode |
| 🇩🇪 Almanya | Bundesland | Kreis (Landkreis) | Stadt / Gemeinde | Ortsteil | PLZ |
| 🇫🇷 Fransa | Région | Département | Commune / Ville | Quartier | Code Postal |
| 🇪🇸 İspanya | Comunidad Autónoma | Provincia | Municipio | Barrio | Código Postal |
| 🇮🇹 İtalya | Regione | Provincia | Comune | Frazione | CAP |
| 🇳🇱 Hollanda | Provincie | Gemeente | Plaats / Stad | Wijk | Postcode |
| 🇯🇵 Japonya | Prefecture (Ken/To/Fu/Do) | City / District (Shi/Gun) | Ward / Town (Ku/Cho) | Chome | Postal Code |
| 🇨🇳 Çin | Province (Sheng) | Prefecture-City (Shi) | District / County (Qu/Xian) | Subdistrict (Jiedao) | Postal Code |
| 🇸🇦 S. Arabistan | Region (Mintaqah) | Governorate (Muhafazah) | City | District (Hayy) | Postal Code |
| 🇦🇪 BAE | Emirate | — *(seviye yok)* | City / Area | District / Community | — *(PO Box)* |
| 🇷🇺 Rusya | Federal Subject / Oblast | Raion (District) | City | Microdistrict | Postal Index |
| 🇨🇦 Kanada | Province / Territory | — | City / Municipality | — | Postal Code |
| 🇦🇺 Avustralya | State / Territory | — | City / Suburb | — | Postcode |
| 🇧🇷 Brezilya | Estado | — | Município / Cidade | Bairro | CEP |
| 🇮🇳 Hindistan | State | District | City / Town | Locality / Area | PIN Code |

### Önemli nüanslar
- **Seviye atlayan ülkeler:** BAE/Kanada/Avustralya/Brezilya'da Level 3 (sub-region) genelde gösterilmez → o dropdown **gizlenir**.
- **Posta kodu olmayan/farklı:** BAE'de posta kodu yerine **PO Box**; bazı ülkelerde zorunlu değil.
- **Etiket dili:** Caption'lar uygulamanın diline (TR/EN/ES/FR/AR) çevrilebilir; ama **yapı (Level)** hep aynı kalır — sadece sözlük değişir.

## Label sözlüğü (JSON — koda gömülecek örnek)
```json
{
  "TR": { "2": "İl", "3": "İlçe", "4": "Mahalle", "postal": "Posta Kodu" },
  "US": { "2": "State", "3": "County", "4": "City", "postal": "ZIP Code" },
  "DE": { "2": "Bundesland", "3": "Kreis", "4": "Stadt", "5": "Ortsteil", "postal": "PLZ" },
  "AE": { "2": "Emirate", "4": "City / Area", "5": "District", "postal": null }
}
```

## Çalışır mockup
`docs/mockup/efso-global-adres.html` — ülke seçince caption'lar + seviye sayısı dinamik değişir; çıktı `LocationId` mantığını gösterir.
