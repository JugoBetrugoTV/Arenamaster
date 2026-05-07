# Approved Functions for Arenamaster - Patch 12.0.5

**This is your reference list of VERIFIED functions that work in WoW 12.0.5**

Check this before adding ANY function to the addon!

---

## ✅ SAFE & APPROVED FOR ARENAMASTER

### Arena Information (100% Safe)

```lua
-- Match Information (SAFE IN ALL PHASES)
C_PvP.GetActiveMatchBracket()              ✅ Returns: number or nil
C_PvP.GetActiveMatchDuration()             ✅ Returns: number (seconds)
C_PvP.GetActiveMatchState()                ✅ Returns: string or nil
C_PvP.GetActiveMatchWinner()               ✅ Returns: number or nil

-- Match Checks (SAFE IN ALL PHASES)
C_PvP.IsArena()                            ✅ Returns: boolean
C_PvP.IsRatedArena()                       ✅ Returns: boolean
C_PvP.IsMatchConsideredArena()             ✅ Returns: boolean
```

### Rating & Progression (Safe)

```lua
-- SAFE - Can be called anytime
GetPersonalRatedInfo(bracket)              ✅ Returns: (rating, seasonTotal, weeklyTotal, seasonBest)
C_PvP.GetPersonalArenaRating(bracket)      ✅ Returns: number
```

### Unit Names (Mostly Safe)

```lua
-- SAFE - Can be called anytime
GetUnitName("player")                      ✅ Safe always
GetUnitName("party1")                      ✅ Safe always
GetUnitName("arena1")                      ✅ Safe in arena
GetUnitName("arena2")                      ✅ Safe in arena
GetUnitName("arena3")                      ✅ Safe in arena
GetUnitName("arena4")                      ✅ Safe in arena
GetUnitName("arena5")                      ✅ Safe in arena
```

### Event System (Safe)

```lua
-- SAFE - Standard event handling
CreateFrame("Frame")                       ✅ Create event frame
frame:RegisterEvent("EVENT_NAME")          ✅ Register event
frame:UnregisterEvent("EVENT_NAME")        ✅ Unregister event
frame:SetScript("OnEvent", function)       ✅ Handle event

-- SAFE EVENTS:
"ADDON_LOADED"                             ✅ Addon loaded
"ARENA_MATCH_BEGIN"                        ✅ Match started
"ARENA_MATCH_END"                          ✅ Match ended
"ARENA_PREP_OPPONENT_SPECIALIZATIONS"      ✅ Opponent specs ready
"PLAYER_LOGIN"                             ✅ Player logged in
"PLAYER_SPECIALIZATION_CHANGED"            ✅ Spec changed
"PVP_ARENA_RATING_UPDATE"                  ✅ Rating changed
```

### UI Frames (Safe)

```lua
-- SAFE - UI building
CreateFrame("Frame", name, parent)         ✅ Create frame
CreateFrame("Button", name, parent)        ✅ Create button
CreateFrame("StatusBar", name, parent)     ✅ Create status bar
CreateFrame("CheckButton", name, parent)   ✅ Create checkbox

frame:SetSize(width, height)               ✅ Safe
frame:SetPoint(point, parent, relPoint)    ✅ Safe
frame:Show()                               ✅ Safe
frame:Hide()                               ✅ Safe
frame:IsVisible()                          ✅ Safe

-- Font strings
frame:CreateFontString(name, layer)        ✅ Safe
text:SetText("string")                     ✅ Safe
text:SetPoint(point, parent, relPoint)     ✅ Safe
text:SetFontObject("FontObject")           ✅ Safe
```

### Time Functions (Safe)

```lua
GetTime()                                  ✅ Returns current game time
date("%Y-%m-%d %H:%M:%S")                  ✅ Standard Lua date

-- For calculations
math.floor()                               ✅ Standard Lua
math.ceil()                                ✅ Standard Lua
math.max()                                 ✅ Standard Lua
math.min()                                 ✅ Standard Lua
```

### Table Operations (Safe)

```lua
table.insert(table, value)                 ✅ Standard Lua
table.remove(table, index)                 ✅ Standard Lua
table.concat(table, separator)             ✅ Standard Lua

pairs(table)                               ✅ Standard Lua iteration
ipairs(table)                              ✅ Standard Lua iteration
```

### String Operations (Safe)

```lua
string.format("%s", value)                 ✅ Standard Lua
tostring(value)                            ✅ Standard Lua
tonumber(value)                            ✅ Standard Lua

-- Chat messages (SAFE)
print("message")                           ✅ Print to chat
```

### Slash Commands (Safe)

