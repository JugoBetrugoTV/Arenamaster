-- Arenamaster: Configuration Module (Enhanced)
-- Advanced configuration system with presets, recommendations & UI enhancements

local AM = Arenamaster
local ConfigManager = {}

-- Configuration categories with visual enhancements
local CONFIG_CATEGORIES = {
    FRAMES = {name = "Enemy Frames", icon = "🎯", color = "|cffff6b6b", priority = 1},
    AURAS = {name = "Aura Tracking", icon = "⚡", color = "|cffffff00", priority = 2},
    NOTIFICATIONS = {name = "Notifications", icon = "📢", color = "|cff4dabf7", priority = 3},
    UI = {name = "UI Settings", icon = "🎨", color = "|cff9775fa", priority = 4},
    STATS = {name = "Statistics", icon = "📊", color = "|cff51cf66", priority = 5},
}

-- ===========================
-- PRESETS & QUICK-CONFIGS
-- ===========================

local PRESETS = {
    AGGRESSIVE = {
        name = "🔥 Aggressive",
        description = "Large frames, maximum visibility, all notifications enabled",
        icon = "🔴",
        settings = {
            frameLayout = "horizontal",
            frameWidth = 280,
            frameHeight = 110,
            frameOpacity = 1,
            showHealthText = true,
            showManaBar = true,
            showCastBar = true,
            showTrinket = true,
            showBuffs = true,
            showDebuffs = true,
            soundAlerts = true,
            chatAnnouncements = true,
            fontSize = 12,
        }
    },
    COMPETITIVE = {
        name = "⚔️ Competitive",
        description = "Balanced setup optimized for serious ranked play",
        icon = "🟡",
        settings = {
            frameLayout = "vertical",
            frameWidth = 220,
            frameHeight = 85,
            frameOpacity = 0.95,
            frameSpacing = 8,
            showHealthText = true,
            showManaBar = true,
            showCastBar = true,
            showTrinket = true,
            soundAlerts = true,
            fontSize = 11,
        }
    },
    STREAMER = {
        name = "🎥 Streamer",
        description = "Large, beautiful UI optimized for stream visibility",
        icon = "🟢",
        settings = {
            frameLayout = "horizontal",
            frameWidth = 320,
            frameHeight = 120,
            frameOpacity = 1,
            showHealthText = true,
            showManaBar = true,
            showCastBar = true,
            showTrinket = true,
            showBuffs = true,
            showDebuffs = true,
            soundAlerts = true,
            chatAnnouncements = true,
            fontSize = 13,
            uiTheme = "Dark",
        }
    },
    MINIMAL = {
        name = "⚪ Minimal",
        description = "Ultra-clean interface for distraction-free gameplay",
        icon = "⚪",
        settings = {
            frameLayout = "vertical",
            frameWidth = 180,
            frameHeight = 60,
            frameOpacity = 0.75,
            showHealthText = false,
            showManaBar = false,
            showCastBar = true,
            showTrinket = true,
            soundAlerts = false,
            fontSize = 9,
        }
    },
    CASUAL = {
        name = "🎮 Casual",
        description = "Relaxed setup with optional notifications",
        icon = "🟣",
        settings = {
            frameLayout = "grid",
            frameWidth = 200,
            frameHeight = 80,
            frameOpacity = 0.85,
            showHealthText = true,
            showManaBar = true,
            showCastBar = false,
            showTrinket = true,
            soundAlerts = false,
            fontSize = 10,
        }
    },
}

-- ===========================
-- ALL AVAILABLE SETTINGS
-- ===========================

