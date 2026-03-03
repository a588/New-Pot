# New-Pot

## New-Pot Enterprise PC Cleanup (BAT)

Dieses Repository enthaelt eine **Enterprise-orientierte Windows-Bereinigungsdatei** mit Fokus auf:

- sichere Ausfuehrung mit Admin-Check,
- nutzerfreundliches Menue,
- DRY-RUN Modus,
- strukturierte Protokollierung,
- Quick-, Deep- und Browser-Cleanup,
- Wartungsfunktionen (DISM, Windows-Update-Cache, Papierkorb, Restore Point).

## Datei

- `pc_cleanup_enterprise.bat`

## Nutzung

1. Datei herunterladen.
2. Mit Rechtsklick **Als Administrator ausfuehren**.
3. Im Menue den gewuenschten Cleanup-Modus auswaehlen.

## Hinweise

- Logs werden standardmaessig unter `%ProgramData%\NewPot\Logs` geschrieben.
- Wenn der Ordner nicht erstellt werden kann, wird automatisch auf `%TEMP%\NewPotLogs` gewechselt.
- Nutze vor grossen Bereinigungen zuerst den **DRY-RUN Modus**, um Auswirkungen zu pruefen.
