# =====================================================================
# EFSO — Global coğrafya tek-komut yükleyici (opsiyonel hızlandırıcı)
# dr5hn world.sql'i indirir -> staging'e yükler -> geographic.locations'a transform eder.
# ÖN KOŞUL: 'psql' PATH'te olmalı (PostgreSQL client). Yoksa .sql'i pgAdmin ile elle çalıştır.
#
# Kullanım (örnek):
#   $env:PGPASSWORD="parola"
#   .\geo-import.ps1 -PgHost localhost -PgPort 5444 -PgUser postgres -PgDb efso
# =====================================================================
param(
  [string]$PgHost = "localhost",
  [int]   $PgPort = 5444,
  [string]$PgUser = "postgres",
  [string]$PgDb   = "efso",
  [string]$Dr5hnUrl = "https://raw.githubusercontent.com/dr5hn/countries-states-cities-database/master/psql/world.sql",
  [string]$TransformSql = "$PSScriptRoot\geo-load-from-dr5hn.sql"
)

$ErrorActionPreference = "Stop"
function step($m){ Write-Host "==> $m" -ForegroundColor Cyan }

# psql var mı?
if(-not (Get-Command psql -ErrorAction SilentlyContinue)){
  Write-Host "psql bulunamadı. PostgreSQL client kur ya da .sql'i pgAdmin ile çalıştır." -ForegroundColor Red; exit 1
}
if(-not $env:PGPASSWORD){
  $sec = Read-Host "PostgreSQL parolası ($PgUser)" -AsSecureString
  $env:PGPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
}

$work = Join-Path $env:TEMP "efso-geo"
New-Item -ItemType Directory -Force $work | Out-Null
$worldSql = Join-Path $work "world.sql"

step "1/4  dr5hn world.sql indiriliyor"
Invoke-WebRequest -Uri $Dr5hnUrl -OutFile $worldSql -UseBasicParsing
"     indirildi: {0:N1} MB" -f ((Get-Item $worldSql).Length/1MB)

$psqlArgs = @("-h",$PgHost,"-p",$PgPort,"-U",$PgUser,"-d",$PgDb,"-v","ON_ERROR_STOP=1")

step "2/4  ÖNCE YEDEK (geographic şeması) -> $work\yedek_geographic.sql"
& pg_dump -h $PgHost -p $PgPort -U $PgUser -d $PgDb -n geographic -f (Join-Path $work "yedek_geographic.sql")

step "3/4  dr5hn staging tabloları yükleniyor (public.countries/states/cities)"
& psql @psqlArgs -f $worldSql

step "4/4  transform çalışıyor (geographic.locations'a yazılıyor, TR atlanır)"
& psql @psqlArgs -f $TransformSql

step "BİTTİ. Özet yukarıdaki SELECT çıktısında. Staging'i temizlemek istersen:"
Write-Host '  psql ... -c "DROP TABLE IF EXISTS public.cities, public.states, public.countries, public.regions, public.subregions CASCADE;"'
