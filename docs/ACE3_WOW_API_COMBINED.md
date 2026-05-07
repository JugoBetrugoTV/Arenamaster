# Ace3 + WoW API Combined Reference

Professional addon development requires understanding both Ace3 frameworks and native WoW APIs working together.

---

## 🎯 Integration Pattern

### Basic Addon Structure

```lua
-- Core addon initialization using Ace3
local AceAddon = LibStub("AceAddon-3.0")
local MyAddon = AceAddon:NewAddon("MyAddon", "AceEvent-3.0", "AceDB-3.0", "AceTimer-3.0")

-- Initialize with WoW events
function MyAddon:OnInitialize()
    -- Setup AceDB with SavedVariables
    self.db = LibStub("AceDB-3.0"):New("MyAddonDB", {
        profile = {
            enabled = true,
            volume = 100,
        }
    })
    
    -- Register AceConfig options
    LibStub("AceConfig-3.0"):RegisterOptionsTable("MyAddon", self:GetOptions())
end

function MyAddon:OnEnable()
    -- Register WoW events using Ace3
    self:RegisterEvent("ARENA_MATCH_BEGIN", "OnArenaStart")
    self:RegisterEvent("ARENA_MATCH_END", "OnArenaEnd")
end

-- WoW event handlers
function MyAddon:OnArenaStart(event)
    print("Arena started!")
end

function MyAddon:OnArenaEnd(event)
    print("Arena ended!")
end
```

---

## 📊 Ace3 Library Mapping

### AceAddon-3.0 + WoW Event System

| WoW | Ace3 | Usage |
|-----|------|-------|
| Event registration | `RegisterEvent()` | `MyAddon:RegisterEvent("EVENT_NAME")` |
| Event firing | `SendMessage()` | `MyAddon:SendMessage("CUSTOM_EVENT")` |
| Unregister | `UnregisterEvent()` | `MyAddon:UnregisterEvent("EVENT_NAME")` |
| Multiple events | `RegisterEvents()` | Register many at once |

### AceDB-3.0 + SavedVariables

```lua
-- .toc file
## SavedVariables: ArenamasterDB

-- Lua code
function Arenamaster:OnInitialize()
    local defaults = {
        profile = {
            frameWidth = 220,
            frameHeight = 85,
        },
        global = {
            version = 1,
        },
        char = {
            characterName = UnitName("player"),
        }
    }
    
    self.db = LibStub("AceDB-3.0"):New("ArenamasterDB", defaults)
    
    -- Access data
    local width = self.db.profile.frameWidth
    
    -- Save is automatic
    self.db.profile.frameWidth = 250
end
```

### AceEvent-3.0 + WoW Events

```lua
local AceEvent = LibStub("AceEvent-3.0")

-- Register addon for events
MyAddon = AceEvent:Embed(MyAddon or {})

function MyAddon:OnEnable()
    -- Register WoW events
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("ARENA_PREP_OPPONENT_UPDATE")
    
    -- Handle events
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnSpellCast")
end

-- Event handler
function MyAddon:PLAYER_LOGIN()
    print("Player logged in!")
end

function MyAddon:OnSpellCast(event, unit)
    print("Spell cast by:", unit)
end
```

### AceGUI-3.0 + WoW Frames

```lua
local AceGUI = LibStub("AceGUI-3.0")

-- Create window with AceGUI
local frame = AceGUI:Create("Frame")
frame:SetTitle("My Addon")
frame:SetCallback("OnClose", function(widget) 
    -- Save position using WoW API
    SaveAddonPosition(widget.frame)
end)

-- Add WoW texture
local texture = frame.frame:CreateTexture(nil, "ARTWORK")
texture:SetTexture("Interface/Icons/achievement_general")

-- Add AceGUI button
local btn = AceGUI:Create("Button")
btn:SetText("Click Me")
btn:SetCallback("OnClick", function()
    PlaySound(SOUNDKIT.IG_MAINMENU_CLICK)
end)
frame:AddChild(btn)
```

### AceConfig-3.0 + WoW C_* APIs

```lua
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Options using WoW APIs
local options = {
    type = "group",
    args = {
        bracket = {
            name = "Bracket",
            type = "select",
            -- Use WoW API for values
            values = function()
                return {
                    ["2v2"] = "2v2 Arena",
                    ["3v3"] = "3v3 Arena",
                    ["5v5"] = "5v5 Arena",
                }
            end,
            get = function(info) 
                return C_PvP.GetBracketSeasonInfo(1).bracket
            end,
        },
        rating = {
            name = "Rating",
            type = "range",
            min = 0, max = 3000,
            get = function(info)
                -- Use WoW API
                return select(2, GetPersonalRatedInfo(1))
            end,
        }
    }
}

AceConfig:RegisterOptionsTable("MyAddon", options)
AceConfigDialog:Open("MyAddon")
```

### AceTimer-3.0 + WoW OnUpdate

