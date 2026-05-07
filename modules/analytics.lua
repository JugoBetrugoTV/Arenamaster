-- Arenamaster: Live Combat Analytics Module
-- Echtzeit-Analyse während eines Arena-Matches

local AM = Arenamaster
local CombatAnalytics = {}

local matchData = nil
local currentMatch = {
    startTime = 0,
    duration = 0,
    opponentTeam = {},
    myTeam = {},
    events = {},
    damageDealt = 0,
    damageTaken = 0,
    kills = 0,
    deaths = 0,
    cc_used = 0,
    cc_received = 0,
    cooldowns_used = {},
    interrupts = 0,
    dispels = 0,
}

-- ===========================
-- INITIALIZATION
-- ===========================

function CombatAnalytics:Initialize()
    self:ResetMatch()
end

function CombatAnalytics:ResetMatch()
    currentMatch = {
        startTime = 0,
        duration = 0,
        opponentTeam = {},
        myTeam = {},
        events = {},
        damageDealt = 0,
        damageTaken = 0,
        kills = 0,
        deaths = 0,
        cc_used = 0,
        cc_received = 0,
        cooldowns_used = {},
        interrupts = 0,
        dispels = 0,
        timestamps = {},
    }
end

-- ===========================
-- MATCH START/END
-- ===========================

function CombatAnalytics:OnMatchStart()
    self:ResetMatch()
    currentMatch.startTime = GetTime()

    -- Record opponent team
    for i = 1, 5 do
        local unit = "arena" .. i
        if UnitExists(unit) then
            table.insert(currentMatch.opponentTeam, {
                index = i,
                name = GetUnitName(unit),
                class = select(2, UnitClass(unit)),
                startingHealth = UnitHealth(unit),
            })
        end
    end

    print("|cff00ff00[Arenamaster]|r Match started - Analytics recording...")
end

function CombatAnalytics:OnMatchEnd(result)
    currentMatch.duration = GetTime() - currentMatch.startTime
    currentMatch.result = result == 1 and "WIN" or "LOSS"

    self:FinalizeMatch()
    self:PrintMatchSummary()
end

function CombatAnalytics:FinalizeMatch()
    -- Store match in history
    if not ArenamasterDB.matchHistory then
        ArenamasterDB.matchHistory = {}
    end

    local matchEntry = {
        timestamp = date("%Y-%m-%d %H:%M:%S"),
        duration = currentMatch.duration,
        result = currentMatch.result,
        opponents = currentMatch.opponentTeam,
        damageDealt = currentMatch.damageDealt,
        damageTaken = currentMatch.damageTaken,
        kills = currentMatch.kills,
        deaths = currentMatch.deaths,
        cc_used = currentMatch.cc_used,
        cc_received = currentMatch.cc_received,
    }

    table.insert(ArenamasterDB.matchHistory, matchEntry)

    -- Keep only last 100 matches
    if #ArenamasterDB.matchHistory > 100 then
        table.remove(ArenamasterDB.matchHistory, 1)
    end
end

-- ===========================
-- EVENT TRACKING
-- ===========================

function CombatAnalytics:RecordEvent(eventType, data)
    local event = {
        type = eventType,
        timestamp = GetTime() - currentMatch.startTime,
        data = data,
    }

    table.insert(currentMatch.events, event)
end

function CombatAnalytics:OnCombatLogEvent(eventType, ...)
    local timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = select(1, ...)

    -- Track damage dealt to enemies
    if event == "SPELL_DAMAGE" or event == "SWING_DAMAGE" then
        if sourceGUID == UnitGUID("player") then
            local amount = select(12, ...)
            currentMatch.damageDealt = currentMatch.damageDealt + (amount or 0)

            self:RecordEvent("DAMAGE_DEALT", {
                to = destName,
                amount = amount,
            })
        end
    end

    -- Track damage taken from enemies
    if event == "SPELL_DAMAGE" or event == "SWING_DAMAGE" then
        if destGUID == UnitGUID("player") then
            local amount = select(12, ...)
            currentMatch.damageTaken = currentMatch.damageTaken + (amount or 0)

            self:RecordEvent("DAMAGE_TAKEN", {
                from = sourceName,
                amount = amount,
            })
        end
    end

    -- Track CC used
    if event == "SPELL_AURA_APPLIED" then
        if sourceGUID == UnitGUID("player") then
            local spellName = select(13, ...)
            if self:IsCCSpell(spellName) then
                currentMatch.cc_used = currentMatch.cc_used + 1
                self:RecordEvent("CC_APPLIED", {
                    spell = spellName,
                    target = destName,
                })
            end
        end
    end

    -- Track CC received
    if event == "SPELL_AURA_APPLIED" then
        if destGUID == UnitGUID("player") then
            local spellName = select(13, ...)
            if self:IsCCSpell(spellName) then
                currentMatch.cc_received = currentMatch.cc_received + 1
                self:RecordEvent("CC_RECEIVED", {
                    spell = spellName,
                    from = sourceName,
                })
            end
        end
    end

    -- Track kills
    if event == "UNIT_DIED" then
        if sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("party1") or sourceGUID == UnitGUID("party2") then
            currentMatch.kills = currentMatch.kills + 1
            self:RecordEvent("KILL", {
                target = destName,
            })
        end
    end

    -- Track deaths
    if event == "UNIT_DIED" and destGUID == UnitGUID("player") then
        currentMatch.deaths = currentMatch.deaths + 1
        self:RecordEvent("DEATH", {
            from = sourceName,
        })
    end

    -- Track interrupts
    if event == "SPELL_INTERRUPT" and sourceGUID == UnitGUID("player") then
        currentMatch.interrupts = currentMatch.interrupts + 1
        self:RecordEvent("INTERRUPT", {
            spell = select(13, ...),
            target = destName,
        })
    end

    -- Track dispels
    if event == "SPELL_DISPEL" and sourceGUID == UnitGUID("player") then
        currentMatch.dispels = currentMatch.dispels + 1
        self:RecordEvent("DISPEL", {
            spell = select(13, ...),
            target = destName,
        })
    end
