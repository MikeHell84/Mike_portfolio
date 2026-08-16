@echo off
setlocal
title Portafolio - Launcher unificado
cd /d "%~dp0"
chcp 65001 >nul 2>nul

echo ==================================================
echo   PORTFOLIO LAUNCHER - FRONTEND + BACKEND
echo ==================================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Node.js no esta instalado o no esta en el PATH.
  echo         Instala Node desde https://nodejs.org e intenta de nuevo.
  pause
  exit /b 1
)

if not exist "data\portfolio.json" (
  echo [AVISO] No existe data/portfolio.json: el sitio se abrira sin tus datos.
  echo         Guarda datos desde el panel admin para crearlo.
  echo.
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ping='http://localhost:5173/__api/ping'; function Test-Backend { try { $r=Invoke-WebRequest -UseBasicParsing $ping -TimeoutSec 2; return $r.StatusCode -eq 200 } catch { return $false } }; Write-Host ''; if (Test-Backend) { Write-Host '  [OK] Backend (serve.js) ya esta corriendo en http://localhost:5173' } else { $ocupado=Get-NetTCPConnection -LocalPort 5173 -State Listen -ErrorAction SilentlyContinue; if ($ocupado) { Write-Host '  [AVISO] El puerto 5173 lo ocupa OTRO proceso (PID ' $ocupado[0].OwningProcess ').' -ForegroundColor Yellow; Write-Host '          Si nuestro backend no puede iniciarse, cierra ese proceso.' } ; Write-Host '  [1/2] Iniciando BACKEND: node serve.js  (ventana minimizada) ...' ; Start-Process node -ArgumentList 'serve.js','5173' -WorkingDirectory (Get-Location).Path -WindowStyle Minimized | Out-Null ; $ok=$false; for($i=0;$i -lt 50;$i++){ Start-Sleep -Milliseconds 300; if (Test-Backend) { $ok=$true; break } }; if (-not $ok) { Write-Host '  [ERROR] El backend no respondio en localhost:5173.' -ForegroundColor Red ; Write-Host '          Revisa el puerto 5173 (netstat -ano | findstr 5173) y vuelve a intentar.' ; Read-Host '  Presiona Enter para cerrar'; exit 1 } else { Write-Host '  [OK] Backend listo (responde ping).' } }; Write-Host '  [2/2] Abriendo FRONTEND (portafolio) y panel BACKEND (admin) en el navegador ...'"

REM --- Mismo lanzamiento: abrir frontend + backend (panel) en el navegador ---
timeout /t 1 /nobreak >nul
start "" "http://localhost:5173/"
start "" "http://localhost:5173/admin.html"

:menu
echo.
echo  ===========================================
echo   FRONTEND  http://localhost:5173/
echo   BACKEND   http://localhost:5173/admin.html
echo  ===========================================
echo.
echo   [1] Reabrir FRONTEND (portafolio)
echo   [2] Reabrir BACKEND (panel admin)
echo   [3] Detener el BACKEND (servidor) y salir
echo   [4] Salir
echo.
choice /C 1234 /N /M "Elige una opcion: "
if errorlevel 4 exit /b 0
if errorlevel 3 goto stop
if errorlevel 2 goto admin
if errorlevel 1 goto front

:front
start "" "http://localhost:5173/"
goto menu

:admin
start "" "http://localhost:5173/admin.html"
goto menu

:stop
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$c=Get-NetTCPConnection -LocalPort 5173 -State Listen -ErrorAction SilentlyContinue; if ($c) { $c | Select-Object -Unique OwningProcess | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force } ; Write-Host 'Backend detenido.' } else { Write-Host 'No habia backend corriendo.' }"
exit /b 0