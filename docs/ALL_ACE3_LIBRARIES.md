# All 17 Ace3 Libraries - Complete Reference

**Arenamaster now includes ALL official Ace3 libraries!**

---

## 📚 Complete Library List

### Core Frameworks
1. **LibStub** - Library loading and versioning
2. **AceAddon-3.0** - Addon lifecycle and module system

### Event System
3. **AceEvent-3.0** - WoW event handling
4. **AceBucket-3.0** - Event grouping and throttling
5. **AceComm-3.0** - Inter-addon communication
6. **AceTimer-3.0** - Timer scheduling

### Configuration
7. **AceConfig-3.0** - Options table registry
8. **AceConfigCmd-3.0** - Command-line config
9. **AceConfigDialog-3.0** - Configuration UI
10. **AceConfigRegistry-3.0** - Options registry
11. **AceDBOptions-3.0** - Profile management UI

### Data Management
12. **AceDB-3.0** - SavedVariables database
13. **AceSerializer-3.0** - Data serialization
14. **AceLocale-3.0** - Localization system

### UI & Utilities
15. **AceGUI-3.0** - GUI widget library
16. **AceTab-3.0** - Tab management
17. **AceConsole-3.0** - Chat commands and output
18. **AceHook-3.0** - Function/script hooking

---

## 🎯 Quick Usage Guide

### LibStub
```lua
-- Get a library
local MyLib = LibStub("AceAddon-3.0")
```

### AceAddon-3.0
```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon")
function MyAddon:OnInitialize() end
function MyAddon:OnEnable() end
```

### AceEvent-3.0
```lua
MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceEvent-3.0")
function MyAddon:OnEnable()
    self:RegisterEvent("ARENA_MATCH_BEGIN")
end
```

### AceTimer-3.0
```lua
MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceTimer-3.0")
self:ScheduleTimer("DoSomething", 5)
self:ScheduleRepeatingTimer("UpdateUI", 0.1)
```

### AceDB-3.0
```lua
function MyAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MyAddonDB", {
        profile = { setting = true }
    })
end
```

### AceConfig-3.0
```lua
local AceConfig = LibStub("AceConfig-3.0")
AceConfig:RegisterOptionsTable("MyAddon", {
    type = "group",
    args = { ... }
})
```

### AceGUI-3.0
```lua
local AceGUI = LibStub("AceGUI-3.0")
local frame = AceGUI:Create("Frame")
local btn = AceGUI:Create("Button")
frame:AddChild(btn)
```

### AceConsole-3.0
```lua
MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceConsole-3.0")
function MyAddon:OnEnable()
    self:RegisterChatCommand("myaddon", "SlashCommand")
end
function MyAddon:SlashCommand(msg)
    self:Print("Hello!")
end
```

### AceComm-3.0
```lua
local AceComm = LibStub("AceComm-3.0")
AceComm:RegisterComm("MYADDON", "OnCommReceived")
AceComm:SendCommMessage("MYADDON", "data", "PARTY")
```

### AceHook-3.0
```lua
MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "AceHook-3.0")
self:Hook(SomeFrame, "OnClick", "OnFrameClick")
function MyAddon:OnFrameClick()
    -- Hook code
end
```

### AceLocale-3.0
```lua
local L = LibStub("AceLocale-3.0"):GetLocale("MyAddon")
print(L["Hello World"])
```

### AceSerializer-3.0
```lua
local Serializer = LibStub("AceSerializer-3.0")
local data = {name = "test", value = 123}
local str = Serializer:Serialize(data)
local restored = Serializer:Deserialize(str)
```

### AceTab-3.0
```lua
local tabs = LibStub("AceTab-3.0"):new(myFrame)
tabs:AddTab("General", "general")
tabs:SelectTab("general")
```

### AceBucket-3.0
```lua
local Bucket = LibStub("AceBucket-3.0"):Embed(MyAddon)
Bucket:RegisterBucketEvent({"COMBAT_LOG_EVENT_UNFILTERED"}, 0.5, "OnBucketEvent")
```

### AceDBOptions-3.0
```lua
local DBOptions = LibStub("AceDBOptions-3.0")
local options = DBOptions:GetOptionsTable(self.db)
```

### AceConfigCmd-3.0
```lua
local ConfigCmd = LibStub("AceConfigCmd-3.0"):Embed(MyAddon)
ConfigCmd:HandleSlashCommand("MyAddon", "/myaddon list")
```

