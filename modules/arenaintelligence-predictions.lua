-- Arenamaster: Advanced Win Prediction Module
-- Machine learning-style match outcome prediction

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ArenaIntelligencePredictions = Arenamaster:NewModule("ArenaIntelligencePredictions", "AceEvent-3.0")

local ArenaIntelligenceProfiler = Arenamaster:GetModule("ArenaIntelligenceProfiler")

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaIntelligencePredictions:OnInitialize()
	if not Arenamaster.db.profile.matchPredictions then
		Arenamaster.db.profile.matchPredictions = {}
	end
end

function ArenaIntelligencePredictions:OnEnable()
	self:RegisterEvent("ARENA_PREP_START")
end

-- ===========================
-- WIN PREDICTION ENGINE
-- ===========================

function ArenaIntelligencePredictions:PredictMatchOutcome(opponents)
	if not opponents or #opponents == 0 then
		return {
			winProbability = 50,
			confidence = 0.3,
			factors = {},
			recommendation = "Insufficient data",
		}
	end

	local factors = {}
	local totalScore = 0

	-- Factor 1: Rating Advantage (25%)
	local ratingScore = self:CalculateRatingAdvantage(opponents)
	factors.rating = ratingScore
	totalScore = totalScore + (ratingScore * 0.25)

	-- Factor 2: Head-to-Head Record (20%)
	local h2hScore = self:CalculateHeadToHeadRecord(opponents)
	factors.headToHead = h2hScore
	totalScore = totalScore + (h2hScore * 0.20)

	-- Factor 3: Recent Performance (20%)
	local recentScore = self:CalculateRecentPerformance()
	factors.recentPerformance = recentScore
	totalScore = totalScore + (recentScore * 0.20)

	-- Factor 4: Opponent Strength Analysis (20%)
	local opponentScore = self:AnalyzeOpponentStrength(opponents)
	factors.opponentStrength = opponentScore
	totalScore = totalScore + (opponentScore * 0.20)

	-- Factor 5: Team Composition (15%)
	local compositionScore = self:AnalyzeTeamComposition(opponents)
	factors.teamComposition = compositionScore
	totalScore = totalScore + (compositionScore * 0.15)

	-- Calculate confidence based on data availability
	local confidence = self:CalculatePredictionConfidence(opponents)

	-- Normalize probability to 0-100
	local winProbability = math.min(math.max(totalScore, 0), 100)

	return {
		winProbability = math.floor(winProbability),
		confidence = confidence,
		factors = factors,
		recommendation = self:GetPredictionRecommendation(winProbability, confidence),
	}
end

function ArenaIntelligencePredictions:CalculateRatingAdvantage(opponents)
	local playerRating = Arenamaster.db.profile.currentRating or 1500

	local totalOpponentRating = 0
	local opponentCount = 0

	for _, opponent in ipairs(opponents) do
		-- Would need opponent rating from profile
		local oppRating = opponent.rating or 1500
		totalOpponentRating = totalOpponentRating + oppRating
		opponentCount = opponentCount + 1
	end

	if opponentCount == 0 then return 50 end

	local averageOpponentRating = totalOpponentRating / opponentCount
	local ratingDifference = playerRating - averageOpponentRating

	-- Convert rating difference to probability
	-- Every 200 rating difference = ~10% advantage
	local ratingScore = 50 + (ratingDifference / 200) * 10

	return math.min(math.max(ratingScore, 20), 80)
end

function ArenaIntelligencePredictions:CalculateHeadToHeadRecord(opponents)
	if not ArenaIntelligenceProfiler then return 50 end

	local totalWinRate = 0
	local profileCount = 0

	for _, opponent in ipairs(opponents) do
		if opponent.name then
			local profile = ArenaIntelligenceProfiler:GetOpponentProfile(opponent.name)
			if profile and profile.encounters > 0 then
				local winRate = ArenaIntelligenceProfiler:GetWinRateVsOpponent(opponent.name)
				totalWinRate = totalWinRate + winRate
				profileCount = profileCount + 1
			end
		end
	end

	if profileCount == 0 then return 50 end

	return totalWinRate / profileCount
