# Enemy Frames Specification - Arenamaster

**Detailliertes Spezifikation für Gegner-Frames (Gladius-Style)**

---

## 🎯 Overview

Enemy Frames zeigen alle 5 gegnerischen Spieler mit Health, Mana, Cast-Status und wichtigen Informationen an.

---

## 📐 Frame Layout

### **Standard Layout (Vertical Stack)**

```
╔═══════════════════════════════════════════════════════════════╗
║ ARENA OPPONENT FRAMES - VERTICAL LAYOUT                        ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  [🔴] Opponent 1         ███████░░░░░░░░  (45%)            ║
║        HP: 2500/5000      ███████░░░░░░░░  Mana             ║
║        Casting: Fireball (3s)                               ║
║        Trinket: ✅ Ready                                    ║
║        Buffs: [🟢] [🔵] [🟡]                               ║
║                                                               ║
║  [⚫] Opponent 2         ██████░░░░░░░░░  (40%)            ║
║        HP: 2000/5000      ████░░░░░░░░░░░░  Energy         ║
║        Casting: None                                         ║
║        Trinket: 🔴 12s                                      ║
║        Buffs: [🔴 CC: 5s] [🟢]                             ║
║                                                               ║
║  [🟣] Opponent 3         ███████████░░░░░  (70%)           ║
║        HP: 3500/5000      ███░░░░░░░░░░░░░  Rage           ║
║        Casting: Shield Block (cast)                         ║
║        Trinket: 🔴 28s                                      ║
║        Buffs: None                                           ║
║                                                               ║
║  [🟠] Opponent 4         ████░░░░░░░░░░░░  (20%)           ║
║        HP: 1000/5000      ██░░░░░░░░░░░░░░  Mana           ║
║        Casting: None                                         ║
║        Trinket: ✅ Ready                                    ║
║        Buffs: [🔴 Stun: 2s] [🟡]                           ║
║                                                               ║
║  [🟡] Opponent 5         ██████████░░░░░░  (60%)           ║
║        HP: 3000/5000      ██████░░░░░░░░░  Power           ║
║        Casting: Frostbolt (2s)                              ║
║        Trinket: ✅ Ready                                    ║
║        Buffs: [🟢] [🟢] [🟡]                               ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 🎨 Frame Structure (Per Opponent)

```
OPPONENT FRAME
├─ Header Bar (Class-Colored)
│  ├─ Class Icon (Left)
│  ├─ Name (Center) + Level (Right)
│  └─ Target Icon (Right) - what they're targeting
│
├─ Health Bar
│  ├─ Current/Max HP (text)
│  ├─ Health Percentage
│  └─ Over-absorb indicator
│
├─ Resource Bar (Mana/Energy/Rage)
│  ├─ Resource type indicator
│  ├─ Current/Max amount
│  └─ Resource depleted state
│
├─ Cast Bar
│  ├─ Spell name
│  ├─ Cast time remaining
│  ├─ Interruptible indicator
│  └─ Channeling vs. Casting
│
├─ Trinket Status
│  ├─ Trinket icon
│  ├─ Cooldown countdown (if used)
│  ├─ "Ready" indicator (if up)
│  └─ Color coding (red/green)
│
└─ Buff/Debuff Section
   ├─ Important Buffs (max 3-5)
   │  ├─ Shield
   │  ├─ Absorption
   │  ├─ Defensive cooldown
   │  └─ Damage buff
   └─ Crowd Control (max 3-5)
      ├─ Stun (red)
      ├─ Root (green)
      ├─ Silence (blue)
      ├─ Fear (purple)
      └─ Duration countdown
```

---

## 🎮 Interactive Features

### **Clicks & Interactions**

```lua
-- Click Frame to target opponent
frame:SetScript("OnClick", function(self)
    TargetUnit("arena" .. self.opponentIndex)
end)

