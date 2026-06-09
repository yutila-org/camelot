$ErrorActionPreference = "Stop"

# Dependency Verification
if (-not (Get-Command "clang" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] 'clang' is not installed." -ForegroundColor Red
    Write-Host "Please install it seamlessly via winget: " -NoNewline; Write-Host "winget install LLVM.LLVM" -ForegroundColor Cyan
    exit 1
}

if (-not (Get-Command "dmd" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] 'dmd' (D compiler) is not installed." -ForegroundColor Red
    Write-Host "Please install it seamlessly via winget: " -NoNewline; Write-Host "winget install Dlang.DMD" -ForegroundColor Cyan
    exit 1
}

if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] 'git' is not installed. Please install git." -ForegroundColor Red
    exit 1
}

$CamelotHome = Join-Path $env:USERPROFILE ".camelot"

if (Test-Path $CamelotHome) {
    Write-Host "[UPDATE] Updating existing Camelot installation in $CamelotHome..." -ForegroundColor Cyan
    Set-Location $CamelotHome
    git pull origin main
} else {
    Write-Host "[INSTALL] Cloning Camelot to $CamelotHome..." -ForegroundColor Cyan
    git clone https://github.com/yutila-org/camelot.git $CamelotHome
    Set-Location $CamelotHome
}

Write-Host "[BUILD] Compiling Merlin Engine via dmd..." -ForegroundColor Cyan
if (-not (Test-Path "bin")) { New-Item -ItemType Directory -Path "bin" | Out-Null }
dmd merlin\*.d -of=bin\merlin.exe

# Permanently inject User Environment Variables (Zero manual setup)
[Environment]::SetEnvironmentVariable("CAMELOT_HOME", $CamelotHome, "User")
$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$BinPath = Join-Path $CamelotHome "bin"

if ($UserPath -notmatch [regex]::Escape($BinPath)) {
    $NewPath = "$UserPath;$BinPath"
    [Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")
    Write-Host "[SUCCESS] Bound CAMELOT_HOME and added Merlin to Windows PATH." -ForegroundColor Green
}

Write-Host "[SUCCESS] Camelot Framework and Merlin Engine successfully initialized!" -ForegroundColor Green
Write-Host "Please restart your PowerShell terminal to wield 'merlin'." -ForegroundColor Cyan
