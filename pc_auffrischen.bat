@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

title PC Auffrischen - Wartungsskript

:: ==================================================
:: PC AUFFRISCHEN - Sichere Wartungsroutine fuer Windows
:: ==================================================
:: Fuehrt nacheinander aus:
:: 1) Temp-Dateien bereinigen
:: 2) DNS-Cache leeren
:: 3) Netzwerk-Stack zuruecksetzen
:: 4) Datentraegerbereinigung starten
:: 5) Integritaetspruefung (SFC)
:: 6) Optional: DISM Reparatur
::
:: Hinweis: Fuer volle Wirkung als Administrator ausfuehren.
:: ==================================================

echo.
echo ===============================================
echo        PC AUFFRISCHEN - WARTUNG STARTET
echo ===============================================

call :requireAdmin

call :step "Temporäre Dateien löschen" :cleanupTemp
call :step "DNS-Cache leeren" :flushDns
call :step "Netzwerk zurücksetzen" :resetNetwork
call :step "Datenträgerbereinigung starten" :startCleanMgr
call :step "Systemdateien prüfen (SFC)" :runSfc
call :askDism

echo.
echo ===============================================
echo Wartung abgeschlossen.
echo Empfehlung: PC neu starten, damit alle Änderungen wirken.
echo ===============================================

goto :end

:requireAdmin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [HINWEIS] Das Skript laeuft nicht mit Administratorrechten.
    echo Einige Schritte koennen fehlschlagen oder weniger Wirkung haben.
    echo.
) else (
    echo [OK] Administratorrechte erkannt.
    echo.
)
exit /b 0

:step
set "STEP_NAME=%~1"
set "STEP_FUNC=%~2"
echo [START] %STEP_NAME%
call %STEP_FUNC%
if !errorlevel! neq 0 (
    echo [WARNUNG] %STEP_NAME% konnte nicht vollstaendig ausgefuehrt werden.
) else (
    echo [OK] %STEP_NAME% abgeschlossen.
)
echo.
exit /b 0

:cleanupTemp
for %%D in ("%TEMP%" "%SystemRoot%\Temp") do (
    if exist %%~D (
        del /f /s /q "%%~D\*" >nul 2>&1
        for /d %%X in ("%%~D\*") do rd /s /q "%%~X" >nul 2>&1
    )
)
exit /b 0

:flushDns
ipconfig /flushdns >nul 2>&1
exit /b %errorlevel%

:resetNetwork
netsh winsock reset >nul 2>&1
set "ERR1=%errorlevel%"
netsh int ip reset >nul 2>&1
set "ERR2=%errorlevel%"
if %ERR1% neq 0 exit /b %ERR1%
exit /b %ERR2%

:startCleanMgr
start "" cleanmgr /verylowdisk
exit /b 0

:runSfc
sfc /scannow
exit /b %errorlevel%

:askDism
choice /c JN /n /m "Optional DISM-Reparatur ausfuehren (kann laenger dauern)? [J/N]: "
if errorlevel 2 (
    echo [INFO] DISM uebersprungen.
    echo.
    exit /b 0
)
call :step "DISM Wiederherstellung" :runDism
exit /b 0

:runDism
DISM /Online /Cleanup-Image /RestoreHealth
exit /b %errorlevel%

:end
endlocal
