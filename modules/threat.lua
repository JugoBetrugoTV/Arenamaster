-- Arenamaster: Threat Detection Module
-- Intelligente Analyse wem man focusen sollte

local AM = Arenamaster
local ThreatDetector = {}

-- Threat-Scoring Weights
local THREAT_WEIGHTS = {
    health = 0.2,           -- Je mehr HP, desto höher die Threat
    defensiveCooldowns = 0.15, -- Defensive CDs aktiv = weniger Threat
    offensiveCooldowns = 0.25, -- Offensive CDs aktiv = höhere Threat
    crowdControl = 0.2,     -- CC-Immunity = weniger Threat
    damageClass = 0.2,      -- Damage Klassen höhere Threat
}

local threatLevels = {}
local focusRecommendation = nil

-- ===========================
-- INITIALIZATION
-- ===========================

function ThreatDetector:Initialize()
    for i = 1, 5 do
        threatLevels["arena" .. i] = {
            score = 0,
            reasons = {},
            lastUpdate = 0,
        }
    end
end

-- ===========================
-- THREAT CALCULATION
-- ===========================

function ThreatDetector:CalculateThreat(unit)
    if not UnitExists(unit) then return 0 end

    local score = 0
    local reasons = {}

    -- 1. Health-basierte Threat (höher HP = potentiell gefährlicher)
    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local healthPercent = (health / maxHealth) * 100

    if healthPercent > 75 then
        score = score + 3 * THREAT_WEIGHTS.health
        table.insert(reasons, "High HP (" .. math.floor(healthPercent) .. "%)")
    elseif healthPercent > 50 then
        score = score + 2 * THREAT_WEIGHTS.health
        table.insert(reasons, "Medium HP (" .. math.floor(healthPercent) .. "%)")
    else
        score = score + 1 * THREAT_WEIGHTS.health
        table.insert(reasons, "Low HP (" .. math.floor(healthPercent) .. "%)")
    end

    -- 2. Defensive Cooldowns (Shield, Bubble, etc)
    local hasDefensiveBuff = self:HasDefensiveBuff(unit)
    if hasDefensiveBuff then
        score = score - 2 * THREAT_WEIGHTS.defensiveCooldowns
        table.insert(reasons, "Defensive CD active (-2)")
    end

    -- 3. Offensive Cooldowns (Heroism, Avatar, etc)
    local hasOffensiveBuff = self:HasOffensiveBuff(unit)
    if hasOffensiveBuff then
        score = score + 3 * THREAT_WEIGHTS.offensiveCooldowns
        table.insert(reasons, "Offensive CD active (+3)")
    end

    -- 4. Crowd Control Immunity
    if self:HasCCImmunity(unit) then
        score = score - 1.5 * THREAT_WEIGHTS.crowdControl
        table.insert(reasons, "CC Immune (-1.5)")
    end

    -- 5. Crowd Control (Stunned = no threat)
    if self:IsCC(unit) then
        score = score - 5
        table.insert(reasons, "CC'd (-5)")
    end

    -- 6. Class-based Threat
    local _, class = UnitClass(unit)
    local classThreat = self:GetClassThreatLevel(class)
    score = score + classThreat * THREAT_WEIGHTS.damageClass
    table.insert(reasons, class .. " class (" .. classThreat .. ")")

    -- 7. Current Target (what they're attacking)
    local targetingMe = self:IsTargetingMe(unit)
    if targetingMe then
        score = score + 2
        table.insert(reasons, "Targeting YOU (+2)")
    end

    -- 8. Casting dangerous spell
    local isCastingDangerous = self:IsCastingDangerousSpell(unit)
    if isCastingDangerous then
        score = score + 2.5
        table.insert(reasons, "Casting dangerous spell (+2.5)")
    end

    -- Ensure minimum 0.1
    score = math.max(0.1, score)

    return score, reasons
end

-- ===========================
-- HELPER FUNCTIONS
-- ===========================

function ThreatDetector:HasDefensiveBuff(unit)
    local defensiveBuffs = {
        "Divine Shield",
        "Bubble",
        "Power Word: Shield",
        "Ice Block",
        "Unending Resolve",
        "Anti-Magic Shell",
        "Shield Block",
        "Consecration",
    }

    for i = 1, 40 do
        local name = UnitAura(unit, i, "BUFF")
        if not name then break end

        for _, buff in ipairs(defensiveBuffs) do
            if name:find(buff) then
                return true
            end
        end
    end

    return false
end

function ThreatDetector:HasOffensiveBuff(unit)
    local offensiveBuffs = {
        "Bloodlust",
        "Time Warp",
        "Heroism",
        "Avatar",
        "Power Infusion",
        "Lifeblood",
        "Icy Veins",
        "Rapid Fire",
        "Avenging Wrath",
    }

    for i = 1, 40 do
        local name = UnitAura(unit, i, "BUFF")
        if not name then break end

        for _, buff in ipairs(offensiveBuffs) do
            if name:find(buff) then
                return true
            end
        end
    end

    return false
end

function ThreatDetector:HasCCImmunity(unit)
    local immunityBuffs = {
        "Divine Shield",
        "Ice Block",
        "Bubble",
        "Deterrence",
    }

    for i = 1, 40 do
        local name = UnitAura(unit, i, "BUFF")
        if not name then break end

        for _, buff in ipairs(immunityBuffs) do
            if name:find(buff) then
                return true
            end
        end
    end

    return false
end

function ThreatDetector:IsCC(unit)
    local ccDebuffs = {
        "Stun",
        "Freeze",
        "Root",
        "Silence",
        "Blind",
        "Polymorph",
        "Hex",
        "Fear",
    }

    for i = 1, 40 do
        local name = UnitAura(unit, i, "DEBUFF")
        if not name then break end

        for _, debuff in ipairs(ccDebuffs) do
            if name:find(debuff) then
                return true
            end
        end
    end

    return false
end

function ThreatDetector:GetClassThreatLevel(class)
    local classThreats = {
        ROGUE = 3.5,           -- Highest threat
        WARRIOR = 3.2,
        HUNTER = 3.0,
        MAGE = 2.8,
        WARLOCK = 2.6,
        SHAMAN = 2.4,
        PALADIN = 2.0,         -- Can heal/shield
        PRIEST = 1.5,          -- Can heal
        DRUID = 1.8,           -- Can heal
        MONK = 2.5,
        DEMON_HUNTER = 3.3,
        DEATH_KNIGHT = 2.9,
    }

    return classThreats[class] or 2.0
end

function ThreatDetector:IsTargetingMe(unit)
    local target = UnitTarget(unit)
    if not target then return false end

    return UnitIsUnit(target, "player")
end

function ThreatDetector:IsCastingDangerousSpell(unit)
    local dangerous = {
        "Pyroblast",
        "Frostbolt",
        "Chaos Bolt",
        "Holy Fire",
        "Arcane Missiles",
        "Aimed Shot",
        "Mortal Strike",
        "Shadow Word: Death",
    }

    local spellName = UnitCastingInfo(unit)
    if not spellName then return false end

    for _, spell in ipairs(dangerous) do
        if spellName:find(spell) then
            return true
        end
    end

    return false
end

-- ===========================
-- THREAT UPDATES
-- ===========================

function ThreatDetector:UpdateAllThreats()
    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) then
            local score, reasons = self:CalculateThreat(unit)
            threatLevels[unit].score = score
            threatLevels[unit].reasons = reasons
            threatLevels[unit].lastUpdate = GetTime()
        end
    end

    self:CalculateFocusRecommendation()
