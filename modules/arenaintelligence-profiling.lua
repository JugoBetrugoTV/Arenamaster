-- Arenamaster: Advanced Opponent Profiling Module
-- Machine learning-inspired opponent analysis and playstyle classification

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ArenaIntelligenceProfiler = Arenamaster:NewModule("ArenaIntelligenceProfiler", "AceEvent-3.0")

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaIntelligenceProfiler:OnInitialize()
	if not Arenamaster.db.profile.opponentProfiles then
		Arenamaster.db.profile.opponentProfiles = {}
	end
end

function ArenaIntelligenceProfiler:OnEnable()
	self:RegisterEvent("ARENA_MATCH_END")
end

-- ===========================
-- OPPONENT PROFILE SYSTEM
-- ===========================

function ArenaIntelligenceProfiler:CreateOrUpdateProfile(playerName, matchData)
	if not playerName or not matchData then return end

	local profile = Arenamaster.db.profile.opponentProfiles[playerName] or {
		name = playerName,
		encounters = 0,
		wins = 0,
		losses = 0,
		avgDamage = 0,
		avgHealing = 0,
		avgCCs = 0,
		playstyles = {},
		lastEncounter = 0,
		commonCombo = {},
		interruptPatterns = {},
		defensePatterns = {},
	}

	-- Update basic stats
	profile.encounters = profile.encounters + 1
	profile.lastEncounter = GetTime()

	if matchData.won then
		profile.wins = profile.wins + 1
	else
		profile.losses = profile.losses + 1
	end

	-- Update averages
	profile.avgDamage = ((profile.avgDamage * (profile.encounters - 1)) + (matchData.damageDealt or 0)) / profile.encounters
	profile.avgHealing = ((profile.avgHealing * (profile.encounters - 1)) + (matchData.healingDone or 0)) / profile.encounters
	profile.avgCCs = ((profile.avgCCs * (profile.encounters - 1)) + (matchData.ccsApplied or 0)) / profile.encounters

	-- Classify playstyle
	self:ClassifyPlaystyle(profile, matchData)

	-- Analyze interrupts and defensive patterns
	self:AnalyzePatterns(profile, matchData)

	-- Store profile
	Arenamaster.db.profile.opponentProfiles[playerName] = profile

	return profile
end

function ArenaIntelligenceProfiler:ClassifyPlaystyle(profile, matchData)
	-- Classify opponent playstyle based on metrics
	-- Possible classifications: Aggressive, Defensive, Balanced, Support, Burst

	local classification = {}

	-- Damage-based classification
	if (matchData.damageDealt or 0) > 50000 then
		classification.offensive = "Very High"
	elseif (matchData.damageDealt or 0) > 30000 then
		classification.offensive = "High"
	elseif (matchData.damageDealt or 0) > 15000 then
		classification.offensive = "Moderate"
	else
		classification.offensive = "Low"
	end

	-- Healing-based classification
	if (matchData.healingDone or 0) > 50000 then
		classification.support = "Very High"
	elseif (matchData.healingDone or 0) > 20000 then
		classification.support = "High"
	else
		classification.support = "Low"
	end

	-- CC-based classification
	if (matchData.ccsApplied or 0) > 8 then
		classification.control = "Very High"
	elseif (matchData.ccsApplied or 0) > 5 then
		classification.control = "High"
	else
		classification.control = "Moderate"
	end

	-- Overall playstyle
	local offScore = classification.offensive == "Very High" and 3 or (classification.offensive == "High" and 2 or 1)
	local supScore = classification.support == "Very High" and 3 or (classification.support == "High" and 2 or 1)
	local ctlScore = classification.control == "Very High" and 3 or (classification.control == "High" and 2 or 1)

	if offScore >= supScore and offScore >= ctlScore then
		classification.playstyle = "Aggressive"
	elseif supScore >= ctlScore then
		classification.playstyle = "Support"
	elseif ctlScore > offScore then
		classification.playstyle = "Control"
	else
		classification.playstyle = "Balanced"
	end

	table.insert(profile.playstyles, classification)

	-- Keep last 20 classifications
	if #profile.playstyles > 20 then
		table.remove(profile.playstyles, 1)
	end
end