local SETTINGS = {
    -- FRAMES: Layout & Positioning
    {
        key = "frameLayout",
        category = "FRAMES",
        name = "Frame Layout",
        type = "select",
        options = {"vertical", "horizontal", "grid"},
        default = "vertical",
        description = "How opponent frames are displayed",
        group = "Layout",
        icon = "📋",
        suggestedValues = {competitive = "vertical", aggressive = "horizontal", casual = "grid"},
    },
    {
        key = "frameWidth",
        category = "FRAMES",
        name = "Frame Width",
        type = "slider",
        min = 150,
        max = 350,
        step = 10,
        default = 220,
        description = "Width of each opponent frame",
        group = "Layout",
        suggestedValues = {competitive = 220, aggressive = 280, minimal = 180, streamer = 320},
    },
    {
        key = "frameHeight",
        category = "FRAMES",
        name = "Frame Height",
        type = "slider",
        min = 60,
        max = 150,
        step = 5,
        default = 85,
        description = "Height of each opponent frame",
        group = "Layout",
        suggestedValues = {competitive = 85, aggressive = 110, minimal = 60, streamer = 120},
    },
    {
        key = "frameSpacing",
        category = "FRAMES",
        name = "Frame Spacing",
        type = "slider",
        min = 0,
        max = 20,
        step = 1,
        default = 8,
        description = "Space between frames",
        group = "Layout",
    },
    {
        key = "frameOpacity",
        category = "FRAMES",
        name = "Frame Opacity",
        type = "slider",
        min = 0.3,
        max = 1,
        step = 0.05,
        default = 0.95,
        description = "Transparency (lower = more transparent)",
        group = "Appearance",
        suggestedValues = {streamer = 1, competitive = 0.95, casual = 0.85},
    },
    {
        key = "framePositionX",
        category = "FRAMES",
        name = "Position X",
        type = "slider",
        min = -500,
        max = 2500,
        step = 10,
        default = 100,
        description = "Horizontal position on screen",
        group = "Position",
    },
    {
        key = "framePositionY",
        category = "FRAMES",
        name = "Position Y",
        type = "slider",
        min = -500,
        max = 1500,
        step = 10,
        default = 200,
        description = "Vertical position on screen",
        group = "Position",
    },

    -- FRAMES: Display Options
    {
        key = "showFrameNames",
        category = "FRAMES",
        name = "Show Names",
        type = "checkbox",
        default = true,
        description = "Display opponent names on frames",
        group = "Display",
    },
    {
        key = "showHealthText",
        category = "FRAMES",
        name = "Show Health %",
        type = "checkbox",
        default = true,
        description = "Display health percentage numbers",
        group = "Display",
    },
    {
        key = "showManaBar",
        category = "FRAMES",
        name = "Show Mana Bar",
        type = "checkbox",
        default = true,
        description = "Display mana/energy/rage bar",
        group = "Display",
    },
    {
        key = "showCastBar",
        category = "FRAMES",
        name = "Show Cast Bar",
        type = "checkbox",
        default = true,
        description = "Display spell casting progress",
        group = "Display",
    },
    {
        key = "showTrinket",
        category = "FRAMES",
        name = "Show Trinket",
        type = "checkbox",
        default = true,
        description = "Display trinket cooldown status",
        group = "Display",
    },
    {
        key = "showBuffs",
        category = "FRAMES",
        name = "Show Buffs",
        type = "checkbox",
        default = true,
        description = "Display beneficial auras",
        group = "Display",
    },
    {
        key = "showDebuffs",
        category = "FRAMES",
        name = "Show Debuffs",
        type = "checkbox",
        default = true,
        description = "Display CC and harmful effects",
        group = "Display",
    },

    -- AURAS: Tracking Options
    {
        key = "auraTrackingEnabled",
        category = "AURAS",
        name = "Enable Tracking",
        type = "checkbox",
        default = true,
        description = "Master switch for aura tracking",
        group = "Core",
    },
    {
        key = "trackCooldowns",
        category = "AURAS",
        name = "Track Cooldowns",
        type = "checkbox",
        default = true,
        description = "Monitor enemy ability cooldowns",
        group = "Tracking",
    },
    {
        key = "trackBuffs",
        category = "AURAS",
        name = "Track Buffs",
        type = "checkbox",
        default = true,
        description = "Monitor beneficial auras",
        group = "Tracking",
    },
    {
        key = "trackDebuffs",
        category = "AURAS",
        name = "Track Debuffs",
        type = "checkbox",
        default = true,
        description = "Monitor crowd control effects",
        group = "Tracking",
    },
    {
        key = "showCountdown",
        category = "AURAS",
        name = "Show Countdown",
        type = "checkbox",
        default = true,
        description = "Display remaining cooldown time",
        group = "Display",
    },

    -- NOTIFICATIONS: Alert System
    {
        key = "notifyMatchStart",
        category = "NOTIFICATIONS",
        name = "Match Start",
        type = "checkbox",
        default = true,
        description = "Alert when arena match begins",
        group = "Events",
    },
    {
        key = "notifyMatchEnd",
        category = "NOTIFICATIONS",
        name = "Match End",
        type = "checkbox",
        default = true,
        description = "Alert when arena match ends",
        group = "Events",
    },
    {
        key = "soundAlerts",
        category = "NOTIFICATIONS",
        name = "Sound Alerts",
        type = "checkbox",
        default = true,
        description = "Play sound for important events",
        group = "Audio",
    },
    {
        key = "chatAnnouncements",
        category = "NOTIFICATIONS",
        name = "Chat Announcements",
        type = "checkbox",
        default = false,
        description = "Announce events in chat channel",
        group = "Output",
    },
    {
        key = "colorChatMessages",
        category = "NOTIFICATIONS",
        name = "Colored Messages",
        type = "checkbox",
        default = true,
        description = "Use colors in chat announcements",
        group = "Output",
    },

    -- UI: Appearance & Theme
    {
        key = "showCloseButton",
        category = "UI",
        name = "Show Close Button",
        type = "checkbox",
        default = true,
        description = "Display close button on main window",
        group = "Interface",
    },
    {
        key = "uiTheme",
        category = "UI",
        name = "UI Theme",
        type = "select",
        options = {"Dark", "Light", "Classic"},
        default = "Dark",
        description = "Color scheme for all UI elements",
        group = "Theme",
    },
    {
        key = "fontSize",
        category = "UI",
        name = "Font Size",
        type = "slider",
        min = 8,
        max = 16,
        step = 1,
        default = 11,
        description = "Text size in interface",
        group = "Theme",
        suggestedValues = {aggressive = 12, competitive = 11, streamer = 13, minimal = 9},
    },

    -- STATS: Tracking & Recording
    {
        key = "trackGames",
        category = "STATS",
        name = "Track Games",
        type = "checkbox",
        default = true,
        description = "Record all arena matches",
        group = "Recording",
    },
    {
        key = "trackOpponents",
        category = "STATS",
        name = "Track Opponents",
        type = "checkbox",
        default = true,
        description = "Store opponent encounter data",
        group = "Recording",
    },
    {
        key = "trackRating",
        category = "STATS",
        name = "Track Rating",
        type = "checkbox",
        default = true,
        description = "Monitor rating changes",
        group = "Recording",
    },
}

