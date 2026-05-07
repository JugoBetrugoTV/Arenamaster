-- Arenamaster: Arena Intelligence Summary & Dashboard Integration
-- Comprehensive display and reporting of all Arena Intelligence data

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ArenaIntelligenceSummary = Arenamaster:NewModule("ArenaIntelligenceSummary", "AceEvent-3.0", "AceTimer-3.0")

local Design = Arenamaster:GetModule("Design")
local ArenaIntelligence = Arenamaster:GetModule("ArenaIntelligence")

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaIntelligenceSummary:OnInitialize()
	-- Initialize summary data structures
end

function ArenaIntelligenceSummary:OnEnable()
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
	self:ScheduleRepeatingTimer("UpdateSummaryData", 1.0)
end

-- ===========================
-- SUMMARY DATA GENERATION
-- ===========================

function ArenaIntelligenceSummary:GetMatchIntelligenceSummary()
	local stats = ArenaIntelligence:GetMatchStats()
	local duration = GetTime() - (stats.matchStartTime or 0)

	return {
		duration = duration,
		dps = ArenaIntelligence:GetDPS(),
		hps = ArenaIntelligence:GetHPS(),
		damageDealt = stats.damageDealt or 0,
		damageTaken = stats.damageTaken or 0,
		healingDone = stats.healingDone or 0,
		ccsApplied = stats.ccsApplied or 0,
		ccsReceived = stats.ccsReceived or 0,
		interruptsApplied = stats.interruptsApplied or 0,
		dispelsApplied = stats.dispelsApplied or 0,
		efficiency = self:CalculateEfficiency(stats),
	}
end

function ArenaIntelligenceSummary:GetOpponentIntelligence(unit)
	if not ArenaIntelligence then return nil end

	local summary = {
		unit = unit,
		name = UnitName(unit),
		health = UnitHealth(unit),
		maxHealth = UnitHealthMax(unit),
		healthPercent = (UnitHealth(unit) / UnitHealthMax(unit)) * 100,
		mana = UnitMana(unit),
		maxMana = UnitManaMax(unit),
		manaPercent = (UnitMana(unit) / UnitManaMax(unit)) * 100,
		drStatus = {},
		threatScore = nil,
		interruptStatus = {},
	}

	-- Get DR status for all chains
	for _, chainType in ipairs({"stun", "silence", "root", "disorient", "fear", "slow"}) do
		local drStatus = ArenaIntelligence:GetDRStatus(unit, chainType)
		if drStatus then
			summary.drStatus[chainType] = drStatus
		end
	end

	-- Get threat score
	if ArenaIntelligence.CalculateAdvancedThreat then
		summary.threatScore = ArenaIntelligence:CalculateAdvancedThreat(unit)
	end

	-- Get interrupt status
	for _, spellName in ipairs({"Kick", "Counterspell", "Pummel"}) do
		local prediction = ArenaIntelligence:PredictInterruptAvailability(unit, spellName)
		if prediction then
			summary.interruptStatus[spellName] = prediction
		end
	end

	return summary
end

function ArenaIntelligenceSummary:GetAllOpponentIntelligence()
	local opponents = {}
	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) then
			opponents[unit] = self:GetOpponentIntelligence(unit)
		end
	end
	return opponents
end

function ArenaIntelligenceSummary:CalculateEfficiency(stats)
	-- Calculate combat efficiency (damage dealt vs healing received vs damage taken)
	local totalTaken = (stats.damageTaken or 0)
	if totalTaken == 0 then return 0 end

	local damageDealt = (stats.damageDealt or 0)
	local healingDone = (stats.healingDone or 0)

	-- Efficiency = (Damage Dealt + Healing Done) / Damage Taken
	local efficiency = (damageDealt + healingDone) / totalTaken
	return math.min(efficiency, 3.0)  -- Cap at 3.0 for display purposes
end

-- ===========================
-- SUMMARY DISPLAY FUNCTIONS
-- ===========================

function ArenaIntelligenceSummary:PrintMatchSummary()
	local summary = self:GetMatchIntelligenceSummary()

	print("|cff00aiff╔════════════════════════════════════════╗|r")
	print("|cff00aiff║     MATCH INTELLIGENCE SUMMARY        ║|r")
	print("|cff00aiff╚════════════════════════════════════════╝|r")

	-- Duration
	local minutes = math.floor(summary.duration / 60)
	local seconds = math.floor(summary.duration % 60)
	print("|cff4dabf7Duration:|r " .. minutes .. "m " .. seconds .. "s")

	-- Damage stats
	print("|cff4dabf7Damage:|r")
	print("  Dealt: " .. self:FormatNumber(summary.damageDealt) .. " (" .. summary.dps .. " DPS)")
	print("  Taken: " .. self:FormatNumber(summary.damageTaken))

	-- Healing stats
	print("|cff4dabf7Healing:|r")
	print("  Done: " .. self:FormatNumber(summary.healingDone) .. " (" .. summary.hps .. " HPS)")

	-- CC stats
	print("|cff4dabf7Control:|r")
	print("  CCs Applied: " .. summary.ccsApplied)
	print("  CCs Received: " .. summary.ccsReceived)
	print("  Interrupts: " .. summary.interruptsApplied)

	-- Efficiency
	local efficiencyPercent = math.floor(summary.efficiency * 100)
	print("|cff4dabf7Efficiency:|r " .. efficiencyPercent .. "%")
