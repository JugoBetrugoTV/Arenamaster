# Ace3 Framework Integration Guide

## 📚 Overview

Arenamaster v4.0+ uses **Ace3 (Ace Advanced Mod Framework)**, the professional standard for WoW addon development.

---

## 🎯 Ace3 Libraries Included

### Core Libraries

1. **LibStub** - Library version management
2. **CallbackHandler-1.0** - Event callback system
3. **AceAddon-3.0** - Addon initialization framework
4. **AceEvent-3.0** - Event handling and registration
5. **AceTimer-3.0** - Timer management system
6. **AceDB-3.0** - SavedVariables database with profiles
7. **AceConfig-3.0** - Options table registration
8. **AceGUI-3.0** - GUI widget library
9. **AceConfigDialog-3.0** - Configuration dialog builder

---

## 📂 Library Structure

```
libs/
├── LibStub/
│   └── LibStub.lua
├── CallbackHandler-1.0/
│   └── CallbackHandler-1.0.lua
├── AceAddon-3.0/
│   └── AceAddon-3.0.lua
├── AceEvent-3.0/
│   └── AceEvent-3.0.lua
├── AceTimer-3.0/
│   └── AceTimer-3.0.lua
├── AceDB-3.0/
│   └── AceDB-3.0.lua
├── AceConfig-3.0/
│   └── AceConfig-3.0.lua
├── AceGUI-3.0/
│   └── AceGUI-3.0.lua
├── AceConfigDialog-3.0/
│   └── AceConfigDialog-3.0.lua
└── libs.xml
```

---

## 🚀 Usage Examples

### Creating an Addon with Ace3

```lua
local AceAddon = LibStub:GetLibrary("AceAddon-3.0")
local MyAddon = AceAddon:NewAddon("MyAddon", "AceEvent-3.0", "AceTimer-3.0")

function MyAddon:OnInitialize()
	-- Called when addon loads
end

function MyAddon:OnEnable()
	-- Called when addon is enabled
end
```

### Using AceDB for SavedVariables

```lua
local AceDB = LibStub:GetLibrary("AceDB-3.0")

local defaults = {
	profile = {
		setting1 = true,
		setting2 = "value",
	}
}

local db = AceDB:New(ArenamasterDB, defaults)
```

### Registering Options with AceConfig

```lua
local AceConfig = LibStub:GetLibrary("AceConfig-3.0")
local AceConfigDialog = LibStub:GetLibrary("AceConfigDialog-3.0")

AceConfig:RegisterOptionsTable("MyAddon", {
	name = "My Addon Options",
	type = "group",
	args = {
		setting1 = {
			name = "My Setting",
			type = "toggle",
			order = 1,
		}
	}
})

AceConfigDialog:SetDefaultSize("MyAddon", 800, 600)
AceConfigDialog:Open("MyAddon")
```

### Creating GUI with AceGUI

```lua
local AceGUI = LibStub:GetLibrary("AceGUI-3.0")

-- Create frame
local frame = AceGUI:Create("Frame")
frame:SetTitle("My Window")

-- Add button
local btn = AceGUI:Create("Button")
btn:SetLabel("Click Me")
btn:SetCallback("OnClick", function()
	print("Button clicked!")
end)
frame:AddChild(btn)
```

### Registering Events with AceEvent

```lua
local MyModule = AceAddon:NewModule("MyModule", "AceEvent-3.0")

function MyModule:OnEnable()
	self:RegisterEvent("ARENA_MATCH_BEGIN", "OnMatchBegin")
end

function MyModule:OnMatchBegin()
	print("Arena match started!")
end
```

### Using AceTimer for Delayed Execution

```lua
local MyAddon = AceAddon:NewAddon("MyAddon", "AceTimer-3.0")

function MyAddon:DoDelayedAction()
	self:ScheduleTimer("PrintMessage", 5)
end

function MyAddon:PrintMessage()
	print("This printed after 5 seconds")
end
```

---

## 📋 Ace3Config Module

### Files
- **modules/ace3config.lua** - Complete Ace3-based configuration

### Features
- 5 pre-configured presets
- AceGUI-based beautiful UI
- AceDB integration for SavedVariables
- AceConfig options table
- Easy expansion for new options

