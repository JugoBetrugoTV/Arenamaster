# Additional APIs for Extended Features - Patch 12.0.5

**Ergänzende APIs die in der Hauptdokumentation noch nicht detailliert dokumentiert sind**

---

## 🆕 C_Item Namespace - 117 Functions

Für Equipment-Tracking und Item-Analyse:

```lua
-- Item Information
C_Item.GetItemInfo(itemID)                 -- Returns item details
C_Item.GetItemName(itemID)                 -- Returns item name
C_Item.GetItemQuality(itemID)              -- Returns quality (0-7)

-- Equipment & Inventory
C_Item.IsEquippedItem(itemID)              -- Check if equipped
C_Item.IsEquippableItem(itemID)            -- Can be equipped?
C_Item.GetItemStats(itemID)                -- Returns item stats

-- Item Classification
C_Item.IsConsumableItem(itemID)            -- Is consumable?
C_Item.IsArtifactPowerItem(itemID)         -- Is artifact power?
C_Item.IsCosmeticItem(itemID)              -- Is cosmetic?

-- Transmog & Collections
C_Item.IsItemEligibleForTransmogrification()
C_Item.GetItemAppearanceID()               -- For transmog tracking
```

**Use Case**: Track opponent's gear ilvl, detect consumable usage patterns

---

## 🎯 C_SpecializationInfo Namespace - 25 Functions

Für Spezialisierungs-Tracking:

```lua
-- Specialization Queries
C_SpecializationInfo.GetSpecialization()   -- Get your current spec
C_SpecializationInfo.GetSpecializationInfo(specID)  -- Get spec details
C_SpecializationInfo.GetMasterySpells()    -- Get mastery spells

-- PvP Talents
C_SpecializationInfo.GetPvpTalentInfo(talentID)  -- Get PvP talent details
C_SpecializationInfo.GetAllSelectedPvpTalentIDs()  -- Get selected PvP talents
C_SpecializationInfo.IsPvpTalentLocked(talentID)  -- Check if locked

-- Talent Management
C_SpecializationInfo.SetSpecialization(specID)  -- Switch spec
C_SpecializationInfo.CanPlayerUseTalentUI()  -- Can modify talents?

-- Class & Spec Info
C_SpecializationInfo.GetClassIDFromSpecID(specID)  -- Get class from spec
C_SpecializationInfo.GetNumSpecializationsForClassID(classID)  -- Count specs

-- Events
"PLAYER_TALENT_UPDATE"                     -- Talents changed
"PLAYER_PVP_TALENT_UPDATE"                 -- PvP talents changed
"SPEC_INVOLUNTARILY_CHANGED"               -- Forced spec change
```

**Use Case**: Track opponent spec changes, predict build from talents, counter-pick analysis

---

## 🗺️ C_Minimap Namespace - 24 Functions

Für Minimap-Features und Arena-Anzeige:

```lua
-- Tracking Control
C_Minimap.SetTracking(trackingID, value)   -- Enable/disable tracking
C_Minimap.GetTrackingInfo()                -- Get all tracking info
C_Minimap.ClearAllTracking()               -- Disable all tracking

-- Display Settings
C_Minimap.SetDrawGroundTextures(enabled)   -- Show/hide ground
C_Minimap.GetViewRadius()                  -- Get minimap zoom radius
C_Minimap.IsFilteredOut(filterID)          -- Check if hidden

-- Quest & Location
C_Minimap.IsInsideQuestBlob(questID)       -- In quest area?
C_Minimap.IsTrackingHiddenQuests()         -- Tracking hidden quests?

-- Configuration
C_Minimap.SetMinimapInsetInfo(insetX, insetY)
C_Minimap.SetIgnoreRotateMinimap(ignore)

-- Events
"MINIMAP_PING"                             -- Someone pinged minimap
"MINIMAP_UPDATE_TRACKING"                  -- Tracking changed
"MINIMAP_UPDATE_ZOOM"                      -- Zoom changed
```

**Use Case**: Display arena opponent locations, track movement patterns, minimap indicators

---

## 🛠️ C_TradeSkillUI Namespace - 88 Functions

Für Crafting-Info und Profession-Tracking:

```lua
-- Profession Info
C_TradeSkillUI.GetBaseProfessionInfo()     -- Get profession details
C_TradeSkillUI.GetProfessionSkillLineID()  -- Get skill line
C_TradeSkillUI.GetProfessionSpells()       -- Get spells

-- Recipe Management
C_TradeSkillUI.GetRecipeInfo(recipeID)     -- Get recipe details
C_TradeSkillUI.IsRecipeTracked(recipeID)   -- Tracking recipe?
C_TradeSkillUI.SetRecipeTracked(recipeID, track)

-- Crafting
C_TradeSkillUI.CraftRecipe(recipeID)       -- Craft item
C_TradeSkillUI.CraftEnchant(enchantID)     -- Apply enchant
C_TradeSkillUI.CraftSalvage()              -- Salvage items

-- Quality & Reagents
C_TradeSkillUI.GetQualitiesForRecipe(recipeID)  -- Quality options
C_TradeSkillUI.GetDependentReagents()      -- Required components
C_TradeSkillUI.GetReagentSlotStatus()      -- Reagent availability

-- UI
C_TradeSkillUI.OpenTradeSkill()            -- Show profession window
C_TradeSkillUI.CloseTradeSkill()           -- Hide window

-- Events (20 total)
"TRADE_SKILL_SHOW"                         -- Profession opened
"TRADE_SKILL_CLOSE"                        -- Profession closed
"TRADE_SKILL_LIST_UPDATE"                  -- Recipes updated
```

**Use Case**: Analyze opponent's profession choices, flasks/potions prediction

---

## 📊 C_ChatInfo Namespace - Chat & Communication

```lua
-- Chat Messages
SendChatMessage(message, chatType)         -- Send chat message
GetChatTypeColor(chatType)                 -- Get color for chat type

-- Chat Filters
ChatFrame_AddMessageGroup(chatFrame, group)
ChatFrame_RemoveMessageGroup(chatFrame, group)
```

**Use Case**: Log arena events to chat, announcements

---

## 🎪 C_Timer Namespace - Scheduling

```lua
-- Timers (for UI updates)
C_Timer.NewTimer(duration, func)           -- Create timer
C_Timer.After(delay, func)                 -- Call function after delay
```

**Use Case**: Periodic UI updates, cooldown timers, match duration display

---

## 📋 Summary: What We Have Available

### ✅ Currently Using:
- C_PvP (arena functions)
- C_SpecializationInfo (spec info - partially)

### ⚠️ Can Use For Features:
- C_Item (gear analysis)
- C_SpecializationInfo (full PvP talent analysis)
- C_Minimap (arena map display)
- C_Timer (UI timers)
- C_TradeSkillUI (profession analysis)

### ❌ Limited/Unavailable:
- Real-time buff/debuff reading
- Tainted combat decision-making
- C_Arena (doesn't exist - use C_PvP instead)

---

## 🎯 Next Steps

1. Review this list
2. Choose which features to implement
3. Check APPROVED_FUNCTIONS.md before coding
4. Build awesome features!

---

**Last Updated**: May 7, 2026  
**Status**: Ready for Implementation