```lua
local AceTimer = LibStub("AceTimer-3.0")
local MyAddon = AceAddon:NewAddon("MyAddon", "AceTimer-3.0")

function MyAddon:OnEnable()
    -- Ace timer for delayed execution
    self:ScheduleTimer("CheckArenaStatus", 5)
    
    -- Repeating timer
    self:ScheduleRepeatingTimer("UpdateUI", 0.5)
end

function MyAddon:CheckArenaStatus()
    -- Use WoW API with Ace timer
    local inArena = C_PvP.IsInArena()
    if inArena then
        print("In arena!")
    end
end

function MyAddon:UpdateUI()
    -- Called every 0.5 seconds
    local rating = select(2, GetPersonalRatedInfo(1))
    UpdateRatingDisplay(rating)
end
```

---

## 🏗️ Common Patterns

### Pattern 1: Event-Driven Combat Tracking

```lua
-- Ace3 setup
local MyAddon = AceAddon:NewAddon("MyAddon", "AceEvent-3.0", "AceDB-3.0")

-- WoW events
function MyAddon:OnEnable()
    self:RegisterEvent("ARENA_MATCH_BEGIN")
    self:RegisterEvent("ARENA_MATCH_END")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("PLAYER_TOOK_DAMAGE")
end

-- Handle with WoW APIs
function MyAddon:ARENA_MATCH_BEGIN()
    -- WoW API to get opponents
    for i = 1, 5 do
        local name = GetUnitName("arena" .. i)
        if name then
            self.db.profile.opponents[name] = {
                joined = GetTime(),
            }
        end
    end
end

function MyAddon:UNIT_SPELLCAST_SUCCEEDED(event, unit, spellName, rank, lineID, spellID)
    -- Track spell usage
    if unit:match("^arena") then
        local data = {
            time = GetTime(),
            spell = GetSpellInfo(spellID),
        }
        table.insert(self.db.profile.spellHistory, data)
    end
end
```

### Pattern 2: Configuration with Presets

```lua
local options = {
    type = "group",
    args = {
        -- Presets group
        presets = {
            name = "Presets",
            type = "group",
            args = {
                aggressive = {
                    name = "Aggressive",
                    type = "execute",
                    func = function(info)
                        -- Apply preset
                        self.db.profile.frameWidth = 350
                        self.db.profile.frameHeight = 150
                        self.db.profile.soundAlerts = true
                        
                        -- Refresh UI using WoW API
                        if self.frame then
                            self.frame:SetSize(350, 150)
                        end
                    end
                }
            }
        },
        
        -- Settings group with AceConfig
        frames = {
            name = "Frames",
            type = "group",
            args = {
                width = {
                    type = "range",
                    name = "Width",
                    min = 100, max = 500,
                    get = function(info) 
                        return self.db.profile.frameWidth 
                    end,
                    set = function(info, val)
                        self.db.profile.frameWidth = val
                        -- Update WoW frames
                        if self.frame then
                            self.frame:SetWidth(val)
                        end
                    end
                }
            }
        }
    }
}
```

### Pattern 3: Real-time Data Display

```lua
-- Use AceTimer for updates
function MyAddon:OnEnable()
    self:ScheduleRepeatingTimer("UpdateDisplay", 0.1)
end

function MyAddon:UpdateDisplay()
    -- Gather WoW data
    local rating = select(2, GetPersonalRatedInfo(1))
    local inArena = C_PvP.IsInArena()
    local time = GetTime()
    
    -- Update frame using WoW API
    if self.ratingText then
        self.ratingText:SetText("Rating: " .. rating)
    end
    
    -- Save to Ace DB
    self.db.profile.lastUpdate = time
    self.db.profile.currentRating = rating
end
```

---

## 🔗 API Reference Quick Links

### Ace3 Libraries
- **LibStub** - Library loading system
- **AceAddon-3.0** - Addon framework & lifecycle
- **AceEvent-3.0** - Event handling
- **AceDB-3.0** - SavedVariables database
- **AceConfig-3.0** - Options registration
- **AceGUI-3.0** - Widget library
- **AceTimer-3.0** - Timer scheduling
- **AceComm-3.0** - Inter-addon communication
- **AceHook-3.0** - Function/script hooking

### WoW APIs (PvP Relevant)
- **C_PvP** - PvP info (rating, bracket, arena)
- **GetPersonalRatedInfo()** - Get player rating
- **UnitName()** - Get unit name
- **GetUnitName()** - Alternative unit naming
- **GetTime()** - Current game time
- **PlaySound()** - Play audio
- **CreateFrame()** - Create UI frames
- **RegisterEvent()** - Native event registration

---

## 💡 Best Practices

1. **Always use Ace3 for:**
   - Event handling
   - Timer management
   - Configuration storage
   - Options UI

2. **Use WoW APIs for:**
   - Game state queries (C_PvP, UnitName, etc.)
   - Frame creation & manipulation
   - Audio playback
   - Combat data

3. **Combine them:**
   - Ace3 for structure & management
   - WoW APIs for data & UI implementation

---

**Arenamaster uses Ace3 + WoW APIs for professional addon development! 🚀**

Version: v4.0.0
Date: 2026-05-07
EOF
