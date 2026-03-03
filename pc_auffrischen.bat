@echo off
setlocal EnableExtensions

:: ===============================================
:: PC Auffrischen Script (Windows Batch)
:: - Loescht Temp-Dateien
:: - Leert Windows-Update-Tempordner (wenn moeglich)
:: - Leert DNS-Cache
:: - Startet Datentraegerbereinigung
:: ===============================================

:: Auf Adminrechte pruefen
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [FEHLER] Bitte diese Datei als Administrator ausfuehren.
    echo Rechtsklick auf die .bat ^> "Als Administrator ausfuehren".
    pause
    exit /b 1
)

echo.
echo ===============================================
echo   PC wird aufgefrischt...
echo ===============================================
echo.

:: 1) Benutzer-Temp leeren
echo [1/5] Benutzer-Temp wird geloescht...
del /s /f /q "%TEMP%\*" >nul 2>&1
for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >nul 2>&1

:: 2) Windows-Temp leeren
echo [2/5] Windows-Temp wird geloescht...
del /s /f /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%D in ("C:\Windows\Temp\*") do rd /s /q "%%D" >nul 2>&1

:: 3) DNS Cache leeren
echo [3/5] DNS-Cache wird geleert...
ipconfig /flushdns

:: 4) Alte Windows Update Download-Dateien entfernen (wenn Dienste gestoppt werden koennen)
echo [4/5] Windows-Update-Temp wird bereinigt...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
del /s /f /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
for /d %%D in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%D" >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1

:: 5) Datentraegerbereinigung starten
echo [5/5] Datentraegerbereinigung wird gestartet...
cleanmgr /verylowdisk >nul 2>&1

echo.
echo ===============================================
echo Fertig! Ein Neustart kann die Wirkung verbessern.
echo ===============================================
echo.
pause
endlocal
