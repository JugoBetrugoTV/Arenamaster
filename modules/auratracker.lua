-- Arenamaster: Aura Tracker Module
-- Tracks enemy cooldowns, buffs, debuffs with visual countdown

local AM = Arenamaster
local AuraTracker = {}

-- Important abilities to track by class
local IMPORTANT_ABILITIES = {
    -- Defensive
    ["Divine Shield"] = {duration = 12, type = "defensive"},
    ["Ice Block"] = {duration = 10, type = "defensive"},
    ["Power Word: Shield"] = {duration = 15, type = "defensive"},
    ["Unending Resolve"] = {duration = 8, type = "defensive"},

    -- Offensive CDs
    ["Bloodlust"] = {duration = 40, type = "offensive"},
    ["Time Warp"] = {duration = 40, type = "offensive"},
    ["Heroism"] = {duration = 40, type = "offensive"},
    ["Avatar"] = {duration = 20, type = "offensive"},

    -- CC
    ["Stun"] = {duration = 4, type = "cc"},
    ["Freeze"] = {duration = 4, type = "cc"},
    ["Polymorph"] = {duration = 60, type = "cc"},
    ["Hex"] = {duration = 60, type = "cc"},
}

local trackedAbilities = {}
local config = {
    enabled = true,
    trackCooldowns = true,
    trackBuffs = true,
    trackDebuffs = true,
    showCountdown = true,
    soundAlerts = true,
}

-- ===========================
-- INITIALIZATION
-- ===========================

function AuraTracker:Initialize()
    self:LoadConfig()
    self:InitializeTracking()
end

function AuraTracker:LoadConfig()
    if ArenamasterDB.auraConfig then
        for key, value in pairs(ArenamasterDB.auraConfig) do
            config[key] = value
        end
    end
end

function AuraTracker:SaveConfig()
    ArenamasterDB.auraConfig = {}
    for key, value in pairs(config) do
        ArenamasterDB.auraConfig[key] = value
    end
end

function AuraTracker:InitializeTracking()
    for i = 1, 5 do
        trackedAbilities["arena" .. i] = {}
    end
end

-- ===========================
-- ABILITY TRACKING
-- ===========================

function AuraTracker:TrackAbility(unit, abilityName, duration)
    if not trackedAbilities[unit] then
        trackedAbilities[unit] = {}
    end

    local endTime = GetTime() + duration
    trackedAbilities[unit][abilityName] = {
        endTime = endTime,
        duration = duration,
        active = true,
        startTime = GetTime()
    }

    -- Play sound alert if enabled
    if config.soundAlerts then
        self:PlayAlert(abilityName, "start")
    end
end

function AuraTracker:GetAbilityStatus(unit, abilityName)
    if not trackedAbilities[unit] or not trackedAbilities[unit][abilityName] then
        return nil
    end

    local ability = trackedAbilities[unit][abilityName]
    local remaining = ability.endTime - GetTime()

    if remaining <= 0 then
        trackedAbilities[unit][abilityName] = nil
        return nil
    end

    return {
        name = abilityName,
        remaining = remaining,
        total = ability.duration,
        percent = (remaining / ability.duration) * 100,
        active = true
    }
end

function AuraTracker:GetAllAbilities(unit)
    if not trackedAbilities[unit] then
        return {}
    end

    local result = {}
    local currentTime = GetTime()

    for abilityName, data in pairs(trackedAbilities[unit]) do
        local remaining = data.endTime - currentTime

        if remaining > 0 then
            table.insert(result, {
                name = abilityName,
                remaining = remaining,
                total = data.duration,
                percent = (remaining / data.duration) * 100
            })
        else
            trackedAbilities[unit][abilityName] = nil
        end
    end

    -- Sort by time remaining (soonest first)
    table.sort(result, function(a, b)
        return a.remaining < b.remaining
    end)

    return result
end

function AuraTracker:UpdateAuraFromUnit(unit)
    if not UnitExists(unit) then return end

    -- Track buffs
    if config.trackBuffs then
        for i = 1, 40 do
            local name, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge = UnitAura(unit, i, "BUFF")
            if name then
                if duration and duration > 0 then
                    local remaining = expirationTime - GetTime()
                    if remaining > 0 then
                        self:TrackAbility(unit, name, remaining)
                    end
                end
            else
                break
            end
        end
    end

    -- Track debuffs
    if config.trackDebuffs then
        for i = 1, 40 do
            local name, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge = UnitAura(unit, i, "DEBUFF")
            if name then
                if duration and duration > 0 then
                    local remaining = expirationTime - GetTime()
                    if remaining > 0 then
                        self:TrackAbility(unit, name, remaining)
                    end
                end
            else
                break
            end
        end
    end
