-- Arenamaster: Match Win Probability Predictor
-- Berechnet Gewinn-Wahrscheinlichkeit basierend auf Gegner-Daten

local AM = Arenamaster
local MatchPredictor = {}

-- Weighting factors
local WEIGHTS = {
    yourRating = 0.25,
    opponentAvgRating = 0.25,
    winRateAgainst = 0.20,
    teamComposition = 0.15,
    recentPerformance = 0.15,
}

-- ===========================
-- INITIALIZATION
-- ===========================

function MatchPredictor:Initialize()
    -- Load historical data for trend analysis
end

-- ===========================
-- WIN PROBABILITY CALCULATION
-- ===========================

function MatchPredictor:CalculateWinProbability()
    if not AM.ThreatDetector then return 0 end

    local yourRating = ArenamasterDB.rating or 0
    local opponentTeam = AM.ThreatDetector:GetAllThreats()

    if #opponentTeam == 0 then
        return 50  -- No data, assume 50/50
    end

    local probability = 0

    -- 1. Your Rating vs Opponent Average
    local avgOpponentRating = 0
    for _, opponent in ipairs(opponentTeam) do
        avgOpponentRating = avgOpponentRating + (AM.OpponentProfiler:GetProfile(opponent.name) and
            AM.OpponentProfiler:GetProfile(opponent.name).averageRating or 1600)
    end
    avgOpponentRating = avgOpponentRating / #opponentTeam

    local ratingDiff = yourRating - avgOpponentRating
    local ratingFactor = 50 + (ratingDiff / 100) * 5  -- ±5% per 100 rating difference
    ratingFactor = math.max(20, math.min(80, ratingFactor))  -- Clamp 20-80%
    probability = probability + (ratingFactor * WEIGHTS.yourRating)

    -- 2. Win Rate Against These Opponents
    local combinedWinRate = 0
    local profiledOpponents = 0
    for _, opponent in ipairs(opponentTeam) do
        local profile = AM.OpponentProfiler:GetProfile(opponent.name)
        if profile then
            combinedWinRate = combinedWinRate + profile.winRate
            profiledOpponents = profiledOpponents + 1
        end
    end

    if profiledOpponents > 0 then
        combinedWinRate = combinedWinRate / profiledOpponents
    else
        combinedWinRate = 50
    end
    probability = probability + (combinedWinRate * WEIGHTS.winRateAgainst)

    -- 3. Team Composition Advantage
    local compositionScore = self:AnalyzeTeamComposition(opponentTeam)
    probability = probability + (compositionScore * WEIGHTS.teamComposition)

    -- 4. Recent Performance (Last 10 matches)
    local recentWinRate = self:GetRecentWinRate(10)
    probability = probability + (recentWinRate * WEIGHTS.recentPerformance)

    -- 5. Opponent Team Composition Analysis
    local opponentCompositionScore = self:AnalyzeOpponentComposition(opponentTeam)
    probability = probability - (opponentCompositionScore * 0.1)  -- Subtract for strong opponent comps

    -- Clamp to 5-95% (never 0% or 100%)
    probability = math.max(5, math.min(95, probability))

    return math.floor(probability)
end

-- ===========================
-- TEAM COMPOSITION ANALYSIS
-- ===========================

function MatchPredictor:AnalyzeTeamComposition(opponents)
    -- Placeholder - would analyze your team's class matchups
    return 50
end

function MatchPredictor:AnalyzeOpponentComposition(opponents)
    local score = 0

    -- Count classes
    local classCount = {}
    for _, opponent in ipairs(opponents) do
        local class = opponent.class
        classCount[class] = (classCount[class] or 0) + 1
    end

    -- Analyze synergies
    if classCount["HEALER"] and #opponents > 1 then
        score = score + 10  -- Healer + DPS is strong
    end

    if classCount["ROGUE"] and classCount["MAGE"] then
        score = score + 8   -- Rogue + Mage sync well
    end

    return score
end

-- ===========================
-- PERFORMANCE ANALYSIS
-- ===========================

