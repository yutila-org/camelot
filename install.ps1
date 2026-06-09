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

if (-not (Test-Path "$CamelotHome\bin")) { New-Item -ItemType Directory -Path "$CamelotHome\bin" | Out-Null }

Write-Host "[DOWNLOAD] Fetching system-specific binary for Camelot (windows-amd64)..." -ForegroundColor Cyan
$URL = "https://github.com/yutila-org/camelot/releases/download/alpha/camelot-windows-amd64.exe"
Invoke-WebRequest -Uri $URL -OutFile "$CamelotHome\bin\camelot.exe"

[Environment]::SetEnvironmentVariable("CAMELOT_HOME", $CamelotHome, "User")
$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$BinPath = Join-Path $CamelotHome "bin"

if ($UserPath -notmatch [regex]::Escape($BinPath)) {
    $NewPath = "$UserPath;$BinPath"
    [Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")
}

if (-not (Get-Command "merlin" -ErrorAction SilentlyContinue)) {
    Write-Host "[NOTICE] Merlin build engine not found. Installing it now..." -ForegroundColor Yellow
    Invoke-RestMethod https://github.com/yutila-org/merlin/releases/latest/download/install.ps1 | Invoke-Expression
}

Write-Host "[SUCCESS] Camelot Framework successfully installed to $CamelotHome!" -ForegroundColor Green