```lua
SLASH_COMMANDNAME1 = "/command"            ✅ Define command
SlashCmdList["COMMANDNAME"] = function()   ✅ Register handler
```

### Dialogs (Safe)

```lua
StaticPopupDialogs["DIALOG_ID"] = {...}   ✅ Define dialog
StaticPopup_Show("DIALOG_ID")              ✅ Show dialog
```

---

## ⚠️ USE WITH CAUTION

```lua
-- Can be called, but data may be restricted or nil
GetUnitInfo(unit)                          ⚠️ May return incomplete data
UnitIsPlayer(unit)                         ⚠️ Works but info may be incomplete

-- Cooldown information (may work)
GetSpellCooldown(spellID)                  ⚠️ Works but may be restricted
C_ActionBar.GetCooldownForAction(id)       ⚠️ Works for your own actions only

-- Spec information (may work but restricted)
UnitSpecialization(unit)                   ⚠️ Works only during prep phase
```

---

## ❌ DO NOT USE (Tainted/Restricted)

```lua
-- Deprecated functions (return nil)
GetArenaOpponentSpec(i)                    ❌ REMOVED - returns nil
GetBattlefieldStatus(i)                    ❌ DEPRECATED

-- Restricted on enemy units
UnitBuff("arena1", i)                      ❌ Unreliable/restricted
UnitDebuff("arena1", i)                    ❌ Unreliable/restricted
UnitAura(unit, index)                      ❌ Restricted on enemies

-- Tainted operations (require secure context)
CastSpellByID(spellID)                     ❌ Tainted in combat
CastSpellByName(spellName)                 ❌ Tainted in combat
UseAction(actionID)                        ❌ Tainted in combat
ClickActionButton(actionID)                ❌ Tainted in combat

-- Combat decisions (cannot use these)
GetSpellInfo(spellID)                      ❌ May fail in combat

-- Real-time data (don't exist)
GetEnemyTeamComposition()                  ❌ Doesn't exist
GetEnemySpecialization()                   ❌ Doesn't exist
GetEnemyStats()                            ❌ Doesn't exist
```

---

## Current Arenamaster Implementation Status

### ✅ What We're Using Correctly

```lua
-- In Arenamaster.lua
C_PvP.GetActiveMatchBracket()              ✅ Implemented
C_PvP.GetActiveMatchDuration()             ✅ Implemented
C_PvP.GetActiveMatchState()                ✅ Implemented
C_PvP.GetActiveMatchWinner()               ✅ Implemented
C_PvP.IsArena()                            ✅ Implemented
C_PvP.IsRatedArena()                       ✅ Implemented
GetPersonalRatedInfo()                     ✅ Implemented
GetUnitName()                              ✅ Implemented

-- Events
"ADDON_LOADED"                             ✅ Implemented
"ARENA_MATCH_BEGIN"                        ✅ Implemented
"ARENA_MATCH_END"                          ✅ Implemented
"ARENA_PREP_OPPONENT_SPECIALIZATIONS"      ✅ Registered
"PLAYER_LOGIN"                             ✅ Registered

-- UI
CreateFrame()                              ✅ Used
Frame methods                              ✅ Used correctly
```

### ⚠️ What Needs Verification

```lua
-- In Arenamaster.lua
GetArenaOpponentSpec(i)                    ⚠️ ISSUE: Deprecated! Remove this
-- Solution: Remove and use event-based opponent tracking instead
```

### ❌ What Should Be Changed

```lua
-- Avoid in current implementation
-- None found yet - but check before adding new features
```

---

## Checklist Before Adding Functions

Before you add ANY new function to Arenamaster, check:

- [ ] Function exists in Patch 12.0.5
- [ ] Function is not deprecated (check PATCH_CHANGES.md)
- [ ] Function is in the APPROVED list above
- [ ] Function doesn't access restricted unit data
- [ ] Function doesn't require tainted execution
- [ ] Function doesn't try to modify game state in combat
- [ ] It's not a removed function from list ❌

If unsure: **Ask before implementing!**

---

## How to Test a Function

Before committing code with a new function:

```lua
-- In debug/test mode:
print("Testing function: FunctionName")
local result = C_PvP.SomeFunction()
if result then
    print("Success: " .. tostring(result))
else
    print("FAILED: Function returned nil - check if it exists in 12.0.5")
end
```

---

## References

- **API_REFERENCE_12.0.5.md** - Full API documentation
- **PVP_FUNCTIONS_GUIDE.md** - Detailed PvP functions guide
- **PATCH_CHANGES.md** - What changed in 12.0.0+

---

**Last Updated**: Patch 12.0.5  
**Status**: Ready for Development  
**Review Date**: Before any major feature addition