function ArenaIntelligenceProfiler:AnalyzePatterns(profile, matchData)
	-- Analyze interrupt and defense patterns
	-- Look for tendencies in how opponent responds to threats

	if not matchData.events then return end

	local interruptCount = 0
	local defensiveCount = 0
	local offensiveCount = 0

	for _, event in ipairs(matchData.events) do
		if event.type == "interrupt" then
			interruptCount = interruptCount + 1
		elseif event.type == "cc" then
			defensiveCount = defensiveCount + 1
		elseif event.type == "damage" then
			offensiveCount = offensiveCount + 1
		end
	end

	-- Store pattern
	table.insert(profile.interruptPatterns, interruptCount)
	table.insert(profile.defensePatterns, defensiveCount)

	-- Keep last 15 patterns
	if #profile.interruptPatterns > 15 then
		table.remove(profile.interruptPatterns, 1)
	end
	if #profile.defensePatterns > 15 then
		table.remove(profile.defensePatterns, 1)
	end
end

-- ===========================
-- PROFILE ANALYSIS
-- ===========================

function ArenaIntelligenceProfiler:GetOpponentProfile(playerName)
	return Arenamaster.db.profile.opponentProfiles[playerName]
end

function ArenaIntelligenceProfiler:GetPredominantPlaystyle(playerName)
	local profile = self:GetOpponentProfile(playerName)
	if not profile or #profile.playstyles == 0 then
		return "Unknown"
	end

	local styleCount = {}
	for _, style in ipairs(profile.playstyles) do
		styleCount[style.playstyle] = (styleCount[style.playstyle] or 0) + 1
	end

	local maxCount = 0
	local dominantStyle = "Balanced"
	for style, count in pairs(styleCount) do
		if count > maxCount then
			maxCount = count
			dominantStyle = style
		end
	end

	return dominantStyle
end

