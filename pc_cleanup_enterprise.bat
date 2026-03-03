@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ============================================================
:: New-Pot Enterprise PC Cleanup Suite
:: Author: New-Pot
:: Purpose: Safe, auditable and user-friendly Windows cleanup
:: ============================================================

:: ----- Global configuration -----
set "APP_NAME=New-Pot Enterprise Cleanup"
set "APP_VERSION=2.0"
set "COMPANY_TAG=NEW-POT"
set "LOG_ROOT=%ProgramData%\NewPot\Logs"
set "RUN_TIMESTAMP=%DATE:~-4%%DATE:~3,2%%DATE:~0,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%"
set "RUN_TIMESTAMP=%RUN_TIMESTAMP: =0%"
set "LOG_FILE=%LOG_ROOT%\cleanup_%RUN_TIMESTAMP%.log"
set "ERROR_COUNT=0"
set "WARN_COUNT=0"
set "DRY_RUN=0"

:: ----- Bootstrap -----
call :InitEnvironment
call :CheckAdmin
if errorlevel 1 (
    echo.
    echo [ERROR] Administratorrechte sind erforderlich.
    echo Bitte Rechtsklick ^> "Als Administrator ausfuehren".
    pause
    exit /b 1
)

:MAIN_MENU
cls
call :Header
echo [Status]
if "%DRY_RUN%"=="1" (
    echo   - Modus: DRY-RUN (es werden keine Dateien geloescht)
) else (
    echo   - Modus: LIVE (Aenderungen werden ausgefuehrt)
)
echo   - Logdatei: %LOG_FILE%
echo.
echo [Hauptmenue]
echo   1. Quick Cleanup (empfohlen)
echo   2. Deep Cleanup (Enterprise)
echo   3. Browser-Cleanup (Edge/Chrome/Firefox Cache)
echo   4. Wartungsfunktionen
echo   5. DRY-RUN umschalten
echo   6. Letzte Logdatei anzeigen
echo   0. Beenden
echo.
set "CHOICE="
set /p "CHOICE=Bitte Auswahl eingeben [0-6]: "

if "%CHOICE%"=="1" call :RunQuickCleanup & goto :PostRun
if "%CHOICE%"=="2" call :RunDeepCleanup & goto :PostRun
if "%CHOICE%"=="3" call :RunBrowserCleanup & goto :PostRun
if "%CHOICE%"=="4" goto :MaintenanceMenu
if "%CHOICE%"=="5" call :ToggleDryRun & goto :MAIN_MENU
if "%CHOICE%"=="6" call :ShowLastLog & goto :MAIN_MENU
if "%CHOICE%"=="0" goto :ExitScript

echo.
echo [WARN] Ungueltige Eingabe.
call :Log "WARN" "Ungueltige Menu-Auswahl: %CHOICE%"
timeout /t 2 >nul
goto :MAIN_MENU

:MaintenanceMenu
cls
call :Header
echo [Wartungsfunktionen]
echo   1. DISM Component Cleanup
echo   2. Windows Update Download-Cache leeren
echo   3. Papierkorb leeren
echo   4. Wiederherstellungspunkt erstellen
echo   5. Zurueck
set "MCHOICE="
set /p "MCHOICE=Bitte Auswahl eingeben [1-5]: "
if "%MCHOICE%"=="1" call :DismCleanup & goto :PostRun
if "%MCHOICE%"=="2" call :WindowsUpdateCacheCleanup & goto :PostRun
if "%MCHOICE%"=="3" call :EmptyRecycleBin & goto :PostRun
if "%MCHOICE%"=="4" call :CreateRestorePoint & goto :PostRun
if "%MCHOICE%"=="5" goto :MAIN_MENU
echo.
echo [WARN] Ungueltige Eingabe.
timeout /t 2 >nul
goto :MaintenanceMenu

:PostRun
echo.
echo [INFO] Ausfuehrung abgeschlossen.
echo        Warnungen: %WARN_COUNT%
echo        Fehler:    %ERROR_COUNT%
echo        Log:       %LOG_FILE%
call :Log "INFO" "Run summary - warnings=%WARN_COUNT%, errors=%ERROR_COUNT%"
echo.
pause
goto :MAIN_MENU

