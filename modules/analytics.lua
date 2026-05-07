-- Arenamaster: Analytics Module
-- Combat logging und real-time Statistiken

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local Analytics = Arenamaster:NewModule("Analytics", "AceEvent-3.0", "AceTimer-3.0")

local matchStats = {
	matchCount = 0,
	wins = 0,
	losses = 0,
	totalDuration = 0,
	killCount = 0,
	deathCount = 0,
	damageDealt = 0,
	damageReceived = 0,
	healingDone = 0,
	spellsCast = 0,
}

function Analytics:OnInitialize()
	if not Arenamaster.db.profile.matchStats then
		Arenamaster.db.profile.matchStats = {}
	end
end

function Analytics:OnEnable()
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

function Analytics:LogMatch(result, duration, opponents)
	matchStats.matchCount = matchStats.matchCount + 1
	if result == "WIN" then
		matchStats.wins = matchStats.wins + 1
	else
		matchStats.losses = matchStats.losses + 1
	end
	matchStats.totalDuration = matchStats.totalDuration + duration

	table.insert(Arenamaster.db.profile.matchStats, {
		result = result,
		duration = duration,
		timestamp = GetTime(),
		opponents = opponents
	})

	if #Arenamaster.db.profile.matchStats > 100 then
		table.remove(Arenamaster.db.profile.matchStats, 1)
	end
end

function Analytics:GetStats()
	return matchStats
end

function Analytics:GetWinrate()
	if matchStats.matchCount == 0 then return 0 end
	return math.floor((matchStats.wins / matchStats.matchCount) * 100)
end

function Analytics:ShowStats()
	print("|cff00ff00[Arenamaster Stats]|r")
	print("Matches: " .. matchStats.matchCount)
	print("Wins: " .. matchStats.wins .. " (" .. self:GetWinrate() .. "%)")
	print("Losses: " .. matchStats.losses)
end

function Analytics:ARENA_MATCH_START()
	Arenamaster:PrintDebug("Analytics: Match tracking started")
end

function Analytics:ARENA_MATCH_END()
	Arenamaster:PrintDebug("Analytics: Match statistics saved")
end

function Analytics:UNIT_SPELLCAST_SUCCEEDED(event, unit, castGUID, spellID)
	matchStats.spellsCast = matchStats.spellsCast + 1
end