function ArenaIntelligenceProfiler:GetAverageInterruptRate(playerName)
	local profile = self:GetOpponentProfile(playerName)
	if not profile or #profile.interruptPatterns == 0 then
		return 0
	end

	local total = 0
	for _, count in ipairs(profile.interruptPatterns) do
		total = total + count
	end

	return math.floor(total / #profile.interruptPatterns)
end

function ArenaIntelligenceProfiler:GetWinRateVsOpponent(playerName)
	local profile = self:GetOpponentProfile(playerName)
	if not profile or profile.encounters == 0 then
		return 0
	end

	return math.floor((profile.wins / profile.encounters) * 100)
end

function ArenaIntelligenceProfiler:GetOpponentStrengths(playerName)
	local profile = self:GetOpponentProfile(playerName)
	if not profile then
		return {}
	end

	local strengths = {}

	-- Identify strength areas
	if profile.avgDamage > 40000 then
		table.insert(strengths, "High Damage Output")
	end

	if profile.avgHealing > 30000 then
		table.insert(strengths, "Strong Healing")
	end

	if profile.avgCCs > 6 then
		table.insert(strengths, "Crowd Control")
	end

	-- Check recent playstyle
	if #profile.playstyles > 0 then
		local recentStyle = profile.playstyles[#profile.playstyles]
		if recentStyle.offensive == "Very High" then
			table.insert(strengths, "Aggressive Offense")
		end
	end

	return strengths
end

function ArenaIntelligenceProfiler:GetOpponentWeaknesses(playerName)
	local profile = self:GetOpponentProfile(playerName)
	if not profile then
		return {}
	end

	local weaknesses = {}

	-- Identify weakness areas
	if profile.avgHealing < 10000 then
		table.insert(weaknesses, "Limited Healing")
	end

	if profile.avgCCs < 3 then
		table.insert(weaknesses, "Poor CC Control")
	end

	-- Check for defensive patterns
	if #profile.defensePatterns > 0 then
		local avgDefense = 0
		for _, count in ipairs(profile.defensePatterns) do
			avgDefense = avgDefense + count
		end
		avgDefense = avgDefense / #profile.defensePatterns

		if avgDefense < 3 then
			table.insert(weaknesses, "Defensive Gaps")
		end
	end

	return weaknesses
end

-- ===========================
-- RECOMMENDATION ENGINE
-- ===========================

function ArenaIntelligenceProfiler:GetCounterRecommendations(playerName)
	local profile = self:GetOpponentProfile(playerName)
	if not profile then
		return {}
	end

	local recommendations = {}

	-- Base recommendations on playstyle
	local playstyle = self:GetPredominantPlaystyle(playerName)

	if playstyle == "Aggressive" then
		table.insert(recommendations, "Focus on interrupts - opponent commits heavily to offense")
		table.insert(recommendations, "Use defensive cooldowns preemptively")
		table.insert(recommendations, "Burst when opponent commits spells")
	elseif playstyle == "Support" then
		table.insert(recommendations, "Pressure the opponent - they have limited offensive tools")
		table.insert(recommendations, "Focus on their healing target first")
		table.insert(recommendations, "Watch for support cooldowns")
	elseif playstyle == "Control" then
		table.insert(recommendations, "Expect heavy CC usage")
		table.insert(recommendations, "Have cleanse/dispel ready")
		table.insert(recommendations, "Play around their CC patterns")
	end

	-- Damage-based recommendations
	if profile.avgDamage > 50000 then
		table.insert(recommendations, "⚠️ HIGH THREAT: Stack defensive buffs")
	end

	-- Healing-based recommendations
	if profile.avgHealing > 40000 then
		table.insert(recommendations, "Opponent heals heavily - focus on burst windows")
	end

	return recommendations
end

-- ===========================
-- REPORTING
-- ===========================

function ArenaIntelligenceProfiler:PrintOpponentProfile(playerName)
	local profile = self:GetOpponentProfile(playerName)
	if not profile then
		print("|cffff0000No profile found for " .. playerName .. "|r")
		return
	end

	print("|cff00aiff════════════════════════════════════════|r")
	print("|cff00aiff       OPPONENT PROFILE: " .. playerName .. "|r")
	print("|cff00aiff════════════════════════════════════════|r")

	print("|cff4dabf7Statistics:|r")
	print("  Encounters: " .. profile.encounters)
	print("  Win Rate: " .. self:GetWinRateVsOpponent(playerName) .. "%")
	print("  Avg Damage: " .. math.floor(profile.avgDamage))
	print("  Avg Healing: " .. math.floor(profile.avgHealing))
	print("  Avg CCs: " .. math.floor(profile.avgCCs))

	print("|cff4dabf7Playstyle:|r")
	local playstyle = self:GetPredominantPlaystyle(playerName)
	print("  Dominant: " .. playstyle)

	local strengths = self:GetOpponentStrengths(playerName)
	if #strengths > 0 then
		print("|cff4dabf7Strengths:|r")
		for _, strength in ipairs(strengths) do
			print("  • " .. strength)
		end
	end

	local weaknesses = self:GetOpponentWeaknesses(playerName)
	if #weaknesses > 0 then
		print("|cff4dabf7Weaknesses:|r")
		for _, weakness in ipairs(weaknesses) do
			print("  • " .. weakness)
		end
	end

	local recommendations = self:GetCounterRecommendations(playerName)
	if #recommendations > 0 then
		print("|cff4dabf7Recommendations:|r")
		for _, rec in ipairs(recommendations) do
			print("  • " .. rec)
		end
	end
end

function ArenaIntelligenceProfiler:PrintAllProfiles()
	local profiles = Arenamaster.db.profile.opponentProfiles or {}
	if next(profiles) == nil then
		print("No opponent profiles recorded yet")
		return
	end

	print("|cff00aiff════════════════════════════════════════|r")
	print("|cff00aiff      OPPONENT PROFILES SUMMARY         |r")
	print("|cff00aiff════════════════════════════════════════|r")

	for playerName, profile in pairs(profiles) do
		local playstyle = self:GetPredominantPlaystyle(playerName)
		local winRate = self:GetWinRateVsOpponent(playerName)
		print("|cff4dabf7" .. playerName .. "|r - " .. playstyle .. " (" .. winRate .. "% WR, " .. profile.encounters .. " encounters)")
	end
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function ArenaIntelligenceProfiler:ARENA_MATCH_END()
	-- Update opponent profiles with match data
	local ArenaIntelligenceStats = Arenamaster:GetModule("ArenaIntelligenceStats")
	if not ArenaIntelligenceStats then return end

	local history = Arenamaster.db.profile.matchHistory or {}
	if #history == 0 then return end

	local latestMatch = history[1]
	if not latestMatch then return end

	-- Would need to identify opponents from combat log
	-- For now, profile updates would be triggered manually or via party tracking
end