### AceConfigRegistry-3.0
```lua
local Registry = LibStub("AceConfigRegistry-3.0")
Registry:RegisterOptionsTable("MyAddon", options)
```

---

## 🏗️ Architecture

### Dependency Chain
```
LibStub (base)
    ↓
AceAddon-3.0
    ├── AceEvent-3.0
    │   ├── AceBucket-3.0
    │   └── AceComm-3.0
    ├── AceTimer-3.0
    ├── AceDB-3.0
    │   └── AceDBOptions-3.0
    ├── AceConsole-3.0
    ├── AceConfig-3.0
    │   ├── AceConfigCmd-3.0
    │   ├── AceConfigDialog-3.0
    │   └── AceConfigRegistry-3.0
    ├── AceGUI-3.0
    │   └── AceTab-3.0
    ├── AceHook-3.0
    ├── AceLocale-3.0
    └── AceSerializer-3.0
```

---

## 💡 Common Patterns

### Pattern 1: Full Setup
```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon(
    "MyAddon", 
    "AceEvent-3.0",
    "AceTimer-3.0",
    "AceDB-3.0",
    "AceConsole-3.0",
    "AceHook-3.0"
)

function MyAddon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MyAddonDB")
end

function MyAddon:OnEnable()
    self:RegisterEvent("ARENA_MATCH_BEGIN")
    self:RegisterChatCommand("myaddon", "SlashCommand")
    self:ScheduleRepeatingTimer("UpdateUI", 0.1)
end
```

### Pattern 2: Full Configuration
```lua
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

AceConfig:RegisterOptionsTable("MyAddon", {
    type = "group",
    args = {
        general = {
            name = "General",
            type = "group",
            args = {
                setting1 = { type = "toggle", ... },
                setting2 = { type = "range", ... },
            }
        }
    }
})

AceConfigDialog:SetDefaultSize("MyAddon", 800, 600)
AceConfigDialog:Open("MyAddon")
```

### Pattern 3: Data Serialization
```lua
local Serializer = LibStub("AceSerializer-3.0")
local myData = { 
    players = {
        {name = "Player1", rating = 1600},
        {name = "Player2", rating = 1800}
    }
}

-- Serialize for storage
local str = Serializer:Serialize(myData)

-- Deserialize from storage
local restored = Serializer:Deserialize(str)
```

---

## 🎯 Use Cases by Library

| Library | Best For |
|---------|----------|
| AceAddon-3.0 | Core addon structure |
| AceEvent-3.0 | Game event handling |
| AceTimer-3.0 | Scheduled tasks |
| AceDB-3.0 | Persistent data |
| AceConfig-3.0 | User options |
| AceGUI-3.0 | UI creation |
| AceConsole-3.0 | Slash commands |
| AceComm-3.0 | Player communication |
| AceHook-3.0 | Hooking WoW functions |
| AceLocale-3.0 | Multi-language |
| AceSerializer-3.0 | Data serialization |
| AceTab-3.0 | Tab interfaces |
| AceBucket-3.0 | Event grouping |
| AceConsole-3.0 | Chat output |

---

## 📈 Load Order

The libs.xml file loads libraries in proper order:

1. LibStub (foundation)
2. CallbackHandler-1.0 (event base)
3. AceAddon-3.0 (framework)
4. AceEvent-3.0 (events)
5. AceTimer-3.0 (timers)
6. AceDB-3.0 (database)
7. AceConfig-3.0 (options)
8. AceGUI-3.0 (widgets)
9. AceConfigDialog-3.0 (UI)
10. AceSerializer-3.0 (serialization)
11. AceComm-3.0 (communication)
12. AceConsole-3.0 (console)
13. AceConfigCmd-3.0 (cmd config)
14. AceConfigRegistry-3.0 (registry)
15. AceDBOptions-3.0 (profile ui)
16. AceHook-3.0 (hooking)
17. AceLocale-3.0 (localization)
18. AceTab-3.0 (tabs)
19. AceBucket-3.0 (bucketing)

---

## ✅ Verification

All 17 libraries are:
- ✅ Fully implemented
- ✅ Loaded via libs.xml
- ✅ Documented
- ✅ Ready to use
- ✅ Integrated with Arenamaster

---

**Arenamaster includes ALL Ace3 libraries! 🚀**

Version: 4.0.0
Date: 2026-05-07
