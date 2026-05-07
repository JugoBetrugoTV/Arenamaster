# Arenamaster Module Structure & Load Order

## 📋 Load Order Tiers

The addon is organized into 4 dependency tiers to ensure proper initialization order.

---

## **Tier 0: Foundation (No Dependencies)**

Core modules that have no dependencies on other modules.

### `modules/opponents.lua` - Opponent Tracker
- **Purpose:** Track and cache opponent encounter data
- **Features:** Win/loss records, ability tracking, opponent cache
- **Dependencies:** None
- **Used by:** OpponentProfiler, CombatAnalytics, ThreatDetector

### `modules/cooldowns.lua` - Cooldown Tracker
- **Purpose:** Legacy cooldown tracking system
- **Features:** Ability status tracking, base cooldown durations
- **Dependencies:** None
- **Used by:** AuraTracker, CooldownPredictor

### `modules/rating.lua` - Rating System
- **Purpose:** PvP rating and tier tracking
- **Features:** Rating history, tier determination, progression tracking
- **Dependencies:** None
- **Used by:** Dashboard UI, Analytics, Goals

### `modules/config.lua` - Configuration Manager
- **Purpose:** Centralized settings management
- **Features:** 30+ settings, profiles, import/export, validation
- **Dependencies:** None
- **Used by:** ConfigUI, EnemyFrames, AuraTracker, all UI modules

---

## **Tier 1: UI & Configuration (Depends on Tier 0)**

User interface and visual modules that depend on foundation.

### `modules/configui.lua` - Configuration UI ⭐
- **Purpose:** Beautiful graphical configuration interface
- **Features:** Presets, search, category organization, real-time updates
- **Dependencies:** ConfigManager
- **Used by:** Main addon (slash command)

### `modules/enemyframes.lua` - Enemy Frames Display
- **Purpose:** Main opponent frame display system
- **Features:** Real-time health/mana/cast bars, trinket tracking, buff/debuff display
- **Dependencies:** ConfigManager, OpponentTracker
- **Used by:** Core addon (arena combat display)

### `modules/auratracker.lua` - Aura & Cooldown Tracking
- **Purpose:** Real-time cooldown and aura monitoring
- **Features:** Important abilities database, predictive notifications, threat ability prioritization
- **Dependencies:** ConfigManager, OpponentTracker, CooldownTracker
- **Used by:** ThreatDetector, CooldownPredictor, Notifications

---

## **Tier 2: Analysis & Detection (Depends on Tier 0-1)**

Combat analysis and threat detection systems.

### `modules/threat.lua` - Threat Detection System
- **Purpose:** Intelligent threat scoring and focus recommendations
- **Features:** 8-factor threat analysis, real-time scoring, frame coloring
- **Dependencies:** AuraTracker, EnemyFrames, OpponentTracker
- **Used by:** Dashboard, Notifications, Callouts

### `modules/predictor.lua` - Cooldown Predictor
- **Purpose:** Predicts when dangerous abilities will be ready
- **Features:** Cooldown history tracking, confidence scoring, danger alerts
- **Dependencies:** AuraTracker, OpponentTracker, RatingTracker
- **Used by:** Notifications, Dashboard, Callouts

### `modules/analytics.lua` - Combat Analytics
- **Purpose:** Real-time combat logging and statistics
- **Features:** DPS tracking, CC logging, efficiency scoring, match history
- **Dependencies:** OpponentTracker, RatingTracker
- **Used by:** Dashboard, Goals, Statistics

---

## **Tier 3: Notifications & Display (Depends on Tier 0-2)**

Alert systems and visual callouts.

### `modules/notifications.lua` - Smart Notifications
- **Purpose:** Multi-channel notification system with intelligent filtering
- **Features:** Priority-based alerts, cooldown throttling, event triggers
- **Dependencies:** ThreatDetector, CooldownPredictor, ConfigManager
- **Used by:** Core addon event system

### `modules/callouts.lua` - Visual Callouts
- **Purpose:** On-screen visual alerts and callout system
- **Features:** Priority-colored boxes, progress bars, animated display
- **Dependencies:** ThreatDetector, EnemyFrames, ConfigManager
- **Used by:** Core addon event system

### `modules/map.lua` - Arena Minimap
- **Purpose:** Arena positioning display with player positions
- **Features:** Class-colored player dots, tooltips, bracket sizing
- **Dependencies:** EnemyFrames, ConfigManager
- **Used by:** Combat display

---

## **Tier 4: AI & Intelligence (Depends on Tier 0-2)**

Advanced AI and machine learning systems.

