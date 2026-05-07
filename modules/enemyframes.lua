-- Arenamaster: Enemy Frames Module
-- Displays opponent health, mana, cast bars, and status information

local AM = Arenamaster
local EnemyFrames = {}

-- Configuration
local config = {
    enabled = true,
    layout = "vertical", -- vertical, horizontal, grid
    frameWidth = 220,
    frameHeight = 85,
    spacing = 8,
    showNames = true,
    showHealthText = true,
    showManaBar = true,
    showCastBar = true,
    showTrinket = true,
    showBuffs = true,
    showDebuffs = true,
    showClassIcon = true,
    opacity = 0.95,
    frameX = 100,
    frameY = 200,
}

local frames = {}
local unitUpdates = {}

-- ===========================
-- INITIALIZATION
-- ===========================

function EnemyFrames:Initialize()
    self:LoadConfig()
    self:CreateFrames()
    self:RegisterEvents()
end

function EnemyFrames:LoadConfig()
    if ArenamasterDB.frameConfig then
        for key, value in pairs(ArenamasterDB.frameConfig) do
            config[key] = value
        end
    end
end

function EnemyFrames:SaveConfig()
    ArenamasterDB.frameConfig = {}
    for key, value in pairs(config) do
        ArenamasterDB.frameConfig[key] = value
    end
end

-- ===========================
-- CREATE FRAMES
-- ===========================

function EnemyFrames:CreateFrames()
    for i = 1, 5 do
        frames[i] = self:CreateOpponentFrame(i)
    end
    self:PositionFrames()
end

function EnemyFrames:CreateOpponentFrame(index)
    local frame = CreateFrame("Frame", "ArenamasterOpponentFrame" .. index, UIParent)
    frame:SetSize(config.frameWidth, config.frameHeight)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    frame:SetBackdropColor(0.05, 0.05, 0.05, config.opacity)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    frame.opponentIndex = index
    frame.unit = "arena" .. index

    -- ===== HEADER (Name + Class) =====
    local header = frame:CreateFontString(nil, "OVERLAY")
    header:SetFontObject("GameFontNormal")
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    header:SetWidth(config.frameWidth - 10)
    header:SetHeight(15)
    frame.header = header

    -- ===== HEALTH BAR =====
    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetSize(config.frameWidth - 10, 22)
    healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -22)
    healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    healthBar:SetStatusBarColor(0.2, 1, 0.2)
    healthBar:SetMinMaxValues(0, 100)
    healthBar:SetValue(100)

    -- Health text
    local healthText = healthBar:CreateFontString(nil, "OVERLAY")
    healthText:SetFontObject("GameFontSmall")
    healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    healthText:SetText("100%")
    frame.healthText = healthText

    -- Health border
    healthBar:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 1
    })
    healthBar:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    healthBar:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

    frame.healthBar = healthBar

    -- ===== MANA BAR =====
    local manaBar = CreateFrame("StatusBar", nil, frame)
    manaBar:SetSize(config.frameWidth - 10, 10)
    manaBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -2)
    manaBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    manaBar:SetStatusBarColor(0.2, 0.5, 1)
    manaBar:SetMinMaxValues(0, 100)
    manaBar:SetValue(100)
    manaBar:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 1
    })
    manaBar:SetBackdropColor(0.05, 0.05, 0.05, 0.5)
    frame.manaBar = manaBar

    -- ===== CAST BAR =====
    local castBar = CreateFrame("StatusBar", nil, frame)
    castBar:SetSize(config.frameWidth - 10, 8)
    castBar:SetPoint("TOPLEFT", manaBar, "BOTTOMLEFT", 0, -2)
    castBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    castBar:SetStatusBarColor(1, 0.8, 0)
    castBar:SetMinMaxValues(0, 1)
    castBar:SetValue(0)
    castBar:Hide()
    frame.castBar = castBar

    -- Cast text
    local castText = castBar:CreateFontString(nil, "OVERLAY")
    castText:SetFontObject("GameFontSmall")
    castText:SetPoint("LEFT", castBar, "LEFT", 2, 0)
    castText:SetText("Cast")
    frame.castText = castText

    -- ===== TRINKET ICON =====
    local trinketIcon = CreateFrame("Button", nil, frame)
    trinketIcon:SetSize(20, 20)
    trinketIcon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    trinketIcon:SetBackdrop({
        bgFile = "Interface/Buttons/WHITE8X8",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 1
    })
    trinketIcon:SetBackdropColor(0.3, 0.3, 0.3, 0.8)

    local trinketText = trinketIcon:CreateFontString(nil, "OVERLAY")
    trinketText:SetFontObject("GameFontSmall")
    trinketText:SetPoint("CENTER", trinketIcon, "CENTER", 0, 0)
    trinketText:SetText("✓")
    trinketText:SetTextColor(0, 1, 0)
    trinketIcon.text = trinketText

    frame.trinketIcon = trinketIcon
    frame.trinketCD = 0

    -- ===== BUFF/DEBUFF SECTION =====
    local buffFrame = CreateFrame("Frame", nil, frame)
    buffFrame:SetSize(config.frameWidth - 10, 12)
    buffFrame:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT", 0, -2)
    frame.buffFrame = buffFrame
    frame.buffs = {}

    -- ===== CLICK HANDLERS =====
    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            TargetUnit(self.unit)
        elseif button == "RightButton" then
            -- Right click menu
            EnemyFrames:ShowOpponentMenu(self.opponentIndex)
        end
    end)

    -- ===== REGISTER EVENTS =====
    frame:RegisterUnitEvent("UNIT_HEALTH", frame.unit)
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", frame.unit)
    frame:RegisterUnitEvent("UNIT_POWER", frame.unit)
    frame:RegisterUnitEvent("UNIT_MAXPOWER", frame.unit)
    frame:RegisterUnitEvent("UNIT_SPELLCAST_START", frame.unit)
    frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", frame.unit)
    frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", frame.unit)
    frame:RegisterUnitEvent("UNIT_AURA", frame.unit)
    frame:RegisterUnitEvent("UNIT_NAME_UPDATE", frame.unit)
    frame:RegisterUnitEvent("UNIT_CLASS", frame.unit)

    frame:SetScript("OnEvent", function(self, event, ...)
        EnemyFrames:UpdateFrame(self, event)
    end)

    return frame