end

-- ===========================
-- COOLDOWN PREDICTION
-- ===========================

function AuraTracker:PredictCooldownReady(unit, abilityName, expectedDuration)
    local status = self:GetAbilityStatus(unit, abilityName)

    if not status then
        -- CD has expired
        return {
            ready = true,
            remaining = 0,
            message = abilityName .. " is READY!"
        }
    else
        -- CD still active
        local percent = (status.remaining / status.total) * 100
        return {
            ready = false,
            remaining = status.remaining,
            percent = percent,
            message = abilityName .. " ready in " .. math.ceil(status.remaining) .. "s"
        }
    end
end

function AuraTracker:GetHighestThreatAbility(unit)
    local abilities = self:GetAllAbilities(unit)

    -- Prioritize certain abilities
    for _, ability in ipairs(abilities) do
        if ability.name:find("Stun") or ability.name:find("Freeze") or ability.name:find("Silence") then
            return ability
        end
    end

    if abilities[1] then
        return abilities[1]
    end

    return nil
end

-- ===========================
-- SMART ALERTS
-- ===========================

function AuraTracker:CheckCooldownThresholds(unit)
    local alerts = {}

    for abilityName, data in pairs(trackedAbilities[unit] or {}) do
        local remaining = data.endTime - GetTime()

        if remaining > 0 and remaining <= 5 then
            table.insert(alerts, {
                ability = abilityName,
                remaining = remaining,
                priority = "high"
            })
        elseif remaining > 0 and remaining <= 10 then
            table.insert(alerts, {
                ability = abilityName,
                remaining = remaining,
                priority = "medium"
            })
        end
    end

    return alerts
end

function AuraTracker:GetFocusTargetRecommendation(unit)
    -- Returns which player to focus based on cooldown status
    local threat = self:GetHighestThreatAbility(unit)

    if threat then
        return {
            unit = unit,
            reason = threat.name .. " ready in " .. math.ceil(threat.remaining) .. "s",
            priority = "HIGH"
        }
    end

    return nil
end

-- ===========================
-- SOUND ALERTS
-- ===========================

function AuraTracker:PlayAlert(abilityName, eventType)
    -- Different sounds for different events
    if eventType == "start" then
        -- Play "ability started" sound
        PlaySoundFile("Sound\\Interface\\Alarm\\AlarmClockWarning3.wav", "Master")
    elseif eventType == "ready" then
        -- Play "cooldown ready" sound
        PlaySoundFile("Sound\\Interface\\UI\\BattlePetNotifications\\PetBattle_NewPetReady.wav", "Master")
    end
end

-- ===========================
-- STATISTICS
-- ===========================

function AuraTracker:GetAbilityStats(unit)
    local stats = {
        activeAbilities = 0,
        highThreatCount = 0,
        defensiveAbilitiesUp = 0,
        offensiveAbilitiesUp = 0,
    }

    for abilityName, data in pairs(trackedAbilities[unit] or {}) do
        if data.endTime - GetTime() > 0 then
            stats.activeAbilities = stats.activeAbilities + 1

            if abilityName:find("Shield") or abilityName:find("Block") or abilityName:find("Divine") then
                stats.defensiveAbilitiesUp = stats.defensiveAbilitiesUp + 1
            end

            if abilityName:find("Bloodlust") or abilityName:find("Avatar") then
                stats.offensiveAbilitiesUp = stats.offensiveAbilitiesUp + 1
            end

            if abilityName:find("Stun") or abilityName:find("Silence") then
                stats.highThreatCount = stats.highThreatCount + 1
            end
        end
    end

    return stats
end

-- ===========================
-- CONFIG MANAGEMENT
-- ===========================

function AuraTracker:UpdateConfig(key, value)
    config[key] = value
    self:SaveConfig()
end

function AuraTracker:GetConfig()
    return config
end

function AuraTracker:ClearTracking(unit)
    if unit then
        trackedAbilities[unit] = {}
    else
        for i = 1, 5 do
            trackedAbilities["arena" .. i] = {}
        end
    end
end

-- ===========================
-- PUBLIC ACCESS
-- ===========================

function AuraTracker:PrintAbilities(unit)
    print("|cff00ffff[Arenamaster]|r Tracked abilities for " .. unit)
    local abilities = self:GetAllAbilities(unit)

    if #abilities == 0 then
        print("None tracked")
        return
    end

    for _, ability in ipairs(abilities) do
        print(string.format("  %s: %.1fs (%.0f%%)", ability.name, ability.remaining, ability.percent))
    end
end

-- Export
AM.AuraTracker = AuraTracker

return AuraTracker