-- Shift-Click to focus target
-- Alt-Click to add to raid mark
-- Right-Click for context menu (notes, blacklist, etc)
```

---

## 🌈 Color Coding System

### **Class Colors**
```lua
local classColors = {
    ["DRUID"] = {r=1.0, g=0.49, b=0.04},      -- Orange
    ["HUNTER"] = {r=0.67, g=0.83, b=0.45},    -- Green
    ["MAGE"] = {r=0.41, g=0.80, b=0.94},      -- Blue
    ["PALADIN"] = {r=0.96, g=0.55, b=0.73},   -- Pink
    ["PRIEST"] = {r=1.0, g=1.0, b=1.0},       -- White
    ["ROGUE"] = {r=1.0, g=0.96, b=0.41},      -- Yellow
    ["SHAMAN"] = {r=0.0, g=0.44, b=0.87},     -- Deep Blue
    ["WARLOCK"] = {r=0.58, g=0.51, b=0.79},   -- Purple
    ["WARRIOR"] = {r=0.78, g=0.61, b=0.43},   -- Brown
    ["MONK"] = {r=0.0, g=1.0, b=0.59},        -- Teal
    ["DEMON_HUNTER"] = {r=0.64, g=0.19, b=0.79}, -- Purple
    ["DEATH_KNIGHT"] = {r=0.77, g=0.12, b=0.23}, -- Dark Red
}
```

### **Status Colors**
```lua
Health Bar Colors:
- Green: 100% HP
- Yellow: 50% HP
- Red: <25% HP
- Dark Red: Dead

Trinket Status:
- Green: Ready to use
- Red: On cooldown
- Orange: About to come up (3s)

CC Status:
- Red: Stunned/Locked
- Yellow: Rooted
- Blue: Silenced
- Purple: Feared
- Orange: Hexed/Polymorphed
```

---

## 📊 Data Display Details

### **Health Bar**
```lua
-- Display format options:
1. "2500/5000 (50%)"
2. "2500 / 5000" 
3. Percentage only "50%"
4. No text, bar only

-- Over-heal/Absorb:
Shield absorption extends bar to right (gray)
Beacon healing shows as second bar (lighter)
```

### **Resource Bar**
```lua
-- Mana (Blue)
-- Energy (Yellow) 
-- Rage (Red)
-- Focus (Yellow-green)
-- Power (varies by class)
-- Runes (for DK - special display)

-- Display:
"1200/1500 Mana" or just bar without text
```

### **Cast Bar**
```lua
-- Format:
"Casting: [Spell Name] (2.3s / 3.0s)"

-- Colors:
- Interruptible: Yellow/Orange
- Non-interruptible: Red
- Channeling: Different color (purple)

-- Special:
- Instant cast: Show as "Cast"
- GCD: Show shorter bar

-- Fail states:
- "INTERRUPTED"
- "RESISTED"
- "ABSORBED"
```

---

## 🎯 Trinket Tracking System

### **Two Display Modes**

**Mode 1: Icon with Cooldown**
```
┌─────────────────────────┐
│  [Trinket Icon]         │
│  ├─ 45s cooldown text   │
│  └─ Greyed out while CD │
└─────────────────────────┘
```

**Mode 2: Grid Indicator**
```
┌──────────────────┐
│  [RED SQUARE]    │ = Used (on cooldown)
│  [GREEN SQUARE]  │ = Ready
│  [ORANGE SQUARE] │ = About to come up
└──────────────────┘
```

---

## 🔔 Events & Updates

### **Real-Time Updates**

```lua
-- Health/Mana Changes (High Priority)
UNIT_HEALTH_FREQUENT
UNIT_MAXHEALTH
UNIT_POWER
UNIT_MAXPOWER

-- Cast Bar Updates
UNIT_SPELLCAST_START
UNIT_SPELLCAST_STOP
UNIT_SPELLCAST_FAILED
UNIT_SPELLCAST_SUCCEEDED

-- Buff/Debuff Updates
UNIT_AURA

-- Trinket Tracking
UNIT_INVENTORY_CHANGED
SPELL_COOLDOWN_CHANGED (via C_CooldownFrame)

-- Arena Events
ARENA_OPPONENT_UPDATE
ARENA_MATCH_BEGIN
ARENA_MATCH_END
```

---

## 🎨 Configuration Options

### **What Users Can Customize**

```lua
-- Layout
├─ Frame order (1-5 or custom)
├─ Frame size (width/height)
├─ Frame spacing
├─ Alignment (vertical/horizontal/grid)
└─ Position on screen

-- Display
├─ Show/hide health bar
├─ Show/hide mana bar
├─ Show/hide cast bar
├─ Show/hide trinket
├─ Show/hide buffs
├─ Show/hide debuffs
├─ Show/hide name
├─ Show/hide class icon
└─ Show/hide level

-- Visuals
├─ Bar thickness
├─ Font size
├─ Bar color (per class or custom)
├─ Transparency
├─ Glow effects
├─ Border style
└─ Background color

