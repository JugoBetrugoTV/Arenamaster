-- Arenamaster: Advanced Arena Statistics Module
-- Enhanced statistics collection and historical tracking

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ArenaIntelligenceStats = Arenamaster:NewModule("ArenaIntelligenceStats", "AceEvent-3.0")

local ArenaIntelligence = Arenamaster:GetModule("ArenaIntelligence")

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaIntelligenceStats:OnInitialize()
	-- Initialize statistics database
	if not Arenamaster.db.profile.matchHistory then
		Arenamaster.db.profile.matchHistory = {}
	end
end

function ArenaIntelligenceStats:OnEnable()
	self:RegisterEvent("ARENA_MATCH_END")
end

-- ===========================
-- MATCH RECORDING
-- ===========================

function ArenaIntelligenceStats:RecordMatchStats()
	if not ArenaIntelligence then return end

	local stats = ArenaIntelligence:GetMatchStats()
	if not stats or stats.matchStartTime == 0 then return end

	local matchDuration = GetTime() - stats.matchStartTime
	local dps = ArenaIntelligence:GetDPS()
	local hps = ArenaIntelligence:GetHPS()
	local efficiency = self:CalculateEfficiency(stats)

	-- Create match record
	local matchRecord = {
		timestamp = GetTime(),
		duration = matchDuration,
		damageDealt = stats.damageDealt or 0,
		damageTaken = stats.damageTaken or 0,
		healingDone = stats.healingDone or 0,
		dps = dps,
		hps = hps,
		ccsApplied = stats.ccsApplied or 0,
		ccsReceived = stats.ccsReceived or 0,
		interruptsApplied = stats.interruptsApplied or 0,
		dispelsApplied = stats.dispelsApplied or 0,
		efficiency = efficiency,
		won = false,  -- Would be determined from actual match result
		rating = Arenamaster.db.profile.currentRating or 1500,
		eventCount = stats.events and #stats.events or 0,
	}

	-- Store in history
	table.insert(Arenamaster.db.profile.matchHistory, 1, matchRecord)

	-- Keep last 100 matches
	if #Arenamaster.db.profile.matchHistory > 100 then
		table.remove(Arenamaster.db.profile.matchHistory)
	end

	if Arenamaster.db.profile.debugMode then
		Arenamaster:PrintDebug("Match recorded: " .. string.format("%.1f DPS, %.1f HPS, Efficiency: %.1f", dps, hps, efficiency))
	end
end

function ArenaIntelligenceStats:CalculateEfficiency(stats)
	-- Efficiency = (Damage Dealt + Healing Done) / Damage Taken
	local totalTaken = (stats.damageTaken or 0)
	if totalTaken == 0 then return 0 end

	local damageDealt = (stats.damageDealt or 0)
	local healingDone = (stats.healingDone or 0)

	local efficiency = (damageDealt + healingDone) / totalTaken
	return math.min(efficiency, 5.0)
end

-- ===========================
-- STATISTICS CALCULATIONS
-- ===========================

