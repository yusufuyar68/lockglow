# App Store Connect API anahtarını GitHub'a gizli değişken olarak ekler (TestFlight iş akışı için).
# Bunu SEN çalıştırırsın; anahtar yalnızca bu bilgisayardan GitHub'a gider, ekrana yazılmaz.
#
# Kullanım (proje klasöründe):
#   powershell -ExecutionPolicy Bypass -File tools\testflight_anahtar_ekle.ps1
#
# Önce App Store Connect > Users and Access > Integrations > App Store Connect API sayfasında
# Admin yetkili bir anahtar oluşturup .p8 dosyasını indir (İndirilenler klasörüne düşer).

$repo = "yusuf68435/lockglow"
$downloads = Join-Path $env:USERPROFILE "Downloads"
$key = Get-ChildItem -Path $downloads -Filter "AuthKey_*.p8" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $key) {
    Write-Host "İndirilenler klasöründe AuthKey_*.p8 bulunamadı. Dosyanın yolunu yaz:"
    $path = Read-Host "Yol"
    if (-not (Test-Path $path)) { Write-Host "Dosya yok: $path"; exit 1 }
    $key = Get-Item $path
}
$keyId = $key.BaseName -replace '^AuthKey_', ''
Write-Host "Anahtar dosyası: $($key.Name)  (Key ID: $keyId)"
$issuer = (Read-Host "Issuer ID (aynı sayfada, anahtar listesinin üstünde)").Trim()
if ($issuer -notmatch '^[0-9a-fA-F-]{20,}$') { Write-Host "Issuer ID beklenen biçimde değil."; exit 1 }

gh secret set ASC_KEY_ID -R $repo -b $keyId
if ($LASTEXITCODE -ne 0) { exit 1 }
gh secret set ASC_ISSUER_ID -R $repo -b $issuer
if ($LASTEXITCODE -ne 0) { exit 1 }
cmd /c "gh secret set ASC_KEY_P8 -R $repo < `"$($key.FullName)`""
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "Tamam: ASC_KEY_ID, ASC_ISSUER_ID ve ASC_KEY_P8 GitHub'a eklendi."
Write-Host ".p8 dosyasını güvenli bir yere taşı (yalnızca bir kez indirilebilir), sonra Claude'a 'anahtarı ekledim' yaz."
