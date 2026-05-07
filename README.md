# 🎯 Arenamaster - PvP Arena Assistant

**Professional-grade PvP addon for World of Warcraft 12.0.5 Retail**

A comprehensive arena combat assistant with AI-powered threat detection, intelligent cooldown prediction, real-time combat analytics, and beautiful configuration UI.

---

## ✨ Features

### 🎯 **Combat Intelligence**
- **Threat Detection** - 8-factor intelligent threat scoring
- **Cooldown Prediction** - Predict when dangerous abilities are ready
- **Win Probability** - Real-time match analysis with win% prediction
- **Opponent Profiling** - Machine learning playstyle detection

### 📊 **Real-Time Analytics**
- **Enemy Frames** - Live health/mana/cast bars with cooldown tracking
- **Match Statistics** - DPS, damage taken, CC usage tracking
- **Opponent History** - Complete encounter records
- **Rating Progression** - Track tier advancement

### 🎨 **Beautiful UI**
- **Modern Config Window** - Gorgeous graphical settings with presets
- **Visual Callouts** - On-screen priority alerts
- **Arena Minimap** - Tactical positioning display
- **Smart Notifications** - Multi-channel alert system

### ⚡ **Optimization**
- **Modular Architecture** - 16 independent modules
- **Event-Driven Design** - Minimal performance impact
- **Smart Throttling** - Prevents notification spam
- **Memory Efficient** - Optimized data structures

---

## 🚀 Quick Start

### Installation
1. Download to: `World of Warcraft\_retail_\Interface\AddOns\Arenamaster\`
2. Restart World of Warcraft
3. Enable addon in addon selection
4. Type `/am config` to configure

### First Steps
1. Choose a preset (Aggressive, Competitive, Streamer, Minimal, Casual)
2. Fine-tune settings in config UI
3. Save your profile
4. Play arena - features activate automatically!

---

## 📖 Commands

| Command | Function |
|---------|----------|
| `/am config` | Open configuration window |
| `/am stats` | Show match statistics |
| `/am threat` | Show threat analysis |
| `/am cooldowns` | Show cooldown status |
| `/am predict` | Show win probability |
| `/am goals` | Show progression goals |
| `/am help` | Show all commands |

---

## 📚 Documentation

- [CONFIG_UI_GUIDE.md](docs/CONFIG_UI_GUIDE.md) - Configuration guide
- [MODULE_STRUCTURE.md](docs/MODULE_STRUCTURE.md) - Architecture and modules
- [INSTALLATION.md](INSTALLATION.md) - Installation guide
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues

---

## 🏗️ Architecture

**4-Tier Module System** with explicit dependencies:
- **Tier 0:** Foundation (Opponent, Cooldown, Rating, Config)
- **Tier 1:** UI (ConfigUI, EnemyFrames, AuraTracker)
- **Tier 2:** Analysis (Threat, Predictor, Analytics)
- **Tier 3:** Notifications (Notifications, Callouts, Map)
- **Tier 4:** AI (Profiler, MatchPredictor, Goals)

---

## ⚙️ System Requirements

- WoW Version: 12.0.5 Retail
- Interface: 120005+
- Memory: 2-5 MB typical
- CPU: Minimal impact

---

## 📜 License

Provided as-is for personal use. See LICENSE for details.

---

**Enjoy dominating the arena! ⚔️🏆**

Version: 4.0.0 | Last Updated: 2026-05-07