end

-- ===========================
-- HELPER FUNCTIONS
-- ===========================

function CombatAnalytics:IsCCSpell(spellName)
    local ccSpells = {
        "Stun",
        "Freeze",
        "Blind",
        "Polymorph",
        "Hex",
        "Fear",
        "Root",
        "Silence",
    }

    for _, spell in ipairs(ccSpells) do
        if spellName and spellName:find(spell) then
            return true
        end
    end

    return false
end

-- ===========================
-- STATISTICS CALCULATION
-- ===========================

function CombatAnalytics:GetCurrentMatchStats()
    local duration = GetTime() - currentMatch.startTime

    return {
        duration = duration,
        damageDealt = currentMatch.damageDealt,
        damagePerSecond = duration > 0 and (currentMatch.damageDealt / duration) or 0,
        damageTaken = currentMatch.damageTaken,
        damageReduction = currentMatch.damageTaken > 0 and ((1 - (currentMatch.damageTaken / (currentMatch.damageDealt + currentMatch.damageTaken))) * 100) or 0,
        kills = currentMatch.kills,
        deaths = currentMatch.deaths,
        cc_used = currentMatch.cc_used,
        cc_received = currentMatch.cc_received,
        interrupts = currentMatch.interrupts,
        dispels = currentMatch.dispels,
    }
end

function CombatAnalytics:GetOpponentStats()
    local stats = {}

    for _, opponent in ipairs(currentMatch.opponentTeam) do
        local damageToOpponent = 0

        -- Count damage events against this opponent
        for _, event in ipairs(currentMatch.events) do
            if event.type == "DAMAGE_DEALT" and event.data.to == opponent.name then
                damageToOpponent = damageToOpponent + (event.data.amount or 0)
            end
        end

        table.insert(stats, {
            name = opponent.name,
            class = opponent.class,
            damageDealt = damageToOpponent,
            percentage = currentMatch.damageDealt > 0 and ((damageToOpponent / currentMatch.damageDealt) * 100) or 0,
        })
    end

    -- Sort by damage
    table.sort(stats, function(a, b)
        return a.damageDealt > b.damageDealt
    end)

    return stats
end

function CombatAnalytics:GetEfficiency()
    -- Calculate how efficient the match was
    local duration = GetTime() - currentMatch.startTime
    local dps = duration > 0 and (currentMatch.damageDealt / duration) or 0
    local ccPerMinute = (currentMatch.cc_used / (duration / 60))
    local survivalRate = (duration > 0) and ((duration - currentMatch.deaths * 5) / duration) or 0

    return {
        dps = dps,
        cc_per_minute = ccPerMinute,
        survival_rate = math.max(0, survivalRate * 100),
        efficiency_score = (dps / 100) + (ccPerMinute / 2) + (survivalRate * 100) / 3,
    }
end

-- ===========================
-- REPORTING
-- ===========================

function CombatAnalytics:PrintMatchSummary()
    local stats = self:GetCurrentMatchStats()
    local opponentStats = self:GetOpponentStats()
    local efficiency = self:GetEfficiency()

    print("|cff00ffff╔════════════════════════════════════╗|r")
    print("|cff00ffff║    MATCH SUMMARY - " .. currentMatch.result .. "          ║|r")
    print("|cff00ffff╠════════════════════════════════════╣|r")
    print(string.format("|cff00ffff║ Duration: %.1fs|r", stats.duration))
    print(string.format("|cff00ffff║ Damage Dealt: %.0f (%.1f DPS)|r", stats.damageDealt, stats.damagePerSecond))
    print(string.format("|cff00ffff║ Damage Taken: %.0f|r", stats.damageTaken))
    print(string.format("|cff00ffff║ Kills: %d | Deaths: %d|r", stats.kills, stats.deaths))
    print(string.format("|cff00ffff║ CC Used: %d | CC Received: %d|r", stats.cc_used, stats.cc_received))
    print(string.format("|cff00ffff║ Interrupts: %d | Dispels: %d|r", stats.interrupts, stats.dispels))
    print("|cff00ffff╠════════════════════════════════════╣|r")
    print("|cff00ffff║ OPPONENT DAMAGE BREAKDOWN|r")

    for i, opp in ipairs(opponentStats) do
        if i <= 5 then
            print(string.format("|cff00ffff║ %s (%s): %.0f (%.1f%%)|r", opp.name, opp.class, opp.damageDealt, opp.percentage))
        end
    end

    print("|cff00ffff╠════════════════════════════════════╣|r")
    print(string.format("|cff00ffff║ Efficiency Score: %.1f|r", efficiency.efficiency_score))
    print("|cff00ffff╚════════════════════════════════════╝|r")
end

function CombatAnalytics:GetMatchHistory(limit)
    limit = limit or 10
    local history = ArenamasterDB.matchHistory or {}

    local result = {}
    local start = math.max(1, #history - limit + 1)

    for i = start, #history do
        table.insert(result, history[i])
    end

    return result
end

-- Export
AM.CombatAnalytics = CombatAnalytics

return CombatAnalytics
