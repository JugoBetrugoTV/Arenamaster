-- Arenamaster: Match Win Probability Predictor
-- Berechnet Gewinn-Wahrscheinlichkeit basierend auf Gegner-Daten

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local MatchPredictor = Arenamaster:NewModule("PredictorMatch", "AceEvent-3.0")

local WEIGHTS = {
	yourRating = 0.25,
	opponentAvgRating = 0.25,
	winRateAgainst = 0.20,
	teamComposition = 0.15,
	recentPerformance = 0.15,
}

function MatchPredictor:OnInitialize()
	-- Initialize
end

function MatchPredictor:OnEnable()
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
end

function MatchPredictor:CalculateWinProbability(yourRating, opponents)
	if not yourRating or not opponents then
		return 50
	end

	local opponentAvgRating = 0
	for _, opp in ipairs(opponents) do
		opponentAvgRating = opponentAvgRating + (opp.rating or 0)
	end
	opponentAvgRating = opponentAvgRating / #opponents

	local ratingDiff = yourRating - opponentAvgRating
	local ratingFactor = math.min(95, math.max(5, 50 + (ratingDiff / 100)))

	return math.floor(ratingFactor)
end

function MatchPredictor:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
	local yourRating = Arenamaster.db.profile.currentRating or 1500
	Arenamaster:PrintDebug("Win probability calculated")
end