end

function ArenaIntelligenceSummary:PrintOpponentSummary(unit)
	local summary = self:GetOpponentIntelligence(unit)
	if not summary then
		print("No opponent at " .. unit)
		return
	end

	print("|cff00aiff════════════════════════════════════════|r")
	print("|cff00aiff " .. summary.name .. " - Intelligence Report|r")
	print("|cff00aiff════════════════════════════════════════|r")

	-- Health status
	local healthColor = self:GetHealthColor(summary.healthPercent)
	print("|cff4dabf7Health:|r |cff" .. healthColor .. summary.healthPercent .. "%|r (" .. self:FormatNumber(summary.health) .. "/" .. self:FormatNumber(summary.maxHealth) .. ")")

	-- Mana status
	if summary.maxMana > 0 then
		print("|cff4dabf7Mana:|r " .. summary.manaPercent .. "% (" .. summary.mana .. "/" .. summary.maxMana .. ")")
	end

	-- DR status
	if next(summary.drStatus) then
		print("|cff4dabf7Diminishing Returns:|r")
		for chain, status in pairs(summary.drStatus) do
			if status.applications > 0 then
				print("  " .. chain .. ": " .. status.percentage .. " (" .. status.applications .. " applications)")
			end
		end
	end

	-- Threat assessment
	if summary.threatScore then
		print("|cff4dabf7Threat Level:|r " .. summary.threatScore.percentage .. "%")
		print("  Health Factor: " .. math.floor(summary.threatScore.factors.health) .. "%")
		print("  Offensive CDs: " .. summary.threatScore.factors.offensive .. "%")
		print("  Defensive CDs: " .. summary.threatScore.factors.defensive .. "%")
	end

	-- Interrupt status
	if next(summary.interruptStatus) then
		print("|cff4dabf7Interrupt Status:|r")
		for spell, status in pairs(summary.interruptStatus) do
			local available = status.available and "|cff00ff00Available|r" or "|cffff0000Ready in " .. math.ceil(status.remainingTime) .. "s|r"
			print("  " .. spell .. ": " .. available)
		end
	end
end

function ArenaIntelligenceSummary:PrintAllOpponentsSummary()
	print("|cff00aiff╔════════════════════════════════════════╗|r")
	print("|cff00aiff║    ALL OPPONENTS INTELLIGENCE         ║|r")
	print("|cff00aiff╚════════════════════════════════════════╝|r")

	local opponents = self:GetAllOpponentIntelligence()
	for unit, summary in pairs(opponents) do
		if summary then
			print("")
			print("|cff4dabf7" .. summary.name .. "|r")
			print("  Health: " .. summary.healthPercent .. "%")

			-- Threat level
			if summary.threatScore then
				print("  Threat: " .. summary.threatScore.percentage .. "%")
			end

			-- DR summary
			local activeDRs = {}
			for chain, status in pairs(summary.drStatus) do
				if status.applications > 0 and status.reduction > 0 then
					table.insert(activeDRs, chain .. " " .. status.percentage)
				end
			end
			if #activeDRs > 0 then
				print("  DRs: " .. table.concat(activeDRs, ", "))
			end
		end
	end
end

-- ===========================
-- UPDATE TIMER
-- ===========================

function ArenaIntelligenceSummary:UpdateSummaryData()
	-- Called periodically to keep summary data fresh
	-- Used internally by other modules for real-time display
end

-- ===========================
-- UTILITY FUNCTIONS
-- ===========================

function ArenaIntelligenceSummary:FormatNumber(num)
	if num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	else
		return tostring(num)
	end
end

function ArenaIntelligenceSummary:GetHealthColor(percent)
	if percent >= 75 then
		return "00ff00"  -- Green
	elseif percent >= 50 then
		return "ffff00"  -- Yellow
	elseif percent >= 25 then
		return "ff8800"  -- Orange
	else
		return "ff0000"  -- Red
	end
end

-- ===========================
-- COMMAND HANDLERS
-- ===========================

function ArenaIntelligenceSummary:GenerateMatchReport()
	-- Called at match end to generate comprehensive report
	self:PrintMatchSummary()
	print("")
	self:PrintAllOpponentsSummary()
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function ArenaIntelligenceSummary:ARENA_MATCH_START()
	Arenamaster:PrintDebug("Arena Intelligence Summary system active")
end

function ArenaIntelligenceSummary:ARENA_MATCH_END()
	if Arenamaster.db.profile.debugMode then
		self:GenerateMatchReport()
	end
end