end

-- ===========================
-- UPDATE FUNCTIONS
-- ===========================

function EnemyFrames:UpdateFrame(frame, event)
    local unit = frame.unit

    -- Only update if unit exists in arena
    if not UnitExists(unit) then
        frame:Hide()
        return
    end

    frame:Show()

    -- Update header (name + class)
    local name = GetUnitName(unit)
    local _, class = UnitClass(unit)
    if name then
        local classColor = self:GetClassColor(class)
        frame.header:SetTextColor(classColor.r, classColor.g, classColor.b)
        frame.header:SetText(name)

        -- Update frame border to class color
        frame:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 1)
    end

    -- Update health bar
    self:UpdateHealthBar(frame)

    -- Update mana bar
    if config.showManaBar then
        self:UpdateManaBar(frame)
        frame.manaBar:Show()
    else
        frame.manaBar:Hide()
    end

    -- Update cast bar
    if config.showCastBar then
        self:UpdateCastBar(frame)
    end

    -- Update trinket
    if config.showTrinket then
        self:UpdateTrinket(frame)
    end

    -- Update buffs/debuffs
    if config.showBuffs or config.showDebuffs then
        self:UpdateAuras(frame)
    end
end

function EnemyFrames:UpdateHealthBar(frame)
    local unit = frame.unit
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)

    if maxHealth > 0 then
        local percent = (health / maxHealth) * 100
        frame.healthBar:SetMinMaxValues(0, maxHealth)
        frame.healthBar:SetValue(health)

        -- Health bar color based on percentage
        if percent > 50 then
            frame.healthBar:SetStatusBarColor(0.2, 1, 0.2)
        elseif percent > 25 then
            frame.healthBar:SetStatusBarColor(1, 1, 0)
        else
            frame.healthBar:SetStatusBarColor(1, 0.2, 0.2)
        end

        -- Update health text
        if config.showHealthText then
            frame.healthText:SetText(string.format("%.0f%%", percent))
        end
    end
end

function EnemyFrames:UpdateManaBar(frame)
    local unit = frame.unit
    local power = UnitPower(unit)
    local maxPower = UnitPowerMax(unit)

    if maxPower > 0 then
        frame.manaBar:SetMinMaxValues(0, maxPower)
        frame.manaBar:SetValue(power)
    end
