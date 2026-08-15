# Requires: firebase login (account must be able to create Google Cloud projects)
$ErrorActionPreference = "Stop"
$ProjectId = "waqf-inspector-app"
$DisplayName = "Waqf Inspector App"
$AndroidPackage = "iq.gov.swa.inspector"
$AppRoot = Split-Path -Parent $PSScriptRoot
if (-not $AppRoot) { $AppRoot = (Get-Location).Path }
if ((Split-Path -Leaf $AppRoot) -eq "tools") { $AppRoot = Split-Path -Parent $AppRoot }

Write-Host "Inspector Firebase is isolated from tenants-301cb and insight-d63c2."
Write-Host "Project: $ProjectId"
Write-Host "Android package: $AndroidPackage"
Write-Host ""

firebase login --reauth
if ($LASTEXITCODE -ne 0) { throw "firebase login failed" }

$existing = firebase projects:list --json 2>$null
if ($existing -notmatch $ProjectId) {
  Write-Host "Creating Firebase project $ProjectId ..."
  firebase projects:create $ProjectId --display-name $DisplayName
  if ($LASTEXITCODE -ne 0) { throw "Could not create $ProjectId. Create it manually at https://console.firebase.google.com then re-run." }
}

firebase use $ProjectId
if ($LASTEXITCODE -ne 0) { throw "firebase use $ProjectId failed" }

Write-Host "Creating Android app $AndroidPackage ..."
firebase apps:create ANDROID $AndroidPackage --project $ProjectId --display-name "Inspector Android"
$sdkOut = Join-Path $AppRoot "android\app\google-services.json"
firebase apps:sdkconfig ANDROID --project $ProjectId -o $sdkOut
if (-not (Test-Path $sdkOut)) { throw "google-services.json was not downloaded" }

Write-Host ""
Write-Host "Android config saved: $sdkOut"
Write-Host ""
Write-Host "NEXT — Admin SDK (backend only, never share with tenant/chairman):"
Write-Host "1) Open https://console.firebase.google.com/project/$ProjectId/settings/serviceaccounts/adminsdk"
Write-Host "2) Generate new private key"
Write-Host "3) Save as: C:\Users\Dell\source\repos\WaqfLand0031\waqf-inspector-firebase-adminsdk.json"
Write-Host "4) Restart WaqfLand.API"
Write-Host ""
Write-Host "Do not reuse tenants-301cb or insight-d63c2 credentials."