-- ===========================
-- INITIALIZATION
-- ===========================

function ConfigManager:Initialize()
    if not ArenamasterDB.config then
        ArenamasterDB.config = {}
    end

    -- Set defaults for missing settings
    for _, setting in ipairs(SETTINGS) do
        if ArenamasterDB.config[setting.key] == nil then
            ArenamasterDB.config[setting.key] = setting.default
        end
    end
end

-- ===========================
-- GETTERS & SETTERS
-- ===========================

function ConfigManager:Get(key)
    return ArenamasterDB.config[key]
end

function ConfigManager:Set(key, value)
    local valid, msg = self:ValidateSetting(key, value)
    if not valid then
        return false, msg
    end

    ArenamasterDB.config[key] = value

    -- Notify modules of config change
    if AM.EnemyFrames and key:find("frame") then
        AM.EnemyFrames:UpdateConfig(key, value)
    end
    if AM.AuraTracker and key:find("aura") then
        AM.AuraTracker:UpdateConfig(key, value)
    end

    return true
end

function ConfigManager:GetAll()
    return ArenamasterDB.config
end

-- ===========================
-- PRESET MANAGEMENT
-- ===========================

function ConfigManager:ApplyPreset(presetName)
    local preset = PRESETS[presetName]
    if not preset then
        return false, "Preset not found: " .. presetName
    end

    for key, value in pairs(preset.settings) do
        self:Set(key, value)
    end

    print("|cff00ff00[Arenamaster]|r Applied preset: " .. preset.name)
    return true
end

function ConfigManager:GetPresets()
    local result = {}
    for key, preset in pairs(PRESETS) do
        table.insert(result, {key = key, name = preset.name, description = preset.description, icon = preset.icon})
    end
    return result
end

function ConfigManager:PrintPresets()
    print("|cff00ffff╔════════════════════════════════════════╗|r")
    print("|cff00ffff║       AVAILABLE PRESETS                ║|r")
    print("|cff00ffff╠════════════════════════════════════════╣|r")

    for key, preset in pairs(PRESETS) do
        print(string.format("|cff00ffff║ %s %s|r", preset.icon, preset.name))
        print(string.format("|cffcccccc║ %s|r", preset.description))
        print("|cff00ffff║ → /am preset %s|r", key:lower())
        print("|cff00ffff╟────────────────────────────────────────╢|r")
    end

    print("|cff00ffff╚════════════════════════════════════════╝|r")
end

-- ===========================
-- RESET FUNCTIONS
-- ===========================

function ConfigManager:ResetToDefaults()
    for _, setting in ipairs(SETTINGS) do
        ArenamasterDB.config[setting.key] = setting.default
    end
    print("|cff00ff00[Arenamaster]|r All settings reset to defaults")
end

