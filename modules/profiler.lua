-- Arenamaster: Opponent Profiler Module
-- Lernt Spielstile und Verhaltensmuster von Gegnern

local AM = Arenamaster
local OpponentProfiler = {}

-- Opponent Profile Structure
local opponentProfiles = {}

-- Playstyle Categories
local PLAYSTYLES = {
    AGGRESSIVE = "Aggressive",
    DEFENSIVE = "Defensive",
    BALANCED = "Balanced",
    HEALER = "Healer",
    SUPPORT = "Support",
    BURST = "Burst Damage",
    CONTROL = "Control",
    UNKNOWN = "Unknown"
}

-- ===========================
-- INITIALIZATION
-- ===========================

function OpponentProfiler:Initialize()
    if not ArenamasterDB.opponentProfiles then
        ArenamasterDB.opponentProfiles = {}
    end
    opponentProfiles = ArenamasterDB.opponentProfiles
end

-- ===========================
-- PROFILE CREATION & UPDATES
-- ===========================

function OpponentProfiler:CreateProfile(name, class, spec)
    if not opponentProfiles[name] then
        opponentProfiles[name] = {
            name = name,
            class = class,
            spec = spec,
            firstSeen = date("%Y-%m-%d %H:%M:%S"),
            lastSeen = date("%Y-%m-%d %H:%M:%S"),

            -- Encounter Statistics
            encounters = 0,
            wins = 0,
            losses = 0,

            -- Playstyle Analysis
            playstyle = "Unknown",
            confidence = 0,

            -- Behavioral Patterns
            behavior = {
                preferredTargets = {},  -- Who they usually attack
                commonSpells = {},      -- Spells they often cast
                commonCCs = {},         -- CCs they use
                defensiveTiming = {},   -- When they use defensives
                burstyness = 0,         -- 0-100 how burst-heavy
                defensiveness = 0,      -- 0-100 how defensive
            },

            -- Strategy Recommendations
            weaknesses = {},
            strengths = {},
            counters = {},

            -- Statistics
            averageDamage = 0,
            averageDuration = 0,
            winRate = 0,
            lastFaceoff = nil,
        }
    end

    return opponentProfiles[name]
end

function OpponentProfiler:UpdateProfile(name, class, spec, matchData)
    local profile = self:CreateProfile(name, class, spec)

    profile.lastSeen = date("%Y-%m-%d %H:%M:%S")
    profile.encounters = profile.encounters + 1

    -- Update win/loss record
    if matchData.result == "WIN" then
        profile.wins = profile.wins + 1
    else
        profile.losses = profile.losses + 1
    end

    profile.winRate = math.floor((profile.wins / profile.encounters) * 100)

    -- Analyze playstyle from match data
    self:AnalyzePlaystyle(profile, matchData)

    -- Update behavioral patterns
    self:UpdateBehavior(profile, matchData)

    -- Generate recommendations
    self:GenerateRecommendations(profile)

    return profile
end

-- ===========================
-- PLAYSTYLE ANALYSIS
-- ===========================

function OpponentProfiler:AnalyzePlaystyle(profile, matchData)
    local class = profile.class
    local damageDealt = matchData.damageDealt or 0
    local damageTaken = matchData.damageTaken or 0
    local ccUsed = matchData.cc_used or 0
    local ccReceived = matchData.cc_received or 0

    -- Calculate metrics
    local aggressionRatio = damageDealt / math.max(1, damageTaken)
    local ccRatio = ccUsed / math.max(1, ccReceived)

    -- Determine playstyle
    if class == "PRIEST" or class == "DRUID" or class == "PALADIN" then
        profile.playstyle = PLAYSTYLES.HEALER
    elseif class == "ROGUE" or class == "DEMON_HUNTER" then
        if aggressionRatio > 2.0 then
            profile.playstyle = PLAYSTYLES.BURST
        else
            profile.playstyle = PLAYSTYLES.AGGRESSIVE
        end
    elseif class == "MAGE" then
        if ccRatio > 1.5 then
            profile.playstyle = PLAYSTYLES.CONTROL
        else
            profile.playstyle = PLAYSTYLES.BURST
        end
    elseif class == "WARRIOR" then
        if damageTaken > damageDealt then
            profile.playstyle = PLAYSTYLES.DEFENSIVE
        else
            profile.playstyle = PLAYSTYLES.AGGRESSIVE
        end
    else
        if aggressionRatio > 1.5 then
            profile.playstyle = PLAYSTYLES.AGGRESSIVE
        elseif aggressionRatio < 0.8 then
            profile.playstyle = PLAYSTYLES.DEFENSIVE
        else
            profile.playstyle = PLAYSTYLES.BALANCED
        end
    end

    profile.confidence = math.min(100, profile.encounters * 10)
