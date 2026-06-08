# EFSO — UI Adres Caption & Görünürlük Listesi (Türkçe, tüm ülkeler)

> UI'da ülkeye göre hangi seviyenin **görüneceği/gizleneceği** ve **Türkçe caption'ı**. 2026-06-07.
> Kaynak veri: `geographic.locations`. dr5hn import sonrası tipik derinlik = **Ülke › Eyalet/İl › Şehir** (3 seviye). Mahalle (L4) yalnız **TR** (diğer ülkeler GeoNames eklenince açılır).

---

## 1. Görünürlük kuralı (UI mantığı)
1. **Bir seviye, o ülkede VERİSİ varsa gösterilir; yoksa gizlenir.** (Ülke seçilince API o ülkenin seviyelerini döner; boş seviye render edilmez.)
2. **Caption** aşağıdaki tablodan/JSON'dan gelir (Türkçe). Yapı (level) sabit, sadece etiket değişir.
3. **Posta kodu** alanı: posta kodu olmayan ülkelerde **gizlenir** (yerine "Posta Kutusu / opsiyonel").
4. **Level 1 (Ülke)** her zaman görünür.

> Pratik sonuç (mevcut veriyle): **TR** → İl + İlçe + Mahalle (3 alt seviye). **Diğer tüm ülkeler** → Eyalet/İl + Şehir (2 alt seviye); Mahalle/Semt **gizli** (veri yok). Operasyonel ülkelere GeoNames ile Mahalle eklendiğinde o ülkede L4 otomatik açılır.

---

## 2. Varsayılan (tabloda olmayan tüm ülkeler)
| Seviye | Caption | Görünür mü |
|---|---|---|
| Level 1 | **Ülke** | ✓ her zaman |
| Level 2 | **İl** | ✓ (veri var) |
| Level 3 | **Şehir** | ✓ (veri varsa) |
| Level 4 | Mahalle | ✗ gizli (veri yok) |
| Level 5 | Semt | ✗ gizli |
| Posta kodu | **Posta Kodu** | ✓ |

---

## 3. Ülke bazında caption + görünürlük (Türkçe)
> `L2/L3/L4` = o seviyenin Türkçe caption'ı. **gizli** = render edilmez. Posta: ✓ görünür · ✗ gizli.

### 3.1 Öne çıkan / operasyonel
| Bayrak | Ülke | L2 | L3 | L4 | L5 | Posta |
|---|---|---|---|---|---|---|
| 🇹🇷 | Türkiye | İl | İlçe | **Mahalle** | gizli | ✓ Posta Kodu |
| 🇩🇪 | Almanya | Eyalet | Şehir | gizli¹ | gizli | ✓ |
| 🇳🇱 | Hollanda | İl | Şehir | gizli¹ | gizli | ✓ |
| 🇫🇷 | Fransa | Bölge | Şehir | gizli¹ | gizli | ✓ |
| 🇬🇧 | İngiltere | Bölge | Şehir | gizli | gizli | ✓ |
| 🇦🇪 | BAE | **Emirlik** | Şehir | gizli | gizli | **✗ (PO Box)** |
| 🇸🇦 | S. Arabistan | Bölge | Şehir | gizli¹ | gizli | ✓ |
| 🇺🇸 | ABD | **Eyalet** | Şehir | gizli¹ | gizli | ✓ |

> ¹ GeoNames ile Mahalle/Semt eklenince L4 = "Mahalle" açılır.