end

function EnemyFrames:UpdateCastBar(frame)
    local unit = frame.unit
    local spellName, spellRank, spellDisplayName, spellStartTime, spellEndTime, isTradeSkill, castID, notInterruptible

    -- Get cast info
    spellName, spellRank, spellDisplayName, spellStartTime, spellEndTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)

    if spellName then
        local duration = spellEndTime / 1000 - GetTime()
        if duration > 0 then
            frame.castBar:SetMinMaxValues(0, (spellEndTime - spellStartTime) / 1000)
            frame.castBar:SetValue(GetTime() - spellStartTime / 1000)
            frame.castText:SetText(string.format("%s (%.1f)", spellDisplayName, duration))

            -- Color: red if not interruptible, yellow if interruptible
            if notInterruptible then
                frame.castBar:SetStatusBarColor(1, 0.2, 0.2)
            else
                frame.castBar:SetStatusBarColor(1, 0.8, 0)
            end

            frame.castBar:Show()
            return
        end
    end

    -- Check for channeling
    spellName, spellRank, spellDisplayName, spellStartTime, spellEndTime = UnitChannelInfo(unit)
    if spellName then
        local duration = spellEndTime / 1000 - GetTime()
        if duration > 0 then
            frame.castBar:SetMinMaxValues(0, (spellEndTime - spellStartTime) / 1000)
            frame.castBar:SetValue(GetTime() - spellStartTime / 1000)
            frame.castText:SetText(string.format("%s (%.1f) [CHANNEL]", spellDisplayName, duration))
            frame.castBar:SetStatusBarColor(0.7, 0.2, 1)
            frame.castBar:Show()
            return
        end
    end

    frame.castBar:Hide()
end

function EnemyFrames:UpdateTrinket(frame)
    -- Basic trinket tracking (simplified version)
    frame.trinketCD = frame.trinketCD - 1

    if frame.trinketCD <= 0 then
        frame.trinketIcon.text:SetText("✓")
        frame.trinketIcon.text:SetTextColor(0, 1, 0)
    else
        frame.trinketIcon.text:SetText(tostring(frame.trinketCD))
        frame.trinketIcon.text:SetTextColor(1, 0.5, 0)
    end
end

function EnemyFrames:UpdateAuras(frame)
    -- Clear old buffs
    for i, buff in ipairs(frame.buffs) do
        buff:Hide()
    end

    local buffIndex = 1
    local unit = frame.unit

    -- Show important buffs
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3 = UnitAura(unit, i, "BUFF")

        if name and config.showBuffs then
            local buffFrame = self:GetOrCreateBuffIcon(frame, buffIndex)
            buffFrame:SetPoint("TOPLEFT", frame.buffFrame, "TOPLEFT", (buffIndex - 1) * 14, 0)
            buffFrame.text:SetText("🔵")
            buffFrame:Show()
            buffIndex = buffIndex + 1

            if buffIndex > 15 then break end
        end
    end

    -- Show debuffs (CC etc)
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3 = UnitAura(unit, i, "DEBUFF")

        if name and config.showDebuffs then
            local color = "🔴"
            if debuffType == "Stun" then
                color = "🔴"
            elseif debuffType == "Root" then
                color = "🟢"
            elseif debuffType == "Silence" then
                color = "🔵"
            elseif debuffType == "Disorient" or debuffType == "Fear" then
                color = "🟣"
            end

            local buffFrame = self:GetOrCreateBuffIcon(frame, buffIndex)
            buffFrame:SetPoint("TOPLEFT", frame.buffFrame, "TOPLEFT", (buffIndex - 1) * 14, 0)
            buffFrame.text:SetText(color)

            -- Show duration if important
            if duration and duration > 0 then
                local remaining = expirationTime - GetTime()
                if remaining > 0 then
                    buffFrame.text:SetText(string.format("%.0f", remaining))
                end
            end

            buffFrame:Show()
            buffIndex = buffIndex + 1

            if buffIndex > 15 then break end
        end
    end
end