:RunQuickCleanup
call :Log "INFO" "Quick Cleanup gestartet"
call :Section "Quick Cleanup"
call :CleanupPath "%TEMP%" "User TEMP"
call :CleanupPath "%WINDIR%\Temp" "Windows TEMP"
call :CleanupPath "%LOCALAPPDATA%\Temp" "Local AppData TEMP"
call :CleanupPath "%WINDIR%\SoftwareDistribution\DeliveryOptimization" "Delivery Optimization Cache"
call :EmptyRecycleBin
call :Log "INFO" "Quick Cleanup beendet"
exit /b 0

:RunDeepCleanup
call :Log "INFO" "Deep Cleanup gestartet"
call :Section "Deep Cleanup"
call :RunQuickCleanup
call :WindowsUpdateCacheCleanup
call :DismCleanup
call :CleanEventLogs
call :CleanupPath "%LOCALAPPDATA%\Microsoft\Windows\INetCache" "INetCache"
call :CleanupPath "%LOCALAPPDATA%\CrashDumps" "Crash Dumps"
call :Log "INFO" "Deep Cleanup beendet"
exit /b 0

:RunBrowserCleanup
call :Log "INFO" "Browser Cleanup gestartet"
call :Section "Browser Cleanup"
call :CleanupPath "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" "Edge Cache"
call :CleanupPath "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" "Chrome Cache"
call :CleanupPath "%APPDATA%\Mozilla\Firefox\Profiles" "Firefox Profile (nur cache2)" "FIREFOX"
call :Log "INFO" "Browser Cleanup beendet"
exit /b 0

:ToggleDryRun
if "%DRY_RUN%"=="0" (
    set "DRY_RUN=1"
    call :Log "INFO" "DRY-RUN aktiviert"
) else (
    set "DRY_RUN=0"
    call :Log "INFO" "DRY-RUN deaktiviert"
)
exit /b 0

:ShowLastLog
if exist "%LOG_FILE%" (
    echo.
    type "%LOG_FILE%"
    echo.
) else (
    echo [WARN] Keine Logdatei gefunden.
)
pause
exit /b 0

:WindowsUpdateCacheCleanup
call :Section "Windows Update Cache Cleanup"
call :Log "INFO" "Windows Update Dienste werden gestoppt"
if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] net stop wuauserv
    echo [DRY-RUN] net stop bits
) else (
    net stop wuauserv >nul 2>&1
    net stop bits >nul 2>&1
)
call :CleanupPath "%WINDIR%\SoftwareDistribution\Download" "SoftwareDistribution Download"
call :Log "INFO" "Windows Update Dienste werden gestartet"
if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] net start wuauserv
    echo [DRY-RUN] net start bits
) else (
    net start wuauserv >nul 2>&1
    net start bits >nul 2>&1
)
exit /b 0

:DismCleanup
call :Section "DISM Component Cleanup"
if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] dism /Online /Cleanup-Image /StartComponentCleanup
    call :Log "INFO" "DISM skipped (DRY-RUN)"
    exit /b 0
)
call :Log "INFO" "DISM cleanup gestartet"
dism /Online /Cleanup-Image /StartComponentCleanup >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :RegisterError "DISM Cleanup fehlgeschlagen"
) else (
    call :Log "INFO" "DISM Cleanup erfolgreich"
)
exit /b 0

:CleanEventLogs
call :Section "Event Logs Cleanup"
if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] wevtutil el ^| foreach ^(wevtutil cl^)
    call :Log "INFO" "Event logs cleanup skipped (DRY-RUN)"
    exit /b 0
)
for /f "tokens=*" %%L in ('wevtutil el') do (
    wevtutil cl "%%L" >nul 2>&1
)
call :Log "INFO" "Event Logs bereinigt"
exit /b 0