function ArenaIntelligenceStats:GetAverageStats()
	local history = Arenamaster.db.profile.matchHistory or {}
	if #history == 0 then
		return {
			matches = 0,
			avgDps = 0,
			avgHps = 0,
			avgEfficiency = 0,
			totalDamage = 0,
			totalHealing = 0,
		}
	end

	local totalDps = 0
	local totalHps = 0
	local totalEfficiency = 0
	local totalDamage = 0
	local totalHealing = 0

	for _, match in ipairs(history) do
		totalDps = totalDps + (match.dps or 0)
		totalHps = totalHps + (match.hps or 0)
		totalEfficiency = totalEfficiency + (match.efficiency or 0)
		totalDamage = totalDamage + (match.damageDealt or 0)
		totalHealing = totalHealing + (match.healingDone or 0)
	end

	return {
		matches = #history,
		avgDps = math.floor(totalDps / #history),
		avgHps = math.floor(totalHps / #history),
		avgEfficiency = math.floor((totalEfficiency / #history) * 100) / 100,
		totalDamage = totalDamage,
		totalHealing = totalHealing,
	}
end

function ArenaIntelligenceStats:GetWinRate()
	local history = Arenamaster.db.profile.matchHistory or {}
	if #history == 0 then return 0 end

	local wins = 0
	for _, match in ipairs(history) do
		if match.won then
			wins = wins + 1
		end
	end

	return math.floor((wins / #history) * 100)
end

function ArenaIntelligenceStats:GetRatingProgression()
	local history = Arenamaster.db.profile.matchHistory or {}
	if #history == 0 then return {} end

	local progression = {}
	for i = #history, 1, -1 do
		table.insert(progression, history[i].rating)
	end

	return progression
end

function ArenaIntelligenceStats:GetRatingTrend()
	local progression = self:GetRatingProgression()
	if #progression < 2 then return 0 end

	-- Calculate average rating change per match
	local firstRating = progression[1]
	local lastRating = progression[#progression]
	local ratingChange = lastRating - firstRating
	local trend = ratingChange / (#progression - 1)

	return math.floor(trend * 100) / 100
end

function ArenaIntelligenceStats:GetTrendDirection()
	local trend = self:GetRatingTrend()

	if trend > 10 then
		return "📈 Strong Uptrend"
	elseif trend > 0 then
		return "📊 Slight Uptrend"
	elseif trend > -10 then
		return "📉 Slight Downtrend"
	else
		return "📉 Strong Downtrend"
	end
end

-- ===========================
-- PERFORMANCE BENCHMARKS
-- ===========================

function ArenaIntelligenceStats:GetPeakPerformance()
	local history = Arenamaster.db.profile.matchHistory or {}
	if #history == 0 then
		return {
			peakDps = 0,
			peakHps = 0,
			bestEfficiency = 0,
			peakDamage = 0,
		}
	end

	local peakDps = 0
	local peakHps = 0
	local bestEfficiency = 0
	local peakDamage = 0

	for _, match in ipairs(history) do
		if (match.dps or 0) > peakDps then peakDps = match.dps end
		if (match.hps or 0) > peakHps then peakHps = match.hps end
		if (match.efficiency or 0) > bestEfficiency then bestEfficiency = match.efficiency end
		if (match.damageDealt or 0) > peakDamage then peakDamage = match.damageDealt end
	end

	return {
		peakDps = peakDps,
		peakHps = peakHps,
		bestEfficiency = bestEfficiency,
		peakDamage = peakDamage,
	}
end

-- ===========================
-- DETAILED REPORTING
-- ===========================

function ArenaIntelligenceStats:PrintDetailedReport()
	local avgStats = self:GetAverageStats()
	local peakStats = self:GetPeakPerformance()
	local trend = self:GetTrendDirection()
	local winrate = self:GetWinRate()

	print("|cff00aiff╔════════════════════════════════════════╗|r")
	print("|cff00aiff║    DETAILED ARENA STATISTICS REPORT    ║|r")
	print("|cff00aiff╚════════════════════════════════════════╝|r")

	print("|cff4dabf7Match History:|r")
	print("  Matches: " .. avgStats.matches)
	print("  Win Rate: " .. winrate .. "%")

	print("|cff4dabf7Performance Averages:|r")
	print("  Avg DPS: " .. avgStats.avgDps)
	print("  Avg HPS: " .. avgStats.avgHps)
	print("  Avg Efficiency: " .. avgStats.avgEfficiency)

	print("|cff4dabf7Peak Performance:|r")
	print("  Peak DPS: " .. peakStats.peakDps)
	print("  Peak HPS: " .. peakStats.peakHps)
	print("  Best Efficiency: " .. peakStats.bestEfficiency)
	print("  Peak Damage: " .. self:FormatNumber(peakStats.peakDamage))

	print("|cff4dabf7Rating Progression:|r")
	print("  Trend: " .. trend)
	print("  Rate: " .. self:GetRatingTrend() .. " per match")

	print("|cff4dabf7Cumulative Stats:|r")
	print("  Total Damage: " .. self:FormatNumber(avgStats.totalDamage))
	print("  Total Healing: " .. self:FormatNumber(avgStats.totalHealing))
end

function AremaIntelligenceStats:PrintLast10Matches()
	local history = Arenamaster.db.profile.matchHistory or {}
	if #history == 0 then
		print("No match history available")
		return
	end

	print("|cff00aiff╔════════════════════════════════════════╗|r")
	print("|cff00aiff║      LAST 10 MATCHES SUMMARY          ║|r")
	print("|cff00aiff╚════════════════════════════════════════╝|r")

	local count = 0
	for i = 1, math.min(10, #history) do
		local match = history[i]
		count = count + 1

		local result = match.won and "|cff00ff00WIN|r" or "|cffff0000LOSS|r"
		print(string.format("%d. %s - DPS: %d, HPS: %d, Eff: %.1f", count, result, match.dps, match.hps, match.efficiency))
	end
end

-- ===========================
-- UTILITY FUNCTIONS
-- ===========================

function ArenaIntelligenceStats:FormatNumber(num)
	if num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	else
		return tostring(num)
	end
end

function ArenaIntelligenceStats:ExportStats()
	local stats = {
		averageStats = self:GetAverageStats(),
		peakPerformance = self:GetPeakPerformance(),
		ratingTrend = self:GetRatingTrend(),
		trendDirection = self:GetTrendDirection(),
		winRate = self:GetWinRate(),
		matchHistory = Arenamaster.db.profile.matchHistory,
	}

	return stats
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function ArenaIntelligenceStats:ARENA_MATCH_END()
	self:RecordMatchStats()
	if Arenamaster.db.profile.debugMode then
		self:PrintDetailedReport()
	end
end