function MatchPredictor:GetRecentWinRate(matches)
    matches = matches or 10
    local history = ArenamasterDB.matchHistory or {}

    if #history == 0 then return 50 end

    local wins = 0
    local count = 0
    local start = math.max(1, #history - matches + 1)

    for i = start, #history do
        if history[i].result == "WIN" then
            wins = wins + 1
        end
        count = count + 1
    end

    return (wins / count) * 100
end

function MatchPredictor:GetOpponentPrediction(opponentName)
    local profile = AM.OpponentProfiler:GetProfile(opponentName)
    if not profile then
        return {
            name = opponentName,
            predictedOutcome = "UNKNOWN",
            confidence = 0,
            reasoning = "No profile data"
        }
    end

    local yourStats = {
        rating = ArenamasterDB.rating or 0,
        winrate = AM:GetWinrate()
    }

    local prediction = profile.winRate > yourStats.winrate and "LOSS" or "WIN"

    return {
        name = opponentName,
        predictedOutcome = prediction,
        winRateAgainstThem = profile.winRate,
        yourWinRate = yourStats.winrate,
        playstyle = profile.playstyle,
        confidence = profile.confidence,
        recommendation = AM.OpponentProfiler:GetCounterStrategy(opponentName)
    }
end

-- ===========================
-- DETAILED ANALYSIS
-- ===========================

function MatchPredictor:GetDetailedAnalysis()
    local probability = self:CalculateWinProbability()
    local yourRating = ArenamasterDB.rating or 0
    local recentWR = self:GetRecentWinRate(10)

    return {
        winProbability = probability,
        description = self:GetProbabilityDescription(probability),
        rating = yourRating,
        recentWinRate = recentWR,
        factors = {
            ratingAdvantage = yourRating > 0,
            recentMomentum = recentWR > 50,
            hasOpponentProfiles = true,
            teamComposition = "Analyzing...",
        }
    }
end

function MatchPredictor:GetProbabilityDescription(probability)
    if probability >= 80 then
        return "Excellent matchup - High win probability"
    elseif probability >= 65 then
        return "Good matchup - Above average win chance"
    elseif probability >= 55 then
        return "Slight advantage - Favorable conditions"
    elseif probability >= 45 then
        return "Close match - 50/50 outcome"
    elseif probability >= 35 then
        return "Slight disadvantage - Challenging matchup"
    elseif probability >= 20 then
        return "Difficult matchup - Low win probability"
    else
        return "Unfavorable matchup - Very challenging"
    end
end

-- ===========================
-- PRINTING & DEBUG
-- ===========================

function MatchPredictor:PrintMatchAnalysis()
    local analysis = self:GetDetailedAnalysis()

    print("|cff00ffff╔═══════════════════════════════════╗|r")
    print("|cff00ffff║   MATCH WIN PROBABILITY ANALYSIS   ║|r")
    print("|cff00ffff╠═══════════════════════════════════╣|r")

    local color = analysis.winProbability >= 65 and "|cff00ff00" or
                  analysis.winProbability >= 50 and "|cffff8800" or
                  "|cffff0000"

    print(string.format("|cff00ffff║ Win Probability: %s%d%%|r", color, analysis.winProbability))
    print("|cff00ffff║ " .. analysis.description .. "|r")
    print("|cff00ffff╠═══════════════════════════════════╣|r")
    print(string.format("|cff00ffff║ Your Rating: %d|r", analysis.rating))
    print(string.format("|cff00ffff║ Recent Win Rate (10): %d%%|r", math.floor(analysis.recentWinRate)))
    print("|cff00ffff╠═══════════════════════════════════╣|r")
    print("|cff00ffff║ OPPONENT BREAKDOWN|r")

    -- Add opponent info if available
    if AM.ThreatDetector then
        local threats = AM.ThreatDetector:GetAllThreats()
        for i = 1, math.min(3, #threats) do
            local threat = threats[i]
            local opponentPred = self:GetOpponentPrediction(threat.name)
            local predColor = opponentPred.predictedOutcome == "WIN" and "|cff00ff00" or "|cffff0000"
            print(string.format("|cff00ffff║ %s %s (%s) - %s%s|r",
                threat.name, threat.class, opponentPred.playstyle, predColor, opponentPred.predictedOutcome))
        end
    end

    print("|cff00ffff╚═══════════════════════════════════╝|r")
end

function MatchPredictor:PrintOpponentAnalysis(opponentName)
    local prediction = self:GetOpponentPrediction(opponentName)

    print("|cff00ffff═══════════════════════════════════|r")
    print("|cff00ffff" .. prediction.name .. "|r")
    print("|cff00ffff═══════════════════════════════════|r")

    if prediction.confidence > 0 then
        print("Prediction: " .. prediction.predictedOutcome)
        print("Your win rate vs them: " .. prediction.winRateAgainstThem .. "%")
        print("Confidence: " .. prediction.confidence .. "%")
        print("Playstyle: " .. prediction.playstyle)

        if prediction.recommendation then
            print("\nRecommendations:")
            for _, rec in ipairs(prediction.recommendation.recommendations) do
                print("  • " .. rec)
            end
        end
    else
        print("Not enough data - First encounter")
    end

    print("|cff00ffff═══════════════════════════════════|r")
end

-- Export
AM.MatchPredictor = MatchPredictor

return MatchPredictor
