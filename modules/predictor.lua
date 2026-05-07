-- Arenamaster: Cooldown Predictor Module
-- Vorhersagen über gegnerische Cooldowns und wichtige Fähigkeiten

local AM = Arenamaster
local CooldownPredictor = {}

-- Bekannte Standard-Cooldowns
local ABILITY_COOLDOWNS = {
    -- Defensive
    ["Divine Shield"] = 60,
    ["Bubble"] = 60,
    ["Ice Block"] = 24,
    ["Power Word: Shield"] = 6,
    ["Unending Resolve"] = 180,
    ["Deterrence"] = 120,
    ["Anti-Magic Shell"] = 60,
    ["Evasion"] = 120,
    ["Shadow Dance"] = 60,

    -- Offensive
    ["Bloodlust"] = 120,
    ["Time Warp"] = 60,
    ["Heroism"] = 120,
    ["Avatar"] = 180,
    ["Power Infusion"] = 45,

    -- CC
    ["Stun"] = 40,
    ["Freeze"] = 20,
    ["Blind"] = 60,
    ["Polymorph"] = 60,
    ["Hex"] = 45,
    ["Fear"] = 30,
    ["Root"] = 8,

    -- Trinket (standard PvP trinket)
    ["Trinket"] = 120,
}

local cooldownHistory = {}
local predictions = {}

-- ===========================
-- INITIALIZATION
-- ===========================

function CooldownPredictor:Initialize()
    for i = 1, 5 do
        cooldownHistory["arena" .. i] = {}
        predictions["arena" .. i] = {}
    end
end

-- ===========================
-- COOLDOWN TRACKING
-- ===========================

function CooldownPredictor:RecordCooldownUsed(unit, abilityName, actualDuration)
    if not cooldownHistory[unit] then
        cooldownHistory[unit] = {}
    end

    cooldownHistory[unit][abilityName] = {
        lastUsed = GetTime(),
        baseDuration = actualDuration or ABILITY_COOLDOWNS[abilityName] or 60,
        estimatedReady = GetTime() + (actualDuration or ABILITY_COOLDOWNS[abilityName] or 60),
        usageCount = (cooldownHistory[unit][abilityName] and cooldownHistory[unit][abilityName].usageCount or 0) + 1,
    }

    self:UpdatePrediction(unit, abilityName)
end

function CooldownPredictor:UpdatePrediction(unit, abilityName)
    if not predictions[unit] then
        predictions[unit] = {}
    end

    local history = cooldownHistory[unit][abilityName]
    if not history then return end

    local remaining = history.estimatedReady - GetTime()

    predictions[unit][abilityName] = {
        name = abilityName,
        remaining = math.max(0, remaining),
        total = history.baseDuration,
        percent = math.max(0, (remaining / history.baseDuration) * 100),
        status = remaining <= 0 and "READY" or "COOLING",
        usageCount = history.usageCount,
        confidence = self:CalculateConfidence(unit, abilityName),
    }
end

-- ===========================
-- PREDICTION ACCURACY
-- ===========================

function CooldownPredictor:CalculateConfidence(unit, abilityName)
    local history = cooldownHistory[unit][abilityName]
    if not history then return 0 end

    -- Confidence based on usage count
    local usageConfidence = math.min(100, history.usageCount * 20)

    -- Confidence based on recency
    local timeSinceUsed = GetTime() - history.lastUsed
    local recencyConfidence = 100 - (timeSinceUsed / history.baseDuration * 50)
    recencyConfidence = math.max(30, recencyConfidence)

    return (usageConfidence + recencyConfidence) / 2
end

-- ===========================
-- SMART PREDICTIONS
-- ===========================

function CooldownPredictor:GetCooldownStatus(unit, abilityName)
    if not predictions[unit] or not predictions[unit][abilityName] then
        return nil
    end

    return predictions[unit][abilityName]
end

function CooldownPredictor:PredictReadyTime(unit, abilityName)
    local pred = self:GetCooldownStatus(unit, abilityName)
    if not pred then return nil end

    if pred.status == "READY" then
        return {
            ready = true,
            message = abilityName .. " is READY!",
            urgency = "HIGH"
        }
    else
        local roundedTime = math.ceil(pred.remaining)
        return {
            ready = false,
            remaining = pred.remaining,
            message = abilityName .. " ready in " .. roundedTime .. "s",
            urgency = roundedTime <= 5 and "HIGH" or "NORMAL",
            confidence = pred.confidence
        }
    end
end

-- ===========================
-- TACTICAL SUGGESTIONS
-- ===========================

function CooldownPredictor:GetNextDangerousAbility(unit)
    -- Returns the dangerous ability that will be ready soonest
    local dangerousAbilities = {
        "Divine Shield",
        "Avatar",
        "Bloodlust",
        "Time Warp",
        "Ice Block",
        "Stun",
        "Polymorph",
    }

    local soonestDanger = nil
    local soonestTime = math.huge

    for _, ability in ipairs(dangerousAbilities) do
        local pred = self:GetCooldownStatus(unit, ability)
        if pred and pred.remaining < soonestTime and pred.remaining > 0 then
            soonestTime = pred.remaining
            soonestDanger = {
                ability = ability,
                readyIn = pred.remaining,
                urgency = pred.remaining <= 5 and "URGENT" or "SOON"
            }
        end
    end

    return soonestDanger