end

function OpponentProfiler:UpdateBehavior(profile, matchData)
    -- Track preferred targets
    if matchData.mostDamageTo then
        if not profile.behavior.preferredTargets[matchData.mostDamageTo] then
            profile.behavior.preferredTargets[matchData.mostDamageTo] = 0
        end
        profile.behavior.preferredTargets[matchData.mostDamageTo] =
            profile.behavior.preferredTargets[matchData.mostDamageTo] + 1
    end

    -- Analyze burstyness (damage spike pattern)
    if matchData.damageDealt and matchData.duration then
        local averageDps = matchData.damageDealt / math.max(1, matchData.duration)
        if averageDps > 500 then
            profile.behavior.burstyness = math.min(100, profile.behavior.burstyness + 5)
        end
    end

    -- Analyze defensiveness
    if matchData.cc_received and matchData.cc_received < 3 then
        profile.behavior.defensiveness = math.min(100, profile.behavior.defensiveness + 3)
    end

    -- Update average damage
    profile.averageDamage = (profile.averageDamage + (matchData.damageDealt or 0)) / 2
end

-- ===========================
-- RECOMMENDATIONS
-- ===========================

function OpponentProfiler:GenerateRecommendations(profile)
    profile.weaknesses = {}
    profile.strengths = {}
    profile.counters = {}

    -- Weaknesses based on playstyle
    if profile.playstyle == PLAYSTYLES.AGGRESSIVE then
        table.insert(profile.weaknesses, "Focus on defense")
        table.insert(profile.weaknesses, "Use CC when approaching")
        table.insert(profile.counters, "Defensive classes")
    elseif profile.playstyle == PLAYSTYLES.DEFENSIVE then
        table.insert(profile.weaknesses, "Low sustained damage")
        table.insert(profile.weaknesses, "Predictable patterns")
        table.insert(profile.counters, "Burst classes")
    elseif profile.playstyle == PLAYSTYLES.BURST then
        table.insert(profile.weaknesses, "Vulnerable after burst")
        table.insert(profile.weaknesses, "Predictable timing")
        table.insert(profile.counters, "Kite and disengage")
    elseif profile.playstyle == PLAYSTYLES.HEALER then
        table.insert(profile.weaknesses, "Silence/Interrupt")
        table.insert(profile.weaknesses, "Mobile casters")
        table.insert(profile.counters, "CC chain")
    end

    -- Strengths
    if profile.wins > profile.losses then
        table.insert(profile.strengths, "Strong matchup for them")
    end

    if profile.behavior.burstyness > 70 then
        table.insert(profile.strengths, "High burst damage")
    end

    if profile.behavior.defensiveness > 70 then
        table.insert(profile.strengths, "Good defensiveness")
    end
end

-- ===========================
-- PREDICTION & ANALYSIS
-- ===========================

function OpponentProfiler:PredictPlaystyle(name)
    local profile = opponentProfiles[name]
    if not profile then
        return nil
    end

    return {
        name = profile.name,
        playstyle = profile.playstyle,
        confidence = profile.confidence,
        description = self:GetPlaystyleDescription(profile),
    }
end

function OpponentProfiler:GetPlaystyleDescription(profile)
    local desc = ""

    if profile.playstyle == PLAYSTYLES.AGGRESSIVE then
        desc = "Tends to attack directly and aggressively. High damage output, lower defense."
    elseif profile.playstyle == PLAYSTYLES.DEFENSIVE then
        desc = "Plays defensively with shields and avoidance. Lower damage but hard to kill."
    elseif profile.playstyle == PLAYSTYLES.BALANCED then
        desc = "Balanced approach between offense and defense. Adaptable playstyle."
    elseif profile.playstyle == PLAYSTYLES.HEALER then
        desc = "Support/healing focused. Keep pressure and interrupt casts."
    elseif profile.playstyle == PLAYSTYLES.BURST then
        desc = "Bursts with high damage in short windows. Vulnerable in between."
    elseif profile.playstyle == PLAYSTYLES.CONTROL then
        desc = "Uses control effects and crowd control. Lock them down or kite."
    end

    return desc
end