:EmptyRecycleBin
call :Section "Papierkorb leeren"
if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] PowerShell Clear-RecycleBin -Force
    call :Log "INFO" "Recycle Bin cleanup skipped (DRY-RUN)"
    exit /b 0
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :RegisterWarning "Papierkorb konnte nicht vollstaendig geleert werden"
) else (
    call :Log "INFO" "Papierkorb geleert"
)
exit /b 0

:CreateRestorePoint
call :Section "Wiederherstellungspunkt"
if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] Checkpoint-Computer -Description "%COMPANY_TAG% Cleanup"
    call :Log "INFO" "Restore point skipped (DRY-RUN)"
    exit /b 0
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description '%COMPANY_TAG% Cleanup' -RestorePointType 'MODIFY_SETTINGS'" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :RegisterWarning "Wiederherstellungspunkt konnte nicht erstellt werden (evtl. deaktivierter Schutz)"
) else (
    call :Log "INFO" "Wiederherstellungspunkt erstellt"
)
exit /b 0

:CleanupPath
set "TARGET=%~1"
set "LABEL=%~2"
set "MODE=%~3"

if not defined LABEL set "LABEL=Cleanup"
if not exist "%TARGET%" (
    call :RegisterWarning "%LABEL% uebersprungen - Pfad nicht gefunden: %TARGET%"
    exit /b 0
)

if /I "%MODE%"=="FIREFOX" (
    call :Log "INFO" "%LABEL% gestartet: %TARGET%"
    for /d %%P in ("%TARGET%\*") do (
        if exist "%%P\cache2" call :CleanupPath "%%P\cache2" "Firefox cache2"
    )
    exit /b 0
)

echo [INFO] Bereinige: %LABEL%
call :Log "INFO" "Bereinige %LABEL% (%TARGET%)"
if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] del /f /s /q "%TARGET%\*"
    echo [DRY-RUN] for /d %%D in ("%TARGET%\*") do rd /s /q "%%D"
    exit /b 0
)

del /f /s /q "%TARGET%\*" >nul 2>&1
for /d %%D in ("%TARGET%\*") do rd /s /q "%%D" >nul 2>&1

if errorlevel 1 (
    call :RegisterWarning "%LABEL% teilweise bereinigt (gesperrte Dateien moeglich)"
) else (
    call :Log "INFO" "%LABEL% erfolgreich bereinigt"
)
exit /b 0

:InitEnvironment
if not exist "%LOG_ROOT%" mkdir "%LOG_ROOT%" >nul 2>&1
if not exist "%LOG_ROOT%" (
    set "LOG_ROOT=%TEMP%\NewPotLogs"
    if not exist "%LOG_ROOT%" mkdir "%LOG_ROOT%" >nul 2>&1
    set "LOG_FILE=%LOG_ROOT%\cleanup_%RUN_TIMESTAMP%.log"
)
call :Log "INFO" "%APP_NAME% v%APP_VERSION% gestartet"
exit /b 0

:CheckAdmin
net session >nul 2>&1
if %errorlevel%==0 (
    call :Log "INFO" "Adminrechte erkannt"
    exit /b 0
)
call :Log "ERROR" "Keine Adminrechte"
exit /b 1

:Header
echo =============================================================
echo   %APP_NAME% ^| Version %APP_VERSION%
echo   Sicher. Transparent. Enterprise-ready.
echo =============================================================
exit /b 0

:Section
echo.
echo -------------------------------------------------------------
echo   %~1
echo -------------------------------------------------------------
exit /b 0

:RegisterWarning
set /a WARN_COUNT+=1
echo [WARN] %~1
call :Log "WARN" "%~1"
exit /b 0

:RegisterError
set /a ERROR_COUNT+=1
echo [ERROR] %~1
call :Log "ERROR" "%~1"
exit /b 0

:Log
set "LEVEL=%~1"
set "MESSAGE=%~2"
set "NOW=%DATE% %TIME%"
>> "%LOG_FILE%" echo [%NOW%] [%LEVEL%] %MESSAGE%
exit /b 0

:ExitScript
call :Log "INFO" "Script beendet"
echo.
echo Danke fuer die Nutzung von %APP_NAME%.
endlocal
exit /b 0