function ConfigManager:ResetCategory(category)
    local count = 0
    for _, setting in ipairs(SETTINGS) do
        if setting.category == category then
            ArenamasterDB.config[setting.key] = setting.default
            count = count + 1
        end
    end
    print(string.format("|cff00ff00[Arenamaster]|r Reset %d settings in %s", count, CONFIG_CATEGORIES[category].name))
end

-- ===========================
-- SETTING INFORMATION & SEARCH
-- ===========================

function ConfigManager:GetSettings(category)
    local result = {}
    for _, setting in ipairs(SETTINGS) do
        if not category or setting.category == category then
            table.insert(result, setting)
        end
    end
    return result
end

function ConfigManager:GetSetting(key)
    for _, setting in ipairs(SETTINGS) do
        if setting.key == key then
            return setting
        end
    end
    return nil
end

function ConfigManager:GetCategories()
    local categories = {}
    for _, setting in ipairs(SETTINGS) do
        if not tContains(categories, setting.category) then
            table.insert(categories, setting.category)
        end
    end
    table.sort(categories, function(a, b)
        return (CONFIG_CATEGORIES[a].priority or 99) < (CONFIG_CATEGORIES[b].priority or 99)
    end)
    return categories
end

function ConfigManager:SearchSettings(keyword)
    local results = {}
    keyword = keyword:lower()

    for _, setting in ipairs(SETTINGS) do
        if setting.name:lower():find(keyword) or
           setting.description:lower():find(keyword) or
           setting.key:lower():find(keyword) then
            table.insert(results, setting)
        end
    end

    return results
end

function ConfigManager:GetSuggestion(key)
    local setting = self:GetSetting(key)
    if not setting or not setting.suggestedValues then
        return nil
    end

    local suggestions = {}
    for playstyle, value in pairs(setting.suggestedValues) do
        table.insert(suggestions, {playstyle = playstyle, value = value})
    end
    return suggestions
end

-- ===========================
-- PROFILE MANAGEMENT
-- ===========================

function ConfigManager:SaveProfile(profileName)
    if not ArenamasterDB.profiles then
        ArenamasterDB.profiles = {}
    end

    ArenamasterDB.profiles[profileName] = {
        config = {},
        savedAt = date("%Y-%m-%d %H:%M:%S"),
        version = "4.0.0",
    }

    for key, value in pairs(ArenamasterDB.config) do
        ArenamasterDB.profiles[profileName].config[key] = value
    end

    print("|cff00ff00[Arenamaster]|r ✓ Profile saved: " .. profileName)
    return true
end

function ConfigManager:LoadProfile(profileName)
    if not ArenamasterDB.profiles or not ArenamasterDB.profiles[profileName] then
        print("|cffff0000[Arenamaster]|r ✗ Profile not found: " .. profileName)
        return false
    end

    local profile = ArenamasterDB.profiles[profileName]
    for key, value in pairs(profile.config) do
        self:Set(key, value)
    end

    print("|cff00ff00[Arenamaster]|r ✓ Loaded: " .. profileName)
    return true
end

function ConfigManager:DeleteProfile(profileName)
    if ArenamasterDB.profiles then
        ArenamasterDB.profiles[profileName] = nil
        print("|cff00ff00[Arenamaster]|r ✓ Profile deleted: " .. profileName)
        return true
    end
    return false
end

function ConfigManager:GetProfiles()
    if not ArenamasterDB.profiles then
        return {}
    end

    local profiles = {}
    for name, data in pairs(ArenamasterDB.profiles) do
        table.insert(profiles, {
            name = name,
            savedAt = data.savedAt or "Unknown",
            version = data.version or "Unknown"
        })
    end
    return profiles
end

function ConfigManager:PrintProfiles()
    local profiles = self:GetProfiles()

    print("|cff00ffff╔════════════════════════════════════════╗|r")
    print("|cff00ffff║       SAVED PROFILES                   ║|r")
    print("|cff00ffff╠════════════════════════════════════════╣|r")

    if #profiles == 0 then
        print("|cffcccccc║ No profiles saved yet|r")
    else
        for _, profile in ipairs(profiles) do
            print(string.format("|cff00ffff║ 💾 %s|r", profile.name))
            print(string.format("|cffcccccc║    Saved: %s|r", profile.savedAt))
            print("|cff00ffff╟────────────────────────────────────────╢|r")
        end
    end

    print("|cff00ffff╚════════════════════════════════════════╝|r")
end

-- ===========================
-- IMPORT/EXPORT
-- ===========================