### `modules/profiler.lua` - Opponent Profiler
- **Purpose:** Machine learning playstyle detection from opponent behavior
- **Features:** Playstyle categorization, behavioral analysis, counter strategies
- **Dependencies:** OpponentTracker, Analytics, AuraTracker, RatingTracker
- **Used by:** MatchPredictor, Dashboard

### `modules/predictor_match.lua` - Match Win Predictor
- **Purpose:** Pre-match win probability calculation
- **Features:** 5-weighted factor analysis, team composition analysis, time-to-goal estimation
- **Dependencies:** OpponentProfiler, RatingTracker, Analytics
- **Used by:** Dashboard, Notifications

### `modules/goals.lua` - Goal Tracker
- **Purpose:** Rating progression and goal tracking
- **Features:** Goal types, progress calculation, time-to-completion estimation
- **Dependencies:** RatingTracker, MatchPredictor, Notifications
- **Used by:** Dashboard, Goals display

---

## 🔄 Initialization Flow

```
1. ADDON_LOADED Event
   ↓
2. Arenamaster:Initialize()
   ├── ConfigManager:Initialize()          [Tier 0]
   ├── OpponentTracker:Initialize()        [Tier 0]
   ├── RatingTracker:Initialize()          [Tier 0]
   ├── ConfigUI:Initialize()               [Tier 1]
   ├── EnemyFrames:Initialize()            [Tier 1]
   ├── AuraTracker:Initialize()            [Tier 1]
   ├── ThreatDetector:Initialize()         [Tier 2]
   ├── CooldownPredictor:Initialize()      [Tier 2]
   ├── Analytics:Initialize()              [Tier 2]
   ├── Notifications:Initialize()          [Tier 3]
   ├── Callouts:Initialize()               [Tier 3]
   ├── Map:Initialize()                    [Tier 3]
   ├── OpponentProfiler:Initialize()       [Tier 4]
   ├── MatchPredictor:Initialize()         [Tier 4]
   └── GoalTracker:Initialize()            [Tier 4]
   ↓
3. UI Created
4. Events Registered
5. Ready for Arena Combat
```

---

## 📊 Dependency Graph

```
┌─────────────────────────────────────────────────────┐
│ TIER 0: Foundation                                  │
│ ┌──────────┐ ┌──────────┐ ┌─────────┐ ┌────────┐   │
│ │Opponents │ │Cooldowns │ │ Rating  │ │ Config │   │
│ └──────────┘ └──────────┘ └─────────┘ └────────┘   │
└─────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────┐
│ TIER 1: UI & Configuration                          │
│ ┌─────────┐ ┌──────────┐ ┌────────────┐             │
│ │ConfigUI │ │EnemyFrame│ │AuraTracker │             │
│ └─────────┘ └──────────┘ └────────────┘             │
└─────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────┐
│ TIER 2: Analysis & Detection                        │
│ ┌────────┐ ┌──────────┐ ┌──────────┐                │
│ │ Threat │ │Predictor │ │Analytics │                │
│ └────────┘ └──────────┘ └──────────┘                │
└─────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────┐
│ TIER 3: Notifications & Display                     │
│ ┌───────────┐ ┌─────────┐ ┌─────┐                   │
│ │Notif.    │ │Callouts │ │ Map │                   │
│ └───────────┘ └─────────┘ └─────┘                   │
└─────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────┐
│ TIER 4: AI & Intelligence                           │
│ ┌──────────┐ ┌─────────────┐ ┌──────┐               │
│ │Profiler  │ │Match Predict│ │Goals │               │
│ └──────────┘ └─────────────┘ └──────┘               │
└─────────────────────────────────────────────────────┘
```

---

## ✅ Load Order Validation

The load order is validated through:

1. **Tier System** - Each tier depends only on lower tiers
2. **XML Definition** - `Arenamaster_Dependencies.xml` defines the order
3. **TOC File** - `Arenamaster.toc` matches the load order
4. **Initialization** - Main addon calls Initialize() in tier order
5. **Testing** - No circular dependencies

---

## 🔧 Adding New Modules

When adding a new module:

1. Identify which tier it belongs to
2. Add to `Arenamaster_Dependencies.xml` in the correct tier
3. Update `Arenamaster.toc` to match
4. Update this documentation
5. Add initialization call in `Arenamaster:Initialize()`

Example:
```lua
-- If your module depends on ThreatDetector (Tier 2)
-- Place it in Tier 3: Notifications & Display
```

---

## 📝 Version

Module Structure v1.0 - Arenamaster 4.0+

Last Updated: 2026-05-07
