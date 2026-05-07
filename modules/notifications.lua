-- Arenamaster: Smart Notifications Module
-- Intelligente Benachrichtigungen und Callouts

local AM = Arenamaster
local SmartNotifications = {}

local config = {
    enabled = true,
    soundAlerts = true,
    chatAlerts = true,
    screenAlerts = true,
    voiceCallouts = false,
}

local notificationQueue = {}
local lastNotificationTime = 0
local NOTIFICATION_COOLDOWN = 2  -- Minimum 2 seconds between notifications

-- ===========================
-- NOTIFICATION TYPES
-- ===========================

local NOTIFICATION_TYPES = {
    CRITICAL = {priority = 1, color = "ff0000", sound = "Alarm", duration = 5},
    HIGH = {priority = 2, color = "ff8800", sound = "Warning", duration = 4},
    MEDIUM = {priority = 3, color = "ffff00", sound = "Info", duration = 3},
    LOW = {priority = 4, color = "00ff00", sound = nil, duration = 2},
}

-- ===========================
-- NOTIFICATIONS
-- ===========================

function SmartNotifications:Initialize()
    self:LoadConfig()
end

function SmartNotifications:LoadConfig()
    if ArenamasterDB.notificationConfig then
        for key, value in pairs(ArenamasterDB.notificationConfig) do
            config[key] = value
        end
    end
end

function SmartNotifications:SaveConfig()
    ArenamasterDB.notificationConfig = {}
    for key, value in pairs(config) do
        ArenamasterDB.notificationConfig[key] = value
    end
end

-- ===========================
-- SEND NOTIFICATIONS
-- ===========================

function SmartNotifications:Notify(title, message, notificationType)
    notificationType = notificationType or "MEDIUM"
    local typeInfo = NOTIFICATION_TYPES[notificationType]

    if not typeInfo then
        notificationType = "MEDIUM"
        typeInfo = NOTIFICATION_TYPES["MEDIUM"]
    end

    -- Respect cooldown
    if GetTime() - lastNotificationTime < NOTIFICATION_COOLDOWN and notificationType ~= "CRITICAL" then
        return
    end

    lastNotificationTime = GetTime()

    -- Chat notification
    if config.chatAlerts then
        self:PrintToChat(title, message, typeInfo.color)
    end

    -- Sound notification
    if config.soundAlerts and typeInfo.sound then
        self:PlaySound(typeInfo.sound)
    end

    -- Screen notification (floating text)
    if config.screenAlerts then
        self:CreateScreenAlert(title, message, typeInfo.color, typeInfo.duration)
    end

    -- Voice callout
    if config.voiceCallouts then
        self:PlayVoiceCallout(title)
    end
end

function SmartNotifications:PrintToChat(title, message, hexColor)
    local color = "|cff" .. hexColor
    print(string.format("%s[Arenamaster]|r %s: %s", color, title, message))
end

function SmartNotifications:PlaySound(soundType)
    local soundMap = {
        Alarm = "Sound\\Interface\\Alarm\\AlarmClockWarning3.wav",
        Warning = "Sound\\Interface\\UI\\BattlePetNotifications\\PetBattle_NewPetReady.wav",
        Info = "Sound\\Interface\\UI\\LevelUpSoundS.ogg",
        Success = "Sound\\Interface\\UI\\TalentScreenOpen.ogg",
    }

    if soundMap[soundType] then
        PlaySoundFile(soundMap[soundType], "Master")
    end
end

function SmartNotifications:CreateScreenAlert(title, message, hexColor, duration)
    -- Create floating text effect on screen
    local color = tonumber("ff" .. hexColor:sub(3), 16)
    CombatTextSetEventColorStyle("COMBAT_TEXT_SCROLL_CRITICAL", 1, 1, 1)

    -- Display as damage number (creative approach)
    FloatingCombatTextFrame_AddMessage(
        FloatingCombatTextFrame,
        title .. ": " .. message,
        COMBATLOG_DEFAULT_CRITICAL_COLOR or {r = 1, g = 0, b = 0},
        duration
    )
end

function SmartNotifications:PlayVoiceCallout(text)
    -- Text-to-speech simulation (simplified)
    -- In a real implementation, would use system TTS or pre-recorded audio
    print("|cff00ffff[Voice]|r " .. text)
end

-- ===========================
-- SMART ALERTS
-- ===========================