function ConfigManager:ExportConfig()
    local exportStr = ""
    for key, value in pairs(ArenamasterDB.config) do
        if type(value) == "boolean" then
            value = value and "1" or "0"
        end
        exportStr = exportStr .. key .. "=" .. tostring(value) .. ";"
    end
    return exportStr
end

function ConfigManager:ImportConfig(importStr)
    local count = 0
    for setting in importStr:gmatch("[^;]+") do
        local key, value = setting:match("([^=]+)=(.+)")
        if key and value then
            if value == "1" then
                value = true
            elseif value == "0" then
                value = false
            elseif tonumber(value) then
                value = tonumber(value)
            end
            local valid, _ = self:ValidateSetting(key, value)
            if valid then
                self:Set(key, value)
                count = count + 1
            end
        end
    end
    print("|cff00ff00[Arenamaster]|r ✓ Imported " .. count .. " settings")
    return count
end

function ConfigManager:ExportToChat()
    local export = self:ExportConfig()
    print("|cff00ffff[EXPORT STRING]|r")
    print(export)
    print("|cffcccccc(Copy the string above)|r")
end

-- ===========================
-- VALIDATION & COMPATIBILITY
-- ===========================

function ConfigManager:ValidateSetting(key, value)
    local setting = self:GetSetting(key)
    if not setting then
        return false, "Unknown setting"
    end

    if setting.type == "slider" then
        if type(value) ~= "number" then
            return false, "Must be a number"
        end
        if value < setting.min or value > setting.max then
            return false, string.format("Must be between %d and %d", setting.min, setting.max)
        end
    elseif setting.type == "select" then
        if not tContains(setting.options, value) then
            return false, "Invalid option. Valid: " .. table.concat(setting.options, ", ")
        end
    elseif setting.type == "checkbox" then
        if type(value) ~= "boolean" then
            return false, "Must be true or false"
        end
    end

    return true, "Valid"
end

function ConfigManager:CheckCompatibility()
    local issues = {}

    -- Frame size compatibility
    if self:Get("frameWidth") > 1920 or self:Get("frameHeight") > 1080 then
        table.insert(issues, "Frame size may exceed screen boundaries")
    end

    -- Layout compatibility
    if self:Get("frameLayout") == "grid" and self:Get("frameWidth") < 150 then
        table.insert(issues, "Grid layout works better with wider frames")
    end

    return issues
end

-- ===========================
-- PRINTING & DEBUG
-- ===========================

function ConfigManager:PrintCategorySettings(category)
    local settings = self:GetSettings(category)
    local catInfo = CONFIG_CATEGORIES[category]

    print(string.format("|cff00ffff╔════════════════════════════════════════╗|r"))
    print(string.format("|cff00ffff║ %s %s|r", catInfo.icon, catInfo.name))
    print(string.format("|cff00ffff╠════════════════════════════════════════╣|r"))

    local currentGroup = nil
    for _, setting in ipairs(settings) do
        if setting.group and setting.group ~= currentGroup then
            currentGroup = setting.group
            print(string.format("|cffcccccc╟─ %s─────────────────────────────╢|r", currentGroup))
        end

        local value = self:Get(setting.key)
        local displayValue = tostring(value)

        if setting.type == "slider" then
            displayValue = string.format("%.1f", value)
        end

        print(string.format("|cff00ffff║ %s %s|r: |cffcccccc%s|r", setting.icon or "•", setting.name, displayValue))
        print(string.format("|cffcccccc║ %s|r", setting.description))
    end

    print(string.format("|cff00ffff╚════════════════════════════════════════╝|r"))
end

function ConfigManager:PrintAllSettings()
    local categories = self:GetCategories()

    print("|cff00ffff╔════════════════════════════════════════╗|r")
    print("|cff00ffff║     ALL ARENAMASTER SETTINGS           ║|r")
    print("|cff00ffff╠════════════════════════════════════════╣|r")

    for _, category in ipairs(categories) do
        self:PrintCategorySettings(category)
        print("")
    end
end

function ConfigManager:PrintCurrentConfig()
    print("|cff00ffff╔════════════════════════════════════════╗|r")
    print("|cff00ffff║     CURRENT CONFIGURATION              ║|r")
    print("|cff00ffff╠════════════════════════════════════════╣|r")

    for _, setting in ipairs(SETTINGS) do
        local value = self:Get(setting.key)
        if setting.type == "slider" then
            value = string.format("%.2f", value)
        end
        print(string.format("|cffcccccc%s: %s|r", setting.key, tostring(value)))
    end

    print("|cff00ffff╚════════════════════════════════════════╝|r")
end

-- Export
AM.ConfigManager = ConfigManager

return ConfigManager
