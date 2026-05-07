-- Arenamaster: Smart Visual Callouts Module
-- Zeigt wichtige Infos visuel auf dem Bildschirm

local AM = Arenamaster
local SmartCallouts = {}

local calloutFrames = {}
local activeCallouts = {}

local config = {
    enabled = true,
    showCallouts = true,
    calloutSize = 40,
    calloutX = 960,
    calloutY = 300,
    opacity = 0.9,
    duration = 3,  -- seconds
}

-- ===========================
-- INITIALIZATION
-- ===========================

function SmartCallouts:Initialize()
    self:LoadConfig()
    self:CreateCalloutFrame()
end

function SmartCallouts:LoadConfig()
    if ArenamasterDB.calloutConfig then
        for key, value in pairs(ArenamasterDB.calloutConfig) do
            config[key] = value
        end
    end
end

function SmartCallouts:SaveConfig()
    ArenamasterDB.calloutConfig = {}
    for key, value in pairs(config) do
        ArenamasterDB.calloutConfig[key] = value
    end
end

-- ===========================
-- CREATE CALLOUT FRAME
-- ===========================

function SmartCallouts:CreateCalloutFrame()
    local frame = CreateFrame("Frame", "ArenamasterCallouts", UIParent)
    frame:SetSize(600, 400)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    frame:EnableMouse(false)
    frame:SetBackdrop(nil)

    calloutFrames.main = frame
end

-- ===========================
-- ADD CALLOUT
-- ===========================

function SmartCallouts:AddCallout(text, icon, priority, duration)
    priority = priority or "MEDIUM"
    duration = duration or config.duration

    local callout = {
        text = text,
        icon = icon,
        priority = priority,
        duration = duration,
        startTime = GetTime(),
        endTime = GetTime() + duration,
    }

    table.insert(activeCallouts, callout)

    -- Sort by priority
    table.sort(activeCallouts, function(a, b)
        local priorityOrder = {CRITICAL = 1, HIGH = 2, MEDIUM = 3, LOW = 4}
        return (priorityOrder[a.priority] or 99) < (priorityOrder[b.priority] or 99)
    end)

    self:UpdateCallouts()
end

function SmartCallouts:UpdateCallouts()
    local currentTime = GetTime()
    local frame = calloutFrames.main

    -- Remove expired callouts
    for i = #activeCallouts, 1, -1 do
        if currentTime > activeCallouts[i].endTime then
            table.remove(activeCallouts, i)
        end
    end

    -- Display active callouts
    local yOffset = 0
    for i, callout in ipairs(activeCallouts) do
        if i <= 3 then  -- Show max 3 callouts
            self:DisplayCallout(frame, callout, yOffset)
            yOffset = yOffset + 60
        end
    end

    if #activeCallouts > 0 then
        frame:Show()
    else
        frame:Hide()
    end
end

function SmartCallouts:DisplayCallout(frame, callout, yOffset)
    local calloutBox = CreateFrame("Frame", nil, frame)
    calloutBox:SetSize(580, 50)
    calloutBox:SetPoint("TOP", frame, "TOP", 0, -yOffset)

    -- Color by priority
    local colors = {
        CRITICAL = {r = 1, g = 0, b = 0},
        HIGH = {r = 1, g = 0.5, b = 0},
        MEDIUM = {r = 1, g = 1, b = 0},
        LOW = {r = 0, g = 1, b = 0},
    }
    local color = colors[callout.priority] or colors.MEDIUM

    -- Background
    calloutBox:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 2,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    })
    calloutBox:SetBackdropColor(color.r * 0.3, color.g * 0.3, color.b * 0.3, config.opacity)
    calloutBox:SetBackdropBorderColor(color.r, color.g, color.b, 1)

    -- Icon (left side)
    if callout.icon then
        local icon = calloutBox:CreateTexture(nil, "ARTWORK")
        icon:SetSize(40, 40)
        icon:SetPoint("LEFT", calloutBox, "LEFT", 5, 0)
        icon:SetTexture(callout.icon)
    end

    -- Text
    local text = calloutBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", calloutBox, "LEFT", 50, 0)
    text:SetText(callout.text)
    text:SetTextColor(color.r, color.g, color.b)

    -- Progress bar
    local progress = CreateFrame("StatusBar", nil, calloutBox)
    progress:SetSize(575, 3)
    progress:SetPoint("BOTTOM", calloutBox, "BOTTOM", 0, 0)
    progress:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    progress:SetStatusBarColor(color.r, color.g, color.b)
    progress:SetMinMaxValues(0, callout.duration)

    -- Animate progress
    local elapsed = GetTime() - callout.startTime
    progress:SetValue(callout.duration - elapsed)