### Presets Available
1. 🔥 **Aggressive** - Large frames, all notifications
2. ⚔️ **Competitive** - Balanced for ranked play
3. 🎥 **Streamer** - Optimized for streaming
4. ⚪ **Minimal** - Ultra-clean interface
5. 🎮 **Casual** - Relaxed with optional alerts

### Opening Config Dialog
```lua
local Ace3Config = AM.Ace3Config
Ace3Config:OpenConfigDialog()
```

---

## 🔧 Extending Ace3 Config

### Adding a New Option

1. **Edit modules/ace3config.lua**
2. **Find the options table in GetOptions()**
3. **Add to appropriate section:**

```lua
args = {
	myNewSetting = {
		name = "My Setting",
		desc = "Description of setting",
		type = "toggle",  -- or "range", "select", "input"
		order = 10,
	}
}
```

### Adding a New Preset

```lua
function Ace3Config:ApplyPreset(preset)
	local presets = {
		-- ... existing presets ...
		MYPRESET = {
			frameWidth = 250,
			frameHeight = 100,
			-- ... more settings ...
		}
	}
	-- ... rest of function ...
end
```

---

## 📊 Tier System with Ace3

### Module Initialization Order

```
Tier 0: Foundation
├─ Config (AceDB)
└─ Other foundations

Tier 1: UI & Config
├─ Ace3Config (AceConfig, AceGUI)
├─ EnemyFrames
└─ AuraTracker

Tier 2: Analysis
├─ Threat Detector
├─ Predictor
└─ Analytics

Tier 3: Notifications
├─ SmartNotifications (AceEvent)
├─ Callouts
└─ Map

Tier 4: AI
├─ Profiler
├─ MatchPredictor
└─ GoalTracker
```

---

## 🎨 Widget Types in AceGUI

### Available Widgets

| Widget | Type | Example |
|--------|------|---------|
| Frame | `"Frame"` | Main window |
| ScrollFrame | `"ScrollFrame"` | Scrollable area |
| Button | `"Button"` | Click action |
| EditBox | `"EditBox"` | Text input |
| Label | `"Label"` | Text display |
| CheckBox | `"CheckBox"` | Toggle option |
| Slider | `"Slider"` | Range selection |

### Creating Widgets

```lua
local AceGUI = LibStub:GetLibrary("AceGUI-3.0")

-- Button
local btn = AceGUI:Create("Button")
btn:SetText("Click Me")

-- Checkbox
local cb = AceGUI:Create("CheckBox")
cb:SetLabel("Enable Feature")

-- Slider
local slider = AceGUI:Create("Slider")
slider:SetMinMaxValues(0, 100)

-- EditBox
local edit = AceGUI:Create("EditBox")
edit:SetLabel("Enter text")
```

---

## 🔗 Linking Options to Database

### With AceConfig

```lua
args = {
	mySetting = {
		name = "My Setting",
		type = "toggle",
		get = function(info) return self.db.profile.mySetting end,
		set = function(info, value) self.db.profile.mySetting = value end,
	}
}
```

### Automatic Handling

AceConfigDialog automatically maps options to your database if you use the correct names.

---

## ✅ Best Practices

1. **Always use LibStub** - Don't create duplicate libraries
2. **Separate modules** - Use Ace3 modules for organization
3. **Use AceDB** - For all SavedVariables (with profiles support)
4. **Register events** - Use AceEvent for clean event handling
5. **Structure options** - Use groups and sections in AceConfig
6. **Document options** - Always include descriptions

---

## 📖 Ace3 Documentation

- **WoWPedia:** https://www.wowpedia.org/Ace3
- **WowAce:** https://www.wowace.com/projects/ace3
- **GitHub:** https://github.com/WoWUIDev/Ace3

---

## 🚀 Future Enhancements

- [ ] Migrate more modules to Ace3
- [ ] Add AceHook-3.0 integration
- [ ] Implement AceDB profiles
- [ ] Add more AceGUI widgets
- [ ] Create custom widget types
- [ ] Add internationalization (i18n)

---

**Arenamaster is now a professional Ace3-based addon! 🎉**

Version: 4.0.0
Date: 2026-05-07