end

function ArenaIntelligencePredictions:CalculateRecentPerformance()
	local ArenaIntelligenceStats = Arenamaster:GetModule("ArenaIntelligenceStats")
	if not ArenaIntelligenceStats then return 50 end

	local history = Arenamaster.db.profile.matchHistory or {}
	if #history < 3 then return 50 end

	-- Calculate win rate from last 10 matches
	local recentMatches = {}
	for i = 1, math.min(10, #history) do
		table.insert(recentMatches, history[i])
	end

	local wins = 0
	for _, match in ipairs(recentMatches) do
		if match.won then
			wins = wins + 1
		end
	end

	local recentWinRate = (wins / #recentMatches) * 100

	-- Boost confidence if performing well, reduce if struggling
	return math.max(30, math.min(70, recentWinRate))
end

function ArenaIntelligencePredictions:AnalyzeOpponentStrength(opponents)
	if not ArenaIntelligenceProfiler then return 50 end

	local totalStrength = 0
	local opponentCount = 0

	for _, opponent in ipairs(opponents) do
		if opponent.name then
			local profile = ArenaIntelligenceProfiler:GetOpponentProfile(opponent.name)
			if profile then
				-- Calculate opponent strength from their metrics
				local avgDamageScore = math.min(profile.avgDamage / 50000 * 30, 30)
				local avgHealingScore = math.min(profile.avgHealing / 40000 * 30, 30)
				local ccScore = math.min(profile.avgCCs / 10 * 20, 20)
				local encounterScore = math.min(profile.encounters / 50 * 20, 20)

				local opponentStrength = 100 - (avgDamageScore + avgHealingScore + ccScore)
				totalStrength = totalStrength + opponentStrength
				opponentCount = opponentCount + 1
			else
				-- Unknown opponent = neutral
				totalStrength = totalStrength + 50
				opponentCount = opponentCount + 1
			end
		else
			totalStrength = totalStrength + 50
			opponentCount = opponentCount + 1
		end
	end

	if opponentCount == 0 then return 50 end

	return totalStrength / opponentCount
end

function ArenaIntelligencePredictions:AnalyzeTeamComposition(opponents)
	-- Analyze class composition advantages
	local classCount = {}
	local scale = 1.0

	for _, opponent in ipairs(opponents) do
		if opponent.class then
			classCount[opponent.class] = (classCount[opponent.class] or 0) + 1
		end
	end

	-- Simple class advantage model
	-- (In reality, this would be much more complex)
	local compositionScore = 50

	-- Check for balanced vs unbalanced comps
	local maxClassCount = 0
	for _, count in pairs(classCount) do
		if count > maxClassCount then
			maxClassCount = count
		end
	end

	if maxClassCount > (#opponents / 2) then
		-- Opponent has duplicate classes (potential advantage)
		compositionScore = compositionScore - 5
	end

	return math.max(30, math.min(70, compositionScore))
end

function ArenaIntelligencePredictions:CalculatePredictionConfidence(opponents)
	-- Confidence is higher with more historical data
	if not ArenaIntelligenceProfiler then return 0.4 end

	local profileCount = 0
	local totalEncounters = 0

	for _, opponent in ipairs(opponents) do
		if opponent.name then
			local profile = ArenaIntelligenceProfiler:GetOpponentProfile(opponent.name)
			if profile then
				profileCount = profileCount + 1
				totalEncounters = totalEncounters + profile.encounters
			end
		end
	end

	-- Base confidence on data availability
	local dataConfidence = 0.3 + (profileCount / math.max(#opponents, 1)) * 0.3
	local encounterConfidence = math.min(totalEncounters / 20, 0.4)

	return math.min(dataConfidence + encounterConfidence, 0.9)
end

function ArenaIntelligencePredictions:GetPredictionRecommendation(winProbability, confidence)
	local confPercent = math.floor(confidence * 100)

	if winProbability >= 70 then
		return string.format("Favorable matchup (%.0f%% confidence)", confPercent)
	elseif winProbability >= 60 then
		return string.format("Slight advantage (%.0f%% confidence)", confPercent)
	elseif winProbability >= 50 then
		return string.format("Even match (%.0f%% confidence)", confPercent)
	elseif winProbability >= 40 then
		return string.format("Slight disadvantage (%.0f%% confidence)", confPercent)
	else
		return string.format("Difficult matchup (%.0f%% confidence)", confPercent)
	end
end

-- ===========================
-- MATCH PREDICTION STORAGE
-- ===========================

function ArenaIntelligencePredictions:StoreMatchPrediction(opponents, prediction)
	local record = {
		timestamp = GetTime(),
		opponents = opponents,
		prediction = prediction,
		actualResult = nil,  -- Will be filled at match end
	}

	table.insert(Arenamaster.db.profile.matchPredictions, 1, record)

	-- Keep last 50 predictions
	if #Arenamaster.db.profile.matchPredictions > 50 then
		table.remove(Arenamaster.db.profile.matchPredictions)
	end
end

function ArenaIntelligencePredictions:CalculatePredictionAccuracy()
	local predictions = Arenamaster.db.profile.matchPredictions or {}
	local completedPredictions = 0
	local correctPredictions = 0

	for _, record in ipairs(predictions) do
		if record.actualResult then
			completedPredictions = completedPredictions + 1

			-- Check if prediction was correct
			local predicted = record.prediction.winProbability >= 50
			if predicted == record.actualResult then
				correctPredictions = correctPredictions + 1
			end
		end
	end

	if completedPredictions == 0 then return 0 end

	return math.floor((correctPredictions / completedPredictions) * 100)
end

-- ===========================
-- REPORTING
-- ===========================

function ArenaIntelligencePredictions:PrintMatchPrediction(opponents)
	local prediction = self:PredictMatchOutcome(opponents)

	print("|cff00aiff════════════════════════════════════════|r")
	print("|cff00aiff      MATCH OUTCOME PREDICTION         |r")
	print("|cff00aiff════════════════════════════════════════|r")

	print("|cff4dabf7Win Probability:|r " .. prediction.winProbability .. "%")
	print("|cff4dabf7Confidence:|r " .. math.floor(prediction.confidence * 100) .. "%")

	print("|cff4dabf7Prediction:|r " .. prediction.recommendation)

	print("|cff4dabf7Factor Analysis:|r")
	print("  Rating: " .. math.floor(prediction.factors.rating) .. "%")
	print("  Head-to-Head: " .. math.floor(prediction.factors.headToHead) .. "%")
	print("  Recent Performance: " .. math.floor(prediction.factors.recentPerformance) .. "%")
	print("  Opponent Strength: " .. math.floor(prediction.factors.opponentStrength) .. "%")
	print("  Team Composition: " .. math.floor(prediction.factors.teamComposition) .. "%")

	local accuracy = self:CalculatePredictionAccuracy()
	if accuracy > 0 then
		print("|cff4dabf7Historical Accuracy:|r " .. accuracy .. "%")
	end
end

function ArenaIntelligencePredictions:PrintPredictionStats()
	local predictions = Arenamaster.db.profile.matchPredictions or {}
	local accuracy = self:CalculatePredictionAccuracy()

	print("|cff00aiff════════════════════════════════════════|r")
	print("|cff00aiff    PREDICTION PERFORMANCE STATS       |r")
	print("|cff00aiff════════════════════════════════════════|r")

	print("|cff4dabf7Total Predictions:|r " .. #predictions)

	local completedCount = 0
	for _, record in ipairs(predictions) do
		if record.actualResult then
			completedCount = completedCount + 1
		end
	end

	print("|cff4dabf7Completed Predictions:|r " .. completedCount)
	if completedCount > 0 then
		print("|cff4dabf7Accuracy:|r " .. accuracy .. "%")
	end
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function ArenaIntelligencePredictions:ARENA_PREP_START()
	-- Would analyze opponents at arena prep start
	-- Predictions would be shown to player before match begins
end
