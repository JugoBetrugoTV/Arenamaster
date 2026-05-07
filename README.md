# Arenamaster - PvP Arena Assistant

Eine umfassende PvP-Erweiterung für World of Warcraft Patch 12.0.5 Retail

## Übersicht
Arenamaster ist ein leistungsstarkes Addon für Arena-PvP in World of Warcraft. Es bietet Echtzeit-Tracking, Statistiken und Gegner-Management.

## 🎯 Hauptfeatures

### Arena-Statistiken
- **Match-Tracking**: Automatische Aufzeichnung aller Arena-Kämpfe
- **Winrate-Berechnung**: Live-Winrate-Statistiken
- **Streak-Tracking**: Aktueller und bester Gewinn-Streak
- **Gegner-Historie**: Detaillierte Aufzeichnung aller Gegner

### Gegner-Management
- **Gegner-Datenbank**: Speichert Information über alle bisherigen Gegner
- **Klasse & Spezialisierung**: Automatisches Tracking der Gegner-Klassen
- **Win/Loss-Record**: Persönliche Statistiken gegen jeden Gegner
- **Häufigste Gegner**: Top-5 Liste der am häufigsten getroffenen Gegner

### Rating-System
- **Live Rating Tracking**: Zeige dein aktuelles PvP-Rating
- **Tier-Anzeige**: Anzeige des aktuellen Tiers (Unranked, Challenger, Rival, Duelist, Gladiator)
- **Rating-Geschichte**: Verfolge deine Rating-Entwicklung
- **Tier-Fortschritt**: Sehe deinen Fortschritt im aktuellen Tier

### Cooldown-Tracking
- **Gegner-Cooldowns**: Verfolge Cooldowns gegnerischer Fähigkeiten
- **Automatische Updates**: Echtzeit-Updates während des Matches
- **Cooldown-Listen**: Übersichtliche Liste aktiver Cooldowns

## 📊 Tabs im Interface

### 1. Dashboard
- Aktueller Arena-Status
- Rating und Tier-Information
- Aktueller Gewinn-Streak
- Winrate-Progress-Bar
- Live-Match-Informationen

### 2. Statistiken
- Gesamt Anzahl Matches
- Siege und Niederlagen
- Berechnet Winrate
- Best Streak
- Top 5 Gegner nach Encounters

### 3. Einstellungen
- Gegner-Tracking aktivieren/deaktivieren
- Cooldown-Tracking aktivieren/deaktivieren
- Match-Benachrichtigungen
- Statistiken zurücksetzen

## 🎮 Slash-Befehle

```
/am              - UI öffnen/schließen
/am stats        - Statistiken im Chat anzeigen
/am reset        - Statistiken zurücksetzen (mit Bestätigung)
/am help         - Hilfe anzeigen
```

## 📋 Installation

1. **Download**: Lade das Addon herunter
2. **Platzierung**: Entpacke es in deinen WoW `Interface/AddOns` Ordner
   ```
   World of Warcraft/_retail_/Interface/AddOns/Arenamaster/
   ```
3. **Aktivierung**: Aktiviere das Addon im Spiel
   - Hauptmenü → Einstellungen → AddOns
   - Suche nach "Arenamaster" und aktiviere es
4. **Neustart**: Starte World of Warcraft neu

## ⚙️ Anforderungen
- World of Warcraft Patch 12.0.5 oder neuer (Retail)
- Lua 5.1 (WoW Standard)

## 🔧 Module

Das Addon besteht aus mehreren spezialisierten Modulen:

- **Arenamaster.lua**: Haupt-Interface und Event-Handling
- **modules/opponents.lua**: Gegner-Tracking und -Verwaltung
- **modules/cooldowns.lua**: Cooldown-Überwachung
- **modules/rating.lua**: Rating- und Tier-System

## 📝 Lizenz
MIT License - Siehe LICENSE Datei für Details

## 🤝 Support & Feedback
- Fehler melden und Vorschläge einreichen auf GitHub
- Discord: [Link folgt]
- Twitch: JugoBetrugoTV

## 🚀 Geplante Features
- Automatische Gegner-Name-Ausprache
- Integration von Armory-Daten
- Arena-Map-Overlays
- Automatische Macro-Generierung
- TeamSpeak/Discord Integration
- Replays und Highlight-Aufnahme

---
**Version**: 1.0.0  
**Autor**: JugoBetrugoTV  
**Patch**: 12.0.5 Retail