### 3.2 Avrupa
| Bayrak | Ülke | L2 | L3 | Posta |
|---|---|---|---|---|
| 🇮🇹 | İtalya | Bölge | Şehir | ✓ |
| 🇪🇸 | İspanya | Özerk Bölge | Şehir | ✓ |
| 🇧🇪 | Belçika | Bölge | Şehir | ✓ |
| 🇵🇹 | Portekiz | Bölge | Şehir | ✓ |
| 🇨🇭 | İsviçre | Kanton | Şehir | ✓ |
| 🇦🇹 | Avusturya | Eyalet | Şehir | ✓ |
| 🇵🇱 | Polonya | Voyvodalık | Şehir | ✓ |
| 🇸🇪 | İsveç | İl | Şehir | ✓ |
| 🇳🇴 | Norveç | İl | Şehir | ✓ |
| 🇩🇰 | Danimarka | Bölge | Şehir | ✓ |
| 🇫🇮 | Finlandiya | Bölge | Şehir | ✓ |
| 🇬🇷 | Yunanistan | Bölge | Şehir | ✓ |
| 🇷🇺 | Rusya | Bölge | Şehir | ✓ |
| 🇺🇦 | Ukrayna | Bölge | Şehir | ✓ |
| 🇷🇴 | Romanya | İl | Şehir | ✓ |
| 🇨🇿 | Çekya | Bölge | Şehir | ✓ |
| 🇭🇺 | Macaristan | İl | Şehir | ✓ |
| 🇧🇬 | Bulgaristan | İl | Şehir | ✓ |
| 🇭🇷 | Hırvatistan | İl | Şehir | ✓ |
| 🇷🇸 | Sırbistan | Bölge | Şehir | ✓ |
| 🇮🇪 | İrlanda | Kontluk | Şehir | ✓ |

### 3.3 Orta Doğu & Körfez
| Bayrak | Ülke | L2 | L3 | Posta |
|---|---|---|---|---|
| 🇶🇦 | Katar | Belediye | Bölge | **✗** |
| 🇰🇼 | Kuveyt | Vilayet | Şehir | ✓ |
| 🇧🇭 | Bahreyn | Vilayet | Şehir | ✓ |
| 🇴🇲 | Umman | Vilayet | Şehir | ✓ |
| 🇮🇱 | İsrail | Bölge | Şehir | ✓ |
| 🇯🇴 | Ürdün | İl | Şehir | ✓ |
| 🇱🇧 | Lübnan | Vilayet | Şehir | ✓ |
| 🇮🇷 | İran | Eyalet | Şehir | ✓ |
| 🇮🇶 | Irak | Vilayet | Şehir | ✓ |

### 3.4 Asya
| Bayrak | Ülke | L2 | L3 | Posta |
|---|---|---|---|---|
| 🇨🇳 | Çin | Eyalet | Şehir | ✓ |
| 🇯🇵 | Japonya | Eyalet | Şehir | ✓ |
| 🇰🇷 | G. Kore | Bölge | Şehir | ✓ |
| 🇮🇳 | Hindistan | Eyalet | Şehir | ✓ |
| 🇵🇰 | Pakistan | Eyalet | Şehir | ✓ |
| 🇧🇩 | Bangladeş | Bölge | Şehir | ✓ |
| 🇹🇭 | Tayland | İl | Şehir | ✓ |
| 🇻🇳 | Vietnam | İl | Şehir | ✓ |
| 🇮🇩 | Endonezya | İl | Şehir | ✓ |
| 🇲🇾 | Malezya | Eyalet | Şehir | ✓ |
| 🇸🇬 | Singapur | Bölge | Şehir | ✓ |
| 🇵🇭 | Filipinler | Bölge | Şehir | ✓ |

### 3.5 Amerika
| Bayrak | Ülke | L2 | L3 | Posta |
|---|---|---|---|---|
| 🇨🇦 | Kanada | Eyalet | Şehir | ✓ |
| 🇲🇽 | Meksika | Eyalet | Şehir | ✓ |
| 🇧🇷 | Brezilya | Eyalet | Şehir | ✓ |
| 🇦🇷 | Arjantin | İl | Şehir | ✓ |
| 🇨🇱 | Şili | Bölge | Şehir | ✓ |
| 🇨🇴 | Kolombiya | İl | Şehir | ✓ |
| 🇵🇪 | Peru | Bölge | Şehir | ✓ |

### 3.6 Afrika & Okyanusya
| Bayrak | Ülke | L2 | L3 | Posta |
|---|---|---|---|---|
| 🇪🇬 | Mısır | Vilayet | Şehir | ✓ |
| 🇿🇦 | G. Afrika | Eyalet | Şehir | ✓ |
| 🇲🇦 | Fas | Bölge | Şehir | ✓ |
| 🇩🇿 | Cezayir | Vilayet | Şehir | ✓ |
| 🇹🇳 | Tunus | Vilayet | Şehir | ✓ |
| 🇳🇬 | Nijerya | Eyalet | Şehir | ✓ |
| 🇰🇪 | Kenya | Kontluk | Şehir | ✓ |
| 🇬🇭 | Gana | Bölge | Şehir | **✗** |
| 🇪🇹 | Etiyopya | Bölge | Şehir | **✗** |
| 🇦🇺 | Avustralya | Eyalet | Şehir | ✓ |
| 🇳🇿 | Y. Zelanda | Bölge | Şehir | ✓ |

