@echo off
setlocal enabledelayedexpansion

:: ── Detect current Wi-Fi / Ethernet IPv4 address ──────────────────────────
set "IP="
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /R /C:"IPv4 Address"') do (
    set "RAW=%%A"
    for /f "tokens=*" %%B in ("!RAW!") do set "IP=%%B"
    goto :found
)
:found

if "!IP!"=="" (
    echo [ERROR] Could not detect local IP. Check your network connection.
    exit /b 1
)

echo [Tori] Detected IP: !IP!
echo [Tori] API base URL: http://!IP!:8122/api/v1

:: ── Patch API_BASE_URL inside .env.json ───────────────────────────────────
powershell -NoProfile -Command "$f='.env.json'; $j=Get-Content $f -Raw | ConvertFrom-Json; $j.API_BASE_URL='http://!IP!:8122/api/v1'; $j | ConvertTo-Json -Depth 10 | Set-Content $f -Encoding UTF8"

echo [Tori] .env.json updated.

:: ── Run Flutter (pass device as first arg, e.g. run.bat android) ──────────
set "DEVICE=%~1"
if "!DEVICE!"=="" set "DEVICE=android"

echo [Tori] Launching on: !DEVICE!
flutter run -d !DEVICE! --dart-define-from-file=.env.json %2 %3 %4

endlocal
