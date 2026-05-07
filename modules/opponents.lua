-- Arenamaster: Opponent Tracking Module
-- Verfolgt gegnerische Spieler und deren Statistiken

local AM = Arenamaster
local OpponentTracker = {}

-- Gegner-Cache
local opponentCache = {}
local matchOpponents = {}

-- ===========================
-- GEGNER TRACKING
-- ===========================

function OpponentTracker:Initialize()
    self:LoadOpponentCache()
end

function OpponentTracker:LoadOpponentCache()
    if not ArenamasterDB.opponentCache then
        ArenamasterDB.opponentCache = {}
    end
    opponentCache = ArenamasterDB.opponentCache
end

function OpponentTracker:AddOpponent(name, class, spec, rating)
    if not opponentCache[name] then
        opponentCache[name] = {
            class = class,
            spec = spec,
            rating = rating,
            encounters = 0,
            wins = 0,
            losses = 0,
            lastSeen = GetTime(),
            firstSeen = GetTime()
        }
    end

    local opponent = opponentCache[name]
    opponent.lastSeen = GetTime()
    opponent.encounters = opponent.encounters + 1
    opponent.rating = rating or opponent.rating
    opponent.class = class or opponent.class
    opponent.spec = spec or opponent.spec
end

function OpponentTracker:UpdateOpponentResult(name, result)
    if not opponentCache[name] then return end

    local opponent = opponentCache[name]
    if result == "WIN" then
        opponent.wins = opponent.wins + 1
    else
        opponent.losses = opponent.losses + 1
    end
end

function OpponentTracker:GetOpponentInfo(name)
    return opponentCache[name]
end

function OpponentTracker:GetTopOpponents(limit)
    limit = limit or 10
    local opponents = {}

    for name, data in pairs(opponentCache) do
        table.insert(opponents, {
            name = name,
            class = data.class,
            spec = data.spec,
            encounters = data.encounters,
            wins = data.wins,
            losses = data.losses,
            rating = data.rating
        })
    end

    table.sort(opponents, function(a, b) return a.encounters > b.encounters end)

    local result = {}
    for i = 1, math.min(limit, #opponents) do
        table.insert(result, opponents[i])
    end

    return result
end

function OpponentTracker:GetWinrateAgainst(name)
    local opponent = opponentCache[name]
    if not opponent or opponent.encounters == 0 then return 0 end

    return math.floor((opponent.wins / opponent.encounters) * 100)
end

-- Export
AM.OpponentTracker = OpponentTracker

return OpponentTracker
