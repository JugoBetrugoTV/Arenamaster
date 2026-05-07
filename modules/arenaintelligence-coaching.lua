-- Arenamaster: Real-Time Coaching and Recommendations Module
-- Live performance tips and strategic guidance during matches

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ArenaIntelligenceCoaching = Arenamaster:NewModule("ArenaIntelligenceCoaching", "AceEvent-3.0", "AceTimer-3.0")

local ArenaIntelligence = Arenamaster:GetModule("ArenaIntelligence")
local ArenaIntelligenceProfiler = Arenamaster:GetModule("ArenaIntelligenceProfiler")

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaIntelligenceCoaching:OnInitialize()
	if not Arenamaster.db.profile.coachingTips then
		Arenamaster.db.profile.coachingTips = {
			enabled = true,
			updateFrequency = 5,  -- seconds
			soundAlerts = true,
			chatAlerts = true,
		}
	end
end

function ArenaIntelligenceCoaching:OnEnable()
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
end

-- ===========================
-- PERFORMANCE MONITORING
-- ===========================

function ArenaIntelligenceCoaching:MonitorMatchPerformance()
	-- Real-time performance analysis and tips

	if not ArenaIntelligence then return end

	local stats = ArenaIntelligence:GetMatchStats()
	local currentDps = ArenaIntelligence:GetDPS()
	local currentHps = ArenaIntelligence:GetHPS()

	-- Check performance metrics
	self:CheckDamageOutput(currentDps, stats)
	self:CheckHealing(currentHps, stats)
	self:CheckDefensive(stats)
	self:CheckOffensive(stats)
	self:CheckCrowdControl(stats)
end

function ArenaIntelligenceCoaching:CheckDamageOutput(dps, stats)
	-- Monitor if player's damage output is sufficient
	if dps == 0 then return end

	-- Benchmark: Average player should do 5000+ DPS
	if dps < 3000 then
		self:AddCoachingTip("⚠️ Damage Output", "Your DPS is low (" .. dps .. "). Focus on maintaining offensive pressure.")
	elseif dps < 5000 then
		self:AddCoachingTip("📉 Damage Output", "DPS is below average (" .. dps .. "). Look for more casting windows.")
	end
end

function ArenaIntelligenceCoaching:CheckHealing(hps, stats)
	-- Monitor healing output (if applicable)
	if hps == 0 then return end

	-- If not a healer, HPS should be low
	if hps > 500 and (stats.ccsApplied or 0) < (stats.ccsReceived or 0) then
		self:AddCoachingTip("💚 Healing", "You're healing but taking more CCs than applying. Balance healing with offense.")
	end
end

function ArenaIntelligenceCoaching:CheckDefensive(stats)
	-- Monitor defensive positioning and cooldown usage
	local damageTaken = stats.damageTaken or 0
	local damageDealt = stats.damageDealt or 0

	if damageTaken > damageDealt * 2 then
		self:AddCoachingTip("🛡️ Defense", "Damage taken is very high. Use defensive cooldowns more preemptively.")
	end

	if (stats.ccsReceived or 0) > (stats.ccsApplied or 0) + 2 then
		self:AddCoachingTip("🔒 CC Pressure", "You're receiving too many CCs. Work on positioning and movement.")
	end
end

function ArenaIntelligenceCoaching:CheckOffensive(stats)
	-- Monitor offensive cooldown usage
	local damageDealt = stats.damageDealt or 0

	if damageDealt == 0 then
		self:AddCoachingTip("⚡ Offensive", "You haven't dealt any damage yet! Commit to offense.")
	end
end

function ArenaIntelligenceCoaching:CheckCrowdControl(stats)
	-- Monitor CC application
	local ccsApplied = stats.ccsApplied or 0
	local ccsReceived = stats.ccsReceived or 0

	if ccsApplied == 0 and ccsReceived > 2 then
		self:AddCoachingTip("🔗 CC Control", "Apply more crowd control to set up kills.")
	end

	if ccsApplied > 5 and ccsReceived == 0 then
		self:AddCoachingTip("📌 Positioning", "Good CC control! Maintain pressure.")
	end