end

-- ===========================
-- FOCUS RECOMMENDATION
-- ===========================

function ThreatDetector:CalculateFocusRecommendation()
    local highestThreat = nil
    local highestScore = 0

    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) then
            local score = threatLevels[unit].score

            if score > highestScore then
                highestScore = score
                highestThreat = {
                    unit = unit,
                    index = i,
                    score = score,
                    name = GetUnitName(unit),
                    class = select(2, UnitClass(unit)),
                    reasons = threatLevels[unit].reasons,
                }
            end
        end
    end

    focusRecommendation = highestThreat
    return focusRecommendation
end

-- ===========================
-- PUBLIC ACCESS
-- ===========================

function ThreatDetector:GetFocusRecommendation()
    return focusRecommendation
end

function ThreatDetector:GetThreatLevel(unit)
    return threatLevels[unit].score or 0
end

function ThreatDetector:GetAllThreats()
    local result = {}

    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) then
            table.insert(result, {
                unit = unit,
                index = i,
                name = GetUnitName(unit),
                class = select(2, UnitClass(unit)),
                threat = threatLevels[unit].score,
                reasons = threatLevels[unit].reasons,
            })
        end
    end

    -- Sort by threat level (highest first)
    table.sort(result, function(a, b)
        return a.threat > b.threat
    end)

    return result
end

function ThreatDetector:GetThreatSummary()
    local summary = {
        highestThreat = focusRecommendation,
        allThreats = self:GetAllThreats(),
        timestamp = GetTime(),
    }

    return summary
end

function ThreatDetector:PrintThreatAnalysis()
    local threats = self:GetAllThreats()

    print("|cff00ffff=== THREAT ANALYSIS ===|r")
    print("Priority Focus: " .. (focusRecommendation and focusRecommendation.name or "None"))

    for i, threat in ipairs(threats) do
        local color = i == 1 and "|cffff0000" or i == 2 and "|cffff8800" or "|cff00ff00"
        print(string.format("%s#%d: %s (%.1f) %s|r", color, threat.index, threat.name, threat.threat, threat.class))

        for _, reason in ipairs(threat.reasons) do
            print("  - " .. reason)
        end
    end
end

-- ===========================
-- VISUAL FEEDBACK
-- ===========================

function ThreatDetector:GetFrameColor(unit)
    local score = threatLevels[unit].score or 0

    if score >= 3.5 then
        return {r = 1, g = 0, b = 0}         -- Red - CRITICAL
    elseif score >= 2.5 then
        return {r = 1, g = 0.5, b = 0}       -- Orange - HIGH
    elseif score >= 1.5 then
        return {r = 1, g = 1, b = 0}         -- Yellow - MEDIUM
    else
        return {r = 0, g = 1, b = 0}         -- Green - LOW
    end
end

function ThreatDetector:GetThreatText(score)
    if score >= 3.5 then
        return "⚠️ FOCUS"
    elseif score >= 2.5 then
        return "🔴 HIGH"
    elseif score >= 1.5 then
        return "🟡 MED"
    else
        return "🟢 LOW"
    end
end

-- Export
AM.ThreatDetector = ThreatDetector

return ThreatDetector