---

## 4. Posta kodu GİZLİ olan ülkeler (alanı render etme)
UPU'ya göre ulusal posta kodu kullanmayan başlıca ülkeler → UI'da posta alanı **gizlenir / opsiyonel + "PO Box"**:

**BAE, Katar, Gana (GPS), Etiyopya, Hong Kong, Macau, İrlanda (opsiyonel)**, Angola, Benin, Botsvana, Burkina Faso, Burundi, Kamerun, Orta Afrika Cum., Çad, Komorlar, Kongo, Demokratik Kongo, Fildişi Sahili, Cibuti, Ekvator Ginesi, Eritre, Fiji, Gabon, Gambiya, Gine, Guyana, Malavi, Mali, Moritanya, Namibya, Nauru, Ruanda, Samoa, Sierra Leone, Surinam, Tanzanya, Togo, Tuvalu, Uganda, Vanuatu, Yemen, Zimbabve.

> Bu listede olmayan ülkeler → posta alanı **görünür** (varsayılan).

---

## 5. UI konfig (JSON — koda gömülecek; l4/l5 yoksa gizli, postal:false ise posta gizli)
```json
{
  "_default": { "l2": "İl",     "l3": "Şehir", "l4": null,      "l5": null, "postal": true },
  "TR": { "l2": "İl",      "l3": "İlçe",  "l4": "Mahalle", "postal": true },
  "US": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "DE": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "NL": { "l2": "İl",      "l3": "Şehir", "postal": true },
  "FR": { "l2": "Bölge",   "l3": "Şehir", "postal": true },
  "GB": { "l2": "Bölge",   "l3": "Şehir", "postal": true },
  "IT": { "l2": "Bölge",   "l3": "Şehir", "postal": true },
  "ES": { "l2": "Özerk Bölge", "l3": "Şehir", "postal": true },
  "CH": { "l2": "Kanton",  "l3": "Şehir", "postal": true },
  "PL": { "l2": "Voyvodalık", "l3": "Şehir", "postal": true },
  "RU": { "l2": "Bölge",   "l3": "Şehir", "postal": true },
  "AE": { "l2": "Emirlik", "l3": "Şehir", "postal": false },
  "QA": { "l2": "Belediye","l3": "Bölge", "postal": false },
  "SA": { "l2": "Bölge",   "l3": "Şehir", "postal": true },
  "KW": { "l2": "Vilayet", "l3": "Şehir", "postal": true },
  "IR": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "CN": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "JP": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "IN": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "KR": { "l2": "Bölge",   "l3": "Şehir", "postal": true },
  "MY": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "ID": { "l2": "İl",      "l3": "Şehir", "postal": true },
  "TH": { "l2": "İl",      "l3": "Şehir", "postal": true },
  "CA": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "MX": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "BR": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "AU": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "EG": { "l2": "Vilayet", "l3": "Şehir", "postal": true },
  "ZA": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "MA": { "l2": "Bölge",   "l3": "Şehir", "postal": true },
  "DZ": { "l2": "Vilayet", "l3": "Şehir", "postal": true },
  "NG": { "l2": "Eyalet",  "l3": "Şehir", "postal": true },
  "KE": { "l2": "Kontluk", "l3": "Şehir", "postal": true },
  "GH": { "l2": "Bölge",   "l3": "Şehir", "postal": false },
  "ET": { "l2": "Bölge",   "l3": "Şehir", "postal": false },
  "IE": { "l2": "Kontluk", "l3": "Şehir", "postal": true }
}
```

## 6. Kullanım (UI dev için)
1. Ülke seçilince: `cfg = LABELS[countryCode] ?? LABELS["_default"]`.
2. API'den gelen seviyeleri sırayla render et; **caption = cfg.l{level}**, `null`/yoksa **o dropdown gizli**.
3. `cfg.postal === false` ise **posta alanını gizle** (yerine PO Box / opsiyonel).
4. Caption'lar uygulama diline (TR/EN/ES/FR/AR) çevrilebilir; bu liste TR sözlüğüdür.
