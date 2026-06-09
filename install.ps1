$ErrorActionPreference = "Stop"

if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] 'git' is not installed." -ForegroundColor Red
    exit 1
}

$CamelotHome = Join-Path $env:USERPROFILE ".camelot"

if (Test-Path $CamelotHome) {
    Write-Host "[UPDATE] Updating Camelot in $CamelotHome..." -ForegroundColor Cyan
    Set-Location $CamelotHome
    git pull origin main
} else {
    Write-Host "[INSTALL] Cloning Camelot to $CamelotHome..." -ForegroundColor Cyan
    git clone https://github.com/yutila-org/camelot.git $CamelotHome
}

[Environment]::SetEnvironmentVariable("CAMELOT_HOME", $CamelotHome, "User")
Write-Host "[SUCCESS] Bound CAMELOT_HOME environment variable." -ForegroundColor Green

if (-not (Get-Command "merlin" -ErrorAction SilentlyContinue)) {
    Write-Host "[NOTICE] Merlin build engine not found. Installing it now..." -ForegroundColor Yellow
    Invoke-RestMethod https://github.com/yutila-org/merlin/releases/latest/download/install.ps1 | Invoke-Expression
}

Write-Host "[SUCCESS] Camelot Framework successfully initialized!" -ForegroundColor Green
