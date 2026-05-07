-- Arenamaster: Configuration Module
-- Advanced configuration system for all features

local AM = Arenamaster
local ConfigManager = {}

-- Configuration categories
local CONFIG_CATEGORIES = {
    FRAMES = "Enemy Frames",
    AURAS = "Aura Tracking",
    NOTIFICATIONS = "Notifications",
    UI = "UI Settings",
    STATS = "Statistics",
}

-- All available settings
local SETTINGS = {
    -- Enemy Frames Settings
    {
        key = "frameLayout",
        category = "FRAMES",
        name = "Frame Layout",
        type = "select",
        options = {"vertical", "horizontal", "grid"},
        default = "vertical",
        description = "How opponent frames are arranged"
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
        description = "Width of each opponent frame"
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
        description = "Height of each opponent frame"
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
        description = "Space between frames"
    },
    {
        key = "frameOpacity",
        category = "FRAMES",
        name = "Frame Opacity",
        type = "slider",
        min = 0.3,
        max = 1,
        step = 0.1,
        default = 0.95,
        description = "Frame transparency (0.3 = transparent, 1 = opaque)"
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
        description = "Horizontal position"
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
        description = "Vertical position"
    },

    -- Display Options
    {
        key = "showFrameNames",
        category = "FRAMES",
        name = "Show Names",
        type = "checkbox",
        default = true,
        description = "Display opponent names"
    },
    {
        key = "showHealthText",
        category = "FRAMES",
        name = "Show Health %",
        type = "checkbox",
        default = true,
        description = "Display health percentage"
    },
    {
        key = "showManaBar",
        category = "FRAMES",
        name = "Show Mana Bar",
        type = "checkbox",
        default = true,
        description = "Display mana/energy/rage bar"
    },
    {
        key = "showCastBar",
        category = "FRAMES",
        name = "Show Cast Bar",
        type = "checkbox",
        default = true,
        description = "Display spell casting bar"
    },
    {
        key = "showTrinket",
        category = "FRAMES",
        name = "Show Trinket",
        type = "checkbox",
        default = true,
        description = "Display trinket cooldown"
    },
    {
        key = "showBuffs",
        category = "FRAMES",
        name = "Show Buffs",
        type = "checkbox",
        default = true,
        description = "Display beneficial auras"
    },
    {
        key = "showDebuffs",
        category = "FRAMES",
        name = "Show Debuffs",
        type = "checkbox",
        default = true,
        description = "Display harmful auras/CC"
    },

    -- Aura Tracking Settings
    {
        key = "auraTrackingEnabled",
        category = "AURAS",
        name = "Enable Tracking",
        type = "checkbox",
        default = true,
        description = "Track cooldowns and auras"
    },
    {
        key = "trackCooldowns",
        category = "AURAS",
        name = "Track Cooldowns",
        type = "checkbox",
        default = true,
        description = "Monitor enemy ability cooldowns"
    },
    {
        key = "trackBuffs",
        category = "AURAS",
        name = "Track Buffs",
        type = "checkbox",
        default = true,
        description = "Monitor beneficial auras"
    },
    {
        key = "trackDebuffs",
        category = "AURAS",
        name = "Track Debuffs",
        type = "checkbox",
        default = true,
        description = "Monitor crowd control effects"
    },
    {
        key = "showCountdown",
        category = "AURAS",
        name = "Show Countdown",
        type = "checkbox",
        default = true,
        description = "Display remaining cooldown time"
    },

    -- Notifications
    {
        key = "notifyMatchStart",
        category = "NOTIFICATIONS",
        name = "Match Start Notification",
        type = "checkbox",
        default = true,
        description = "Alert when arena match begins"
    },
    {
        key = "notifyMatchEnd",
        category = "NOTIFICATIONS",
        name = "Match End Notification",
        type = "checkbox",
        default = true,
        description = "Alert when arena match ends"
    },
    {
        key = "soundAlerts",
        category = "NOTIFICATIONS",
        name = "Sound Alerts",
        type = "checkbox",
        default = true,
        description = "Play sound for important events"
    },
    {
        key = "chatAnnouncements",
        category = "NOTIFICATIONS",
        name = "Chat Announcements",
        type = "checkbox",
        default = false,
        description = "Announce events in chat"
    },
    {
        key = "colorChatMessages",
        category = "NOTIFICATIONS",
        name = "Colored Messages",
        type = "checkbox",
        default = true,
        description = "Use color in announcements"
    },

    -- UI Settings
    {
        key = "showCloseButton",
        category = "UI",
        name = "Show Close Button",
        type = "checkbox",
        default = true,
        description = "Display close button on main window"
    },
    {
        key = "uiTheme",
        category = "UI",
        name = "UI Theme",
        type = "select",
        options = {"Dark", "Light", "Classic"},
        default = "Dark",
        description = "Color scheme for interface"
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
        description = "Text size in interface"
    },

    -- Statistics
    {
        key = "trackGames",
        category = "STATS",
        name = "Track Games",
        type = "checkbox",
        default = true,
        description = "Record all arena matches"
    },
    {
        key = "trackOpponents",
        category = "STATS",
        name = "Track Opponents",
        type = "checkbox",
        default = true,
        description = "Store opponent encounter data"
    },
    {
        key = "trackRating",
        category = "STATS",
        name = "Track Rating",
        type = "checkbox",
        default = true,
        description = "Monitor rating changes"
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
    ArenamasterDB.config[key] = value

    -- Notify modules of config change
    if AM.EnemyFrames and key:find("frame") then
        AM.EnemyFrames:UpdateConfig(key, value)
    end
    if AM.AuraTracker and key:find("aura") then
        AM.AuraTracker:UpdateConfig(key, value)
    end
end

function ConfigManager:GetAll()
    return ArenamasterDB.config
end

function ConfigManager:ResetToDefaults()
    for _, setting in ipairs(SETTINGS) do
        ArenamasterDB.config[setting.key] = setting.default
    end
end

-- ===========================
-- SETTING INFORMATION
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
    return categories
end

-- ===========================
-- PROFILE MANAGEMENT
-- ===========================

function ConfigManager:SaveProfile(profileName)
    if not ArenamasterDB.profiles then
        ArenamasterDB.profiles = {}
    end

    ArenamasterDB.profiles[profileName] = {}
    for key, value in pairs(ArenamasterDB.config) do
        ArenamasterDB.profiles[profileName][key] = value
    end

    print("|cff00ff00[Arenamaster]|r Profile saved: " .. profileName)
end

function ConfigManager:LoadProfile(profileName)
    if not ArenamasterDB.profiles or not ArenamasterDB.profiles[profileName] then
        print("|cffff0000[Arenamaster]|r Profile not found: " .. profileName)
        return false
    end

    for key, value in pairs(ArenamasterDB.profiles[profileName]) do
        self:Set(key, value)
    end

    print("|cff00ff00[Arenamaster]|r Profile loaded: " .. profileName)
    return true
end

function ConfigManager:DeleteProfile(profileName)
    if ArenamasterDB.profiles then
        ArenamasterDB.profiles[profileName] = nil
        print("|cff00ff00[Arenamaster]|r Profile deleted: " .. profileName)
    end
end

function ConfigManager:GetProfiles()
    if not ArenamasterDB.profiles then
        return {}
    end

    local profiles = {}
    for name, _ in pairs(ArenamasterDB.profiles) do
        table.insert(profiles, name)
    end
    return profiles
end

-- ===========================
-- IMPORT/EXPORT
-- ===========================

function ConfigManager:ExportConfig()
    local exportStr = ""
    for key, value in pairs(ArenamasterDB.config) do
        if type(value) == "boolean" then
            value = value and "true" or "false"
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
            if value == "true" then
                value = true
            elseif value == "false" then
                value = false
            elseif tonumber(value) then
                value = tonumber(value)
            end
            self:Set(key, value)
            count = count + 1
        end
    end
    print("|cff00ff00[Arenamaster]|r Imported " .. count .. " settings")
end

-- ===========================
-- VALIDATION
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
            return false, "Value out of range"
        end
    elseif setting.type == "select" then
        if not tContains(setting.options, value) then
            return false, "Invalid option"
        end
    elseif setting.type == "checkbox" then
        if type(value) ~= "boolean" then
            return false, "Must be true or false"
        end
    end

    return true, "Valid"
end

-- Export
AM.ConfigManager = ConfigManager

return ConfigManager
