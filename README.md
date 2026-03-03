# New-Pot

## PC-Auffrischen Script

Dieses Repository enthält `pc_auffrischen.bat`, ein praxisnahes Windows-Wartungsskript zum schnellen „Auffrischen“ eines PCs.

### Was das Skript verbessert

- Löscht temporäre Dateien (`%TEMP%` und `%SystemRoot%\Temp`).
- Leert den DNS-Cache.
- Setzt Winsock und den IP-Stack zurück.
- Startet die Datenträgerbereinigung.
- Führt eine Systemdateiprüfung mit `sfc /scannow` aus.
- Bietet optional eine tiefere Reparatur via `DISM /RestoreHealth`.

### Verkaufstaugliche Punkte (USP)

- **Ein-Klick-Wartung:** Mehrere typische Support-Schritte in einem Skript gebündelt.
- **Zeitersparnis:** Ideal für IT-Dienstleister, Support und Wiederverkauf gebrauchter PCs.
- **Sicher & nachvollziehbar:** Klarer Ablauf mit Statusmeldungen je Schritt.
- **Flexibel:** DISM-Reparatur optional aktivierbar.
- **Niedrige Einstiegshürde:** Reine Batch-Datei, keine zusätzliche Installation nötig.

### Anwendung

1. Datei `pc_auffrischen.bat` herunterladen.
2. Rechtsklick → **Als Administrator ausführen** (empfohlen).
3. Ablauf durchlaufen lassen.
4. Anschließend PC neu starten.

### Hinweis

Das Skript ersetzt keine vollständige Hardwarediagnose oder professionelle Sicherheitsprüfung, ist aber ein effizienter Standard-Baustein für die Grundwartung.