end

-- ===========================
-- CALLOUT TRIGGERS
-- ===========================

function SmartCallouts:CalloutFocusChange(opponentName)
    self:AddCallout("🎯 FOCUS: " .. opponentName, nil, "HIGH", 2)
end

function SmartCallouts:CalloutCriticalCooldown(abilityName, opponentName, secondsRemaining)
    if secondsRemaining == 5 or secondsRemaining == 3 or secondsRemaining == 1 then
        local text = "⚠️ " .. opponentName .. ": " .. abilityName .. " in " .. secondsRemaining .. "s"
        self:AddCallout(text, nil, "CRITICAL", 2)
    end
end

function SmartCallouts:CalloutBurstPhase()
    self:AddCallout("🔥 INCOMING BURST - DEFENSIVE NOW!", nil, "CRITICAL", 3)
end

function SmartCallouts:CalloutDefensiveWindow()
    self:AddCallout("🛡️ DEFENSIVE WINDOW - COUNTER NOW!", nil, "HIGH", 3)
end

function SmartCallouts:CalloutKillOpportunity(targetName)
    self:AddCallout("💀 KILL OPPORTUNITY: " .. targetName, nil, "HIGH", 2)
end

function SmartCallouts:CalloutYouAreCCd()
    self:AddCallout("⚡ YOU ARE CC'D!", nil, "CRITICAL", 2)
end

function SmartCallouts:CalloutTeammateCC(teammate)
    self:AddCallout("⚡ " .. teammate .. " CC'D", nil, "HIGH", 2)
end

function SmartCallouts:CalloutPlayerKilled()
    self:AddCallout("💥 YOU DIED", nil, "CRITICAL", 3)
end

function SmartCallouts:CalloutEnemyKilled(enemyName)
    self:AddCallout("💀 " .. enemyName .. " KILLED", nil, "HIGH", 2)
end

function SmartCallouts:CalloutWin()
    self:AddCallout("🏆 VICTORY!", nil, "HIGH", 5)
end

function SmartCallouts:CalloutLoss()
    self:AddCallout("💔 DEFEAT", nil, "MEDIUM", 5)
end

function SmartCallouts:CalloutStreak(count)
    self:AddCallout("🔥 " .. count .. " WIN STREAK!", nil, "MEDIUM", 3)
end

-- ===========================
-- CONFIGURATION
-- ===========================

function SmartCallouts:UpdateConfig(key, value)
    config[key] = value
    self:SaveConfig()
end

function SmartCallouts:GetConfig()
    return config
end

function SmartCallouts:ToggleCallouts()
    config.showCallouts = not config.showCallouts
    self:SaveConfig()
    return config.showCallouts
end

function SmartCallouts:ClearAllCallouts()
    activeCallouts = {}
    calloutFrames.main:Hide()
end

-- ===========================
-- DEBUG
-- ===========================

function SmartCallouts:TestCallouts()
    print("|cff00ffff=== Testing Callouts ===|r")
    self:AddCallout("🎯 TEST: Focus Change", nil, "HIGH", 3)
    self:AddCallout("🔥 TEST: Burst Incoming", nil, "CRITICAL", 3)
    self:AddCallout("🛡️ TEST: Defensive Window", nil, "MEDIUM", 3)
end

-- Export
AM.SmartCallouts = SmartCallouts

return SmartCallouts