function EnemyFrames:GetOrCreateBuffIcon(frame, index)
    if not frame.buffs[index] then
        local icon = CreateFrame("Frame", nil, frame.buffFrame)
        icon:SetSize(12, 12)
        icon:SetBackdrop({
            bgFile = "Interface/Buttons/WHITE8X8",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 8,
            edgeSize = 1
        })
        icon:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

        local text = icon:CreateFontString(nil, "OVERLAY")
        text:SetFontObject("GameFontSmall")
        text:SetPoint("CENTER", icon, "CENTER", 0, 0)
        icon.text = text

        frame.buffs[index] = icon
    end

    return frame.buffs[index]
end

-- ===========================
-- POSITIONING
-- ===========================

function EnemyFrames:PositionFrames()
    if config.layout == "vertical" then
        for i, frame in ipairs(frames) do
            frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", config.frameX, -(config.frameY + (i - 1) * (config.frameHeight + config.spacing)))
        end
    elseif config.layout == "horizontal" then
        for i, frame in ipairs(frames) do
            frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", config.frameX + (i - 1) * (config.frameWidth + config.spacing), -config.frameY)
        end
    elseif config.layout == "grid" then
        for i, frame in ipairs(frames) do
            local row = math.floor((i - 1) / 3)
            local col = (i - 1) % 3
            frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", config.frameX + col * (config.frameWidth + config.spacing), -(config.frameY + row * (config.frameHeight + config.spacing)))
        end
    end
end

-- ===========================
-- UTILITY FUNCTIONS
-- ===========================

function EnemyFrames:GetClassColor(class)
    local colors = {
        DRUID = {r = 1.0, g = 0.49, b = 0.04},
        HUNTER = {r = 0.67, g = 0.83, b = 0.45},
        MAGE = {r = 0.41, g = 0.80, b = 0.94},
        PALADIN = {r = 0.96, g = 0.55, b = 0.73},
        PRIEST = {r = 1.0, g = 1.0, b = 1.0},
        ROGUE = {r = 1.0, g = 0.96, b = 0.41},
        SHAMAN = {r = 0.0, g = 0.44, b = 0.87},
        WARLOCK = {r = 0.58, g = 0.51, b = 0.79},
        WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
        MONK = {r = 0.0, g = 1.0, b = 0.59},
        DEMON_HUNTER = {r = 0.64, g = 0.19, b = 0.79},
        DEATH_KNIGHT = {r = 0.77, g = 0.12, b = 0.23},
    }
    return colors[class] or {r = 0.5, g = 0.5, b = 0.5}
end

function EnemyFrames:ShowOpponentMenu(index)
    -- Placeholder for context menu
    print("Right-click menu for opponent " .. index .. " (coming soon)")
end

-- ===========================
-- PUBLIC FUNCTIONS
-- ===========================

function EnemyFrames:RegisterEvents()
    -- Arena events
    if not Arenamaster.enemyFrameEventFrame then
        Arenamaster.enemyFrameEventFrame = CreateFrame("Frame")
        Arenamaster.enemyFrameEventFrame:RegisterEvent("ARENA_MATCH_BEGIN")
        Arenamaster.enemyFrameEventFrame:RegisterEvent("ARENA_MATCH_END")
        Arenamaster.enemyFrameEventFrame:SetScript("OnEvent", function(self, event)
            if event == "ARENA_MATCH_BEGIN" then
                for i, frame in ipairs(frames) do
                    frame:Show()
                end
            elseif event == "ARENA_MATCH_END" then
                for i, frame in ipairs(frames) do
                    frame:Hide()
                end
            end
        end)
    end
end

function EnemyFrames:UpdateConfig(key, value)
    config[key] = value
    self:SaveConfig()

    if key == "layout" or key == "frameX" or key == "frameY" or key == "frameWidth" or key == "frameHeight" or key == "spacing" then
        self:PositionFrames()
    elseif key == "opacity" then
        for i, frame in ipairs(frames) do
            frame:SetBackdropColor(0.05, 0.05, 0.05, value)
        end
    end
end

function EnemyFrames:GetConfig()
    return config
end

function EnemyFrames:ToggleFrames()
    config.enabled = not config.enabled
    self:SaveConfig()
    for i, frame in ipairs(frames) do
        if config.enabled then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

-- Export
AM.EnemyFrames = EnemyFrames

return EnemyFrames
