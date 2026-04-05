@echo off
title n8n - Sleep Tracker
echo ================================
echo   Demarrage de n8n + Cloudflare
echo ================================
echo.

:: Verifier si Node.js est installe
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERREUR] Node.js n'est pas installe ou pas dans le PATH.
    echo Telecharge-le sur https://nodejs.org
    pause
    exit /b 1
)

:: Verifier si n8n est installe
where n8n >nul 2>nul
if %errorlevel% neq 0 (
    echo n8n n'est pas installe. Installation en cours...
    npm install -g n8n
    if %errorlevel% neq 0 (
        echo [ERREUR] Echec de l'installation de n8n.
        pause
        exit /b 1
    )
)

:: Lancer cloudflared en arriere-plan (tunnel gratuit sans compte)
echo [1/2] Lancement du tunnel Cloudflare...
start /b cloudflared tunnel --url http://localhost:5678 --logfile "%~dp0cloudflared.log" 2>nul

:: Attendre que le tunnel demarre
timeout /t 5 /nobreak >nul

:: Recuperer l'URL du tunnel depuis les logs
for /f "tokens=*" %%i in ('powershell -Command "Get-Content '%~dp0cloudflared.log' | Select-String 'https://.*trycloudflare.com' | ForEach-Object { if($_.Line -match '(https://[a-z0-9-]+\.trycloudflare\.com)'){$matches[1]} } | Select-Object -Last 1"') do set TUNNEL_URL=%%i

if "%TUNNEL_URL%"=="" (
    echo [ERREUR] Impossible de recuperer l'URL du tunnel.
    echo Verifie le fichier cloudflared.log
    pause
    exit /b 1
)

echo.
echo ========================================
echo   URL tunnel : %TUNNEL_URL%
echo ========================================
echo.
echo n8n local  : http://localhost:5678
echo Webhook    : %TUNNEL_URL%
echo.
echo Cette URL est utilisee par Telegram pour
echo communiquer avec ton n8n.
echo.
echo Appuie sur Ctrl+C pour arreter.
echo.

:: Lancer n8n avec l'URL webhook Cloudflare
set WEBHOOK_URL=%TUNNEL_URL%/
n8n start

:: Quand n8n s'arrete, tuer cloudflared
taskkill /f /im cloudflared.exe >nul 2>nul
del "%~dp0cloudflared.log" >nul 2>nul
pause