end

-- ===========================
-- OPPONENT-SPECIFIC TIPS
-- ===========================

function ArenaIntelligenceCoaching:AnalyzeOpponentsBehavior()
	-- Analyze current opponent behavior and provide tips

	if not ArenaIntelligenceProfiler then return end

	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) then
			local name = UnitName(unit)
			if name then
				local profile = ArenaIntelligenceProfiler:GetOpponentProfile(name)
				if profile then
					self:AnalyzeOpponentPattern(name, profile)
				end
			end
		end
	end
end

function ArenaIntelligenceCoaching:AnalyzeOpponentPattern(opponentName, profile)
	-- Provide tips based on opponent's known patterns

	local weaknesses = ArenaIntelligenceProfiler:GetOpponentWeaknesses(opponentName)
	local strengths = ArenaIntelligenceProfiler:GetOpponentStrengths(opponentName)

	if #weaknesses > 0 then
		for _, weakness in ipairs(weaknesses) do
			if weakness == "Limited Healing" then
				self:AddCoachingTip("🎯 " .. opponentName, "This opponent has limited healing. Burst them down!")
			elseif weakness == "Poor CC Control" then
				self:AddCoachingTip("🎯 " .. opponentName, "This opponent struggles with CC. Control the match pace.")
			elseif weakness == "Defensive Gaps" then
				self:AddCoachingTip("🎯 " .. opponentName, "Watch for this opponent's defensive gaps and capitalize.")
			end
		end
	end

	if #strengths > 0 then
		for _, strength in ipairs(strengths) do
			if strength == "High Damage Output" then
				self:AddCoachingTip("⚠️ " .. opponentName, "This opponent deals high damage. Respect their burst!")
			elseif strength == "Strong Healing" then
				self:AddCoachingTip("⚠️ " .. opponentName, "This opponent heals well. Focus them down quickly.")
			end
		end
	end
end

-- ===========================
-- COACHING TIP SYSTEM
-- ===========================

local activeTips = {}

function ArenaIntelligenceCoaching:AddCoachingTip(title, message)
	-- Only add if not already showing
	for _, tip in ipairs(activeTips) do
		if tip.title == title then
			return  -- Tip already active
		end
	end

	local tip = {
		title = title,
		message = message,
		timestamp = GetTime(),
		displayed = false,
	}

	table.insert(activeTips, tip)

	-- Display tip
	if Arenamaster.db.profile.coachingTips.chatAlerts then
		print("|cff4dabf7[Coach]|r " .. title .. ": " .. message)
	end

	if Arenamaster.db.profile.coachingTips.soundAlerts then
		PlaySoundFile("Sound\\Interface\\Doodad\\Warforged Chest Open.wav", "Master")
	end
end

function ArenaIntelligenceCoaching:ClearExpiredTips()
	-- Remove tips older than 10 seconds
	local currentTime = GetTime()
	for i = #activeTips, 1, -1 do
		if currentTime - activeTips[i].timestamp > 10 then
			table.remove(activeTips, i)
		end
	end
end

function ArenaIntelligenceCoaching:GetActiveTips()
	self:ClearExpiredTips()
	return activeTips
end

-- ===========================
-- STRATEGIC ANALYSIS
-- ===========================

function ArenaIntelligenceCoaching:AnalyzeMatchFlow()
	-- Analyze how the match is progressing

	if not ArenaIntelligence then return end

	local stats = ArenaIntelligence:GetMatchStats()
	local dps = ArenaIntelligence:GetDPS()
	local duration = GetTime() - (stats.matchStartTime or 0)

	-- Analyze early/mid/late game
	if duration < 30 then
		-- Early game
		self:AnalyzeEarlyGame(stats, dps)
	elseif duration < 300 then
		-- Mid game
		self:AnalyzeMidGame(stats, dps)
	else
		-- Late game / extended
		self:AnalyzeLateGame(stats, dps)
	end
