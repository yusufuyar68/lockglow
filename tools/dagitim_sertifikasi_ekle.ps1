# Expo'dan indirilen iOS dağıtım sertifikasını (.p12) GitHub'a gizli değişken olarak ekler (TestFlight imzası için).
# Bunu SEN çalıştırırsın; sertifika ve parolası ekrana yazılmaz, yalnızca bu bilgisayardan GitHub'a gider.
#
# Önce Expo projesinde (ör. Momentra) şunu çalıştır ve menülerden indir:
#   npx eas-cli credentials -p ios
#   -> production -> "credentials.json: Upload/Download credentials..." -> "Download credentials from EAS to credentials.json"
#
# Kullanım (Lockglow proje klasöründe):
#   powershell -ExecutionPolicy Bypass -File tools\dagitim_sertifikasi_ekle.ps1
#   powershell -ExecutionPolicy Bypass -File tools\dagitim_sertifikasi_ekle.ps1 -ExpoKlasoru "C:\...\proje"

param([string]$ExpoKlasoru = (Join-Path $env:USERPROFILE "Desktop\sürpriz claude\surprise-planner"))

$repo = "yusufuyar68/lockglow"
$json = Join-Path $ExpoKlasoru "credentials.json"
if (-not (Test-Path $json)) { Write-Host "credentials.json bulunamadı: $json"; exit 1 }

$cred = Get-Content $json -Raw -Encoding UTF8 | ConvertFrom-Json
$dist = $cred.ios.distributionCertificate
if (-not $dist -or -not $dist.path -or -not $dist.password) {
    Write-Host "credentials.json içinde ios.distributionCertificate (path, password) yok."; exit 1
}
$p12 = Join-Path $ExpoKlasoru $dist.path
if (-not (Test-Path $p12)) { Write-Host "Sertifika dosyası yok: $p12"; exit 1 }

$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($p12))
$b64 | gh secret set DIST_P12_BASE64 -R $repo
if ($LASTEXITCODE -ne 0) { exit 1 }
$dist.password | gh secret set DIST_P12_PASSWORD -R $repo
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "Tamam: DIST_P12_BASE64 ve DIST_P12_PASSWORD GitHub'a eklendi."
Write-Host "Şimdi Expo klasöründeki credentials.json ve credentials\ klasörünü sil ya da güvenli bir yere taşı."
Write-Host "Sonra Claude'a 'sertifikayı ekledim' yaz."