function OpponentProfiler:GetCounterStrategy(name)
    local profile = opponentProfiles[name]
    if not profile then return nil end

    local strategy = {
        opponent = name,
        playstyle = profile.playstyle,
        weaknesses = profile.weaknesses,
        counters = profile.counters,
        recommendations = {}
    }

    if profile.playstyle == PLAYSTYLES.AGGRESSIVE then
        table.insert(strategy.recommendations, "Stay mobile and kite")
        table.insert(strategy.recommendations, "Use defensive cooldowns early")
        table.insert(strategy.recommendations, "CC when they commit")
    elseif profile.playstyle == PLAYSTYLES.BURST then
        table.insert(strategy.recommendations, "Predict burst timing")
        table.insert(strategy.recommendations, "Use defenses preemptively")
        table.insert(strategy.recommendations, "Counter burst when they commit")
    elseif profile.playstyle == PLAYSTYLES.HEALER then
        table.insert(strategy.recommendations, "Focus and CC the healer")
        table.insert(strategy.recommendations, "Interrupt heals")
        table.insert(strategy.recommendations, "Use silence effects")
    elseif profile.playstyle == PLAYSTYLES.DEFENSIVE then
        table.insert(strategy.recommendations, "Out-damage their sustain")
        table.insert(strategy.recommendations, "Use burst when they're vulnerable")
        table.insert(strategy.recommendations, "Focus weak points")
    end

    return strategy
end

-- ===========================
-- PROFILE QUERIES
-- ===========================

function OpponentProfiler:GetProfile(name)
    return opponentProfiles[name]
end

function OpponentProfiler:GetAllProfiles()
    local profiles = {}
    for name, profile in pairs(opponentProfiles) do
        table.insert(profiles, profile)
    end

    -- Sort by encounters (most recent opponents first)
    table.sort(profiles, function(a, b)
        return a.encounters > b.encounters
    end)

    return profiles
end

function OpponentProfiler:GetTopOpponentsByWinrate(limit)
    limit = limit or 10
    local profiles = self:GetAllProfiles()

    local result = {}
    for i = 1, math.min(limit, #profiles) do
        local p = profiles[i]
        if p.encounters >= 3 then  -- Only show if fought 3+ times
            table.insert(result, {
                name = p.name,
                class = p.class,
                winRate = p.winRate,
                encounters = p.encounters,
                playstyle = p.playstyle,
            })
        end
    end

    return result
end

function OpponentProfiler:GetPlaystyleDistribution()
    local distribution = {}
    for playstyle, _ in pairs(PLAYSTYLES) do
        distribution[playstyle] = 0
    end

    for _, profile in pairs(opponentProfiles) do
        distribution[profile.playstyle] = (distribution[profile.playstyle] or 0) + 1
    end

    return distribution
end

-- ===========================
-- PRINTING & DEBUG
-- ===========================

function OpponentProfiler:PrintProfile(name)
    local profile = opponentProfiles[name]
    if not profile then
        print("|cffff0000[Arenamaster]|r No profile for " .. name)
        return
    end

    print("|cff00ffff═══════════════════════════════════|r")
    print("|cff00ffff" .. profile.name .. " (" .. profile.class .. ")|r")
    print("|cff00ffff═══════════════════════════════════|r")
    print("Playstyle: " .. profile.playstyle .. " (Confidence: " .. profile.confidence .. "%)")
    print("Record: " .. profile.wins .. "W - " .. profile.losses .. "L (" .. profile.winRate .. "%)")
    print("Encounters: " .. profile.encounters)
    print("Average Damage: " .. math.floor(profile.averageDamage))
    print("")
    print("Burstyness: " .. profile.behavior.burstyness .. "/100")
    print("Defensiveness: " .. profile.behavior.defensiveness .. "/100")
    print("")

    if #profile.weaknesses > 0 then
        print("|cffff8800Weaknesses:|r")
        for _, weakness in ipairs(profile.weaknesses) do
            print("  - " .. weakness)
        end
    end

    if #profile.strengths > 0 then
        print("|cff00ff00Strengths:|r")
        for _, strength in ipairs(profile.strengths) do
            print("  + " .. strength)
        end
    end

    if #profile.counters > 0 then
        print("|cff00ffffCounters:|r")
        for _, counter in ipairs(profile.counters) do
            print("  • " .. counter)
        end
    end

    print("|cff00ffff═══════════════════════════════════|r")
end

function OpponentProfiler:PrintAllProfiles()
    local profiles = self:GetTopOpponentsByWinrate(15)

    print("|cff00ffff╔═══════════════════════════════════╗|r")
    print("|cff00ffff║  TOP OPPONENT PROFILES            ║|r")
    print("|cff00ffff╠═══════════════════════════════════╣|r")

    for i, p in ipairs(profiles) do
        local color = p.winRate >= 60 and "|cff00ff00" or p.winRate >= 40 and "|cffff8800" or "|cffff0000"
        print(string.format("|cff00ffff#%d|r %s %s (%dx) - %s%d%%|r",
            i, p.name, p.class, p.encounters, color, p.winRate))
    end

    print("|cff00ffff╚═══════════════════════════════════╝|r")
end

-- Export
AM.OpponentProfiler = OpponentProfiler

return OpponentProfiler