function SmartNotifications:OnMatchStart()
    self:Notify("MATCH START", "Arena match begun!", "MEDIUM")
end

function SmartNotifications:OnMatchEnd(result)
    if result == 1 then
        self:Notify("VICTORY!", "You won!", "HIGH")
    else
        self:Notify("DEFEAT", "Match lost", "MEDIUM")
    end
end

function SmartNotifications:OnFocusTargetChanged(opponentName, threatLevel)
    self:Notify("FOCUS", "Target: " .. opponentName, "HIGH")
end

function SmartNotifications:OnDangerousCooldownReady(abilityName, opponentName)
    self:Notify("⚠️ COOLDOWN", opponentName .. ": " .. abilityName .. " READY!", "CRITICAL")
end

function SmartNotifications:OnTeamwideAlert(alertType, details)
    if alertType == "INCOMING_BURST" then
        self:Notify("🔥 BURST INCOMING", details.count .. " offensive CDs active!", "CRITICAL")
    elseif alertType == "KILL_OPPORTUNITY" then
        self:Notify("💀 KILL OPPORTUNITY", details.target .. " vulnerable!", "HIGH")
    elseif alertType == "DEFENSIVE_WINDOW" then
        self:Notify("🛡️ SAFE ZONE", "Enemy defensives down!", "MEDIUM")
    end
end

function SmartNotifications:OnPlayerCC()
    self:Notify("⚡ CC RECEIVED", "You are crowd controlled!", "CRITICAL")
end

function SmartNotifications:OnKill(targetName)
    self:Notify("💀 KILL", "Defeated " .. targetName, "HIGH")
end

function SmartNotifications:OnDeath(killedBy)
    self:Notify("💥 DEATH", "Killed by " .. killedBy, "HIGH")
end

function SmartNotifications:OnStreak(count, isWinStreak)
    if count % 5 == 0 then
        if isWinStreak then
            self:Notify("🔥 STREAK!", count .. " wins in a row!", "HIGH")
        else
            self:Notify("Losing Streak", count .. " losses", "MEDIUM")
        end
    end
end

-- ===========================
-- TACTICAL CALLOUTS
-- ===========================

function SmartNotifications:CalloutTacticalSituation()
    if not AM.ThreatDetector then return end

    local focus = AM.ThreatDetector:GetFocusRecommendation()
    if focus then
        local threatText = "Focus: " .. focus.name
        self:PrintToChat("TACTICAL", threatText, "ff8800")
    end

    if AM.CooldownPredictor then
        local alerts = AM.CooldownPredictor:GetCriticalAlerts()
        if #alerts > 0 then
            for i = 1, math.min(2, #alerts) do
                self:PrintToChat("ALERT", alerts[i].danger .. " ready in " .. math.ceil(alerts[i].readyIn) .. "s!", "ff0000")
            end
        end
    end
end

function SmartNotifications:CalloutCountdownCooldown(abilityName, secondsRemaining)
    if secondsRemaining == 5 or secondsRemaining == 3 or secondsRemaining == 1 then
        self:Notify("COUNTDOWN", abilityName .. " ready in " .. secondsRemaining .. "s!", "MEDIUM")
    end
end

-- ===========================
-- CONFIGURATION
-- ===========================

function SmartNotifications:UpdateConfig(key, value)
    config[key] = value
    self:SaveConfig()
end

function SmartNotifications:GetConfig()
    return config
end

function SmartNotifications:ToggleNotifications()
    config.enabled = not config.enabled
    self:SaveConfig()
    return config.enabled
end

function SmartNotifications:ToggleSounds()
    config.soundAlerts = not config.soundAlerts
    self:SaveConfig()
    return config.soundAlerts
end

function SmartNotifications:ToggleVoiceCallouts()
    config.voiceCallouts = not config.voiceCallouts
    self:SaveConfig()
    return config.voiceCallouts
end

-- ===========================
-- DEBUG
-- ===========================

function SmartNotifications:TestNotifications()
    print("|cff00ffff=== Testing Notifications ===|r")
    self:Notify("TEST", "Low priority", "LOW")
    self:Notify("TEST", "Medium priority", "MEDIUM")
    self:Notify("TEST", "High priority", "HIGH")
    self:Notify("TEST", "Critical priority", "CRITICAL")
end

-- Export
AM.SmartNotifications = SmartNotifications

return SmartNotifications