end

function CooldownPredictor:GetDefensiveReadiness(unit)
    -- Returns status of enemy defensive cooldowns
    local defensives = {
        "Divine Shield",
        "Ice Block",
        "Power Word: Shield",
        "Unending Resolve",
        "Evasion",
    }

    local status = {
        readyCount = 0,
        coolingCount = 0,
        timeTillNextReady = math.huge,
        details = {}
    }

    for _, ability in ipairs(defensives) do
        local pred = self:GetCooldownStatus(unit, ability)
        if pred then
            table.insert(status.details, {
                ability = ability,
                status = pred.status,
                remaining = pred.remaining
            })

            if pred.status == "READY" then
                status.readyCount = status.readyCount + 1
            else
                status.coolingCount = status.coolingCount + 1
                if pred.remaining < status.timeTillNextReady then
                    status.timeTillNextReady = pred.remaining
                end
            end
        end
    end

    return status
end

function CooldownPredictor:GetOffensiveOpportunity(unit)
    -- When should we be worried about offensive cooldowns?
    local offensives = {
        "Avatar",
        "Bloodlust",
        "Time Warp",
        "Heroism",
        "Power Infusion",
    }

    local readySoon = {}

    for _, ability in ipairs(offensives) do
        local pred = self:GetCooldownStatus(unit, ability)
        if pred and pred.remaining <= 10 then
            table.insert(readySoon, {
                ability = ability,
                readyIn = pred.remaining,
                type = "OFFENSIVE"
            })
        end
    end

    return readySoon
end

-- ===========================
-- GROUP ANALYSIS
-- ===========================

function CooldownPredictor:GetTeamDefensiveStatus()
    -- Returns defensive CD status for all 5 opponents
    local teamStatus = {
        totalDefensivesReady = 0,
        totalDefensivesCooling = 0,
        vulnerableOpponents = {},
        wellDefendedOpponents = {},
    }

    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) then
            local defensiveStatus = self:GetDefensiveReadiness(unit)

            if defensiveStatus.readyCount >= 2 then
                table.insert(teamStatus.wellDefendedOpponents, {
                    unit = unit,
                    name = GetUnitName(unit),
                    readyDefensives = defensiveStatus.readyCount
                })
            else
                table.insert(teamStatus.vulnerableOpponents, {
                    unit = unit,
                    name = GetUnitName(unit),
                    readyDefensives = defensiveStatus.readyCount
                })
            end

            teamStatus.totalDefensivesReady = teamStatus.totalDefensivesReady + defensiveStatus.readyCount
            teamStatus.totalDefensivesCooling = teamStatus.totalDefensivesCooling + defensiveStatus.coolingCount
        end
    end

    return teamStatus
end

function CooldownPredictor:GetTeamOffensiveStatus()
    -- When is the enemy team most dangerous?
    local teamStatus = {
        highDamagePhaseIncoming = false,
        timeTillBurst = math.huge,
        activeOffensives = 0,
    }

    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) then
            local offensiveOpportunity = self:GetOffensiveOpportunity(unit)
            if #offensiveOpportunity > 0 then
                teamStatus.activeOffensives = teamStatus.activeOffensives + #offensiveOpportunity
                for _, opp in ipairs(offensiveOpportunity) do
                    teamStatus.timeTillBurst = math.min(teamStatus.timeTillBurst, opp.readyIn)
                end
            end
        end
    end

    teamStatus.highDamagePhaseIncoming = teamStatus.timeTillBurst <= 3

    return teamStatus
end

-- ===========================
-- NOTIFICATIONS
-- ===========================

function CooldownPredictor:GetCriticalAlerts()
    -- Returns high-priority alerts
    local alerts = {}

    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) then
            local danger = self:GetNextDangerousAbility(unit)
            if danger and danger.urgency == "URGENT" then
                table.insert(alerts, {
                    unit = unit,
                    name = GetUnitName(unit),
                    danger = danger.ability,
                    readyIn = danger.readyIn,
                    priority = "CRITICAL"
                })
            end
        end
    end

    -- Sort by urgency
    table.sort(alerts, function(a, b)
        return a.readyIn < b.readyIn
    end)

    return alerts
end

function CooldownPredictor:PrintCooldownAnalysis()
    print("|cff00ffff=== COOLDOWN ANALYSIS ===|r")

    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) then
            local name = GetUnitName(unit)
            print("|cff00ff00" .. name .. "|r")

            -- Dangerous ability coming up
            local danger = self:GetNextDangerousAbility(unit)
            if danger then
                print("  Next threat: " .. danger.ability .. " in " .. math.ceil(danger.readyIn) .. "s")
            end

            -- Defensive status
            local defStatus = self:GetDefensiveReadiness(unit)
            print("  Defensives: " .. defStatus.readyCount .. " ready, " .. defStatus.coolingCount .. " cooling")
        end
    end
end

-- Export
AM.CooldownPredictor = CooldownPredictor

return CooldownPredictor