-- Behavior
├─ Click to target
├─ Show click feedback
├─ Sound on update
├─ Announce events (chat)
└─ Minimize in rated vs skirmish
```

---

## 🚀 Implementation Steps

### **Phase 1: Basic Structure** (2-3 hours)
1. Create frame templates
2. Implement health/mana bars
3. Add class-based coloring
4. Position 5 frames on screen

### **Phase 2: Cast & Trinket** (2-3 hours)
1. Add cast bar with timer
2. Implement trinket tracking
3. Add cooldown countdown
4. Color coding for status

### **Phase 3: Buffs & Debuffs** (2-3 hours)
1. Track important buffs
2. Track CC durations
3. Display in frame
4. Update on aura changes

### **Phase 4: Polish & Customization** (2 hours)
1. Add configuration options
2. Implement adjustable sizes
3. Add layout options
4. Performance optimization

---

## 📋 Pseudocode Example

```lua
-- Create opponent frame
function CreateOpponentFrame(index)
    local frame = CreateFrame("Frame", "OpponentFrame" .. index)
    frame:SetSize(200, 80)
    frame:SetPoint("TOP", UIParent, "CENTER", 0, -(index * 90))
    
    -- Header (Class & Name)
    local header = frame:CreateFontString(nil, "OVERLAY")
    header:SetFontObject("GameFontNormal")
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    
    -- Health Bar
    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetSize(190, 20)
    healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -25)
    healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    healthBar:SetStatusBarColor(0, 1, 0)
    
    -- Mana Bar
    local manaBar = CreateFrame("StatusBar", nil, frame)
    manaBar:SetSize(190, 10)
    manaBar:SetPoint("TOP", healthBar, "BOTTOM", 0, -2)
    manaBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    manaBar:SetStatusBarColor(0, 0.5, 1)
    
    -- Cast Bar
    local castBar = CreateFrame("StatusBar", nil, frame)
    castBar:SetSize(190, 15)
    castBar:SetPoint("TOP", manaBar, "BOTTOM", 0, -2)
    castBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    castBar:SetStatusBarColor(1, 0.8, 0)
    castBar:Hide()
    
    -- Register for updates
    frame:RegisterUnitEvent("UNIT_HEALTH", "arena" .. index)
    frame:RegisterUnitEvent("UNIT_POWER", "arena" .. index)
    frame:RegisterUnitEvent("UNIT_SPELLCAST_START", "arena" .. index)
    frame:SetScript("OnEvent", function(self, event, ...)
        UpdateOpponentFrame(self, event)
    end)
    
    frame.healthBar = healthBar
    frame.manaBar = manaBar
    frame.castBar = castBar
    frame.opponentIndex = index
    
    return frame
end

-- Update function
function UpdateOpponentFrame(frame, event)
    local unit = "arena" .. frame.opponentIndex
    
    -- Health
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    frame.healthBar:SetMinMaxValues(0, maxHealth)
    frame.healthBar:SetValue(health)
    
    -- Mana
    local power = UnitPower(unit)
    local maxPower = UnitPowerMax(unit)
    frame.manaBar:SetMinMaxValues(0, maxPower)
    frame.manaBar:SetValue(power)
    
    -- Class coloring
    local _, class = UnitClass(unit)
    local color = GetClassColor(class)
    frame.healthBar:SetStatusBarColor(color.r, color.g, color.b)
end
```

---

## 🎯 Integration with Rest of Addon

```
ENEMY FRAMES
    ↓
    ├─ Data from Opponent Tracker
    │  └─ Historical data, notes
    ├─ Data from Cooldown Tracker
    │  └─ Predicted cooldown timers
    ├─ Data from Stats Module
    │  └─ Matchup statistics
    └─ Sends events to
       ├─ Threat Detection
       ├─ Analysis Engine
       └─ Statistics Recorder
```

---

## ✅ Success Criteria

Frame should:
- [✅] Display all 5 opponents
- [✅] Update health/mana in real-time
- [✅] Show cast bars with interruption indicators
- [✅] Track trinket cooldowns
- [✅] Display buffs/debuffs
- [✅] Color-code by class
- [✅] Be fully customizable
- [✅] Have <5% performance impact
- [✅] Integrate with other modules
- [✅] Work in all arena types (2v2, 3v3, 5v5, skirmish)

---

**Next Step**: Start implementation of Phase 1!