end

function ArenaIntelligenceCoaching:AnalyzeEarlyGame(stats, dps)
	-- Early game: Focus on setup and control
	if (stats.ccsApplied or 0) == 0 then
		self:AddCoachingTip("🎮 Early Game", "Establish control early. Start applying CCs!")
	end

	if dps < 1000 then
		self:AddCoachingTip("🎮 Early Game", "Build tempo. Get some damage in early.")
	end
end

function ArenaIntelligenceCoaching:AnalyzeMidGame(stats, dps)
	-- Mid game: Balance offense and defense
	if (stats.ccsReceived or 0) > 5 and (stats.ccsApplied or 0) < 3 then
		self:AddCoachingTip("🎮 Mid Game", "You're down on CC control. Push back and reestablish dominance.")
	end
end

function ArenaIntelligenceCoaching:AnalyzeLateGame(stats, dps)
	-- Late game: Close it out
	if (stats.damageDealt or 0) > 0 and (stats.ccsApplied or 0) > 0 then
		self:AddCoachingTip("🎮 Late Game", "Finish strong! You have momentum.")
	end
end

-- ===========================
-- TIMER-BASED MONITORING
-- ===========================

function ArenaIntelligenceCoaching:StartCoachingMonitor()
	if not Arenamaster.db.profile.coachingTips.enabled then return end

	-- Monitor every 5 seconds
	self:ScheduleRepeatingTimer(function()
		self:MonitorMatchPerformance()
		self:AnalyzeOpponentsBehavior()
		self:AnalyzeMatchFlow()
	end, Arenamaster.db.profile.coachingTips.updateFrequency)
end

function ArenaIntelligenceCoaching:StopCoachingMonitor()
	self:CancelAllTimers()
	activeTips = {}
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function ArenaIntelligenceCoaching:ARENA_MATCH_START()
	activeTips = {}
	self:StartCoachingMonitor()
	self:AddCoachingTip("🎮 Arena Started", "Let's win this! Focus on control and momentum.")
end

function ArenaIntelligenceCoaching:ARENA_MATCH_END()
	self:StopCoachingMonitor()
	self:PrintMatchCoachingReport()
end

-- ===========================
-- REPORTING
-- ===========================

function ArenaIntelligenceCoaching:PrintMatchCoachingReport()
	print("|cff00aiff════════════════════════════════════════|r")
	print("|cff00aiff     MATCH COACHING SUMMARY           |r")
	print("|cff00aiff════════════════════════════════════════|r")

	local stats = ArenaIntelligence and ArenaIntelligence:GetMatchStats() or {}

	print("|cff4dabf7Performance Highlights:|r")

	if (stats.ccsApplied or 0) > 5 then
		print("  ✓ Strong crowd control application")
	end

	if (stats.damageDealt or 0) > 50000 then
		print("  ✓ Solid damage output")
	end

	if (stats.ccsReceived or 0) < (stats.ccsApplied or 0) then
		print("  ✓ Won the CC control battle")
	end

	print("|cff4dabf7Areas for Improvement:|r")

	if (stats.ccsReceived or 0) > (stats.ccsApplied or 0) + 3 then
		print("  • Work on defensive positioning")
	end

	if (stats.damageDealt or 0) < 30000 then
		print("  • Look for more offensive windows")
	end

	if (stats.interruptsApplied or 0) == 0 then
		print("  • Practice interrupt timing")
	end
end

function ArenaIntelligenceCoaching:PrintActiveTips()
	if #activeTips == 0 then
		print("No active coaching tips")
		return
	end

	print("|cff00aiff Active Coaching Tips:|r")
	for _, tip in ipairs(activeTips) do
		print("  " .. tip.title .. ": " .. tip.message)
	end
end
