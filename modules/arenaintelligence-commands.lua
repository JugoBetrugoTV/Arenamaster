-- Arenamaster: Arena Intelligence Commands Module
-- Provides slash commands for accessing Arena Intelligence features

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ArenaIntelligenceCommands = Arenamaster:NewModule("ArenaIntelligenceCommands", "AceEvent-3.0")

local ArenaIntelligence = Arenamaster:GetModule("ArenaIntelligence")
local ArenaIntelligenceSummary = Arenamaster:GetModule("ArenaIntelligenceSummary")

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaIntelligenceCommands:OnInitialize()
	-- Register commands with main addon
end

function ArenaIntelligenceCommands:OnEnable()
	-- Commands will be registered by main Arenamaster module
end

-- ===========================
-- COMMAND HANDLERS
-- ===========================

function ArenaIntelligenceCommands:HandleDRCommand(args)
	if not ArenaIntelligence then
		print("|cffff0000Arena Intelligence module not loaded|r")
		return
	end

	local target = args or "all"

	if target == "all" then
		ArenaIntelligence:PrintArenaStats()
	else
		-- Print specific unit DR
		local unit = target:lower()
		if not UnitExists(unit) then
			print("|cffff0000Invalid target: " .. target .. "|r")
			return
		end

		print("|cff00aiff════════════════════════════════════════|r")
		print("|cff00aiff DR Status: " .. UnitName(unit) .. "|r")
		print("|cff00aiff════════════════════════════════════════|r")

		for _, chainType in ipairs({"stun", "root", "silence", "disorient", "fear", "slow"}) do
			local status = ArenaIntelligence:GetDRStatus(unit, chainType)
			if status and status.applications > 0 then
				print("|cff4dabf7" .. chainType .. ":|r " .. status.percentage .. " (" .. status.applications .. " applications)")
			end
		end
	end
end

function ArenaIntelligenceCommands:HandleThreatCommand(args)
	if not ArenaIntelligence then
		print("|cffff0000Arena Intelligence module not loaded|r")
		return
	end

	print("|cff00aiff════════════════════════════════════════|r")
	print("|cff00aiff THREAT ASSESSMENT|r")
	print("|cff00aiff════════════════════════════════════════|r")

	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) then
			local threat = ArenaIntelligence:CalculateAdvancedThreat(unit)
			local name = UnitName(unit)

			print("|cff4dabf7" .. name .. ":|r " .. threat.percentage .. "% threat")
			print("  Health: " .. math.floor(threat.factors.health) .. "%")
			print("  Offensive: " .. threat.factors.offensive .. "%")
			print("  Defensive: " .. threat.factors.defensive .. "%")
			print("  Class: " .. threat.factors.classScore .. "%")
			print("  Distance: " .. threat.factors.distance .. "%")
		end
	end
end

function ArenaIntelligenceCommands:HandleInterruptCommand(args)
	if not ArenaIntelligence then
		print("|cffff0000Arena Intelligence module not loaded|r")
		return
	end

	print("|cff00aiff════════════════════════════════════════|r")
	print("|cff00aiff INTERRUPT PREDICTIONS|r")
	print("|cff00aiff════════════════════════════════════════|r")

	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) then
			local name = UnitName(unit)
			print("|cff4dabf7" .. name .. "|r")

			for _, spellName in ipairs({"Kick", "Counterspell", "Pummel"}) do
				local prediction = ArenaIntelligence:PredictInterruptAvailability(unit, spellName)
				if prediction then
					local status = prediction.available and "|cff00ff00✓|r" or "|cffff0000✗|r"
					local time = math.ceil(prediction.remainingTime)
					local confidence = math.floor(prediction.confidence * 100)
					print("  " .. status .. " " .. spellName .. ": " .. time .. "s (confidence: " .. confidence .. "%)")
				end
			end
		end
	end
end

function ArenaIntelligenceCommands:HandleStatsCommand(args)
	if not ArenaIntelligenceSummary then
		print("|cffff0000Arena Intelligence Summary module not loaded|r")
		return
	end

	local subcommand = args:lower() or "match"

	if subcommand == "match" or subcommand == "" then
		ArenaIntelligenceSummary:PrintMatchSummary()
	elseif subcommand == "opponents" or subcommand == "all" then
		ArenaIntelligenceSummary:PrintAllOpponentsSummary()
	elseif subcommand == "report" then
		ArenaIntelligenceSummary:GenerateMatchReport()
	else
		print("|cffccccccSubcommands: match, opponents, report|r")
	end
end

function ArenaIntelligenceCommands:HandleIntelligenceCommand(args)
	local subcommand, subargs = self:ParseCommand(args)

	if subcommand == "dr" or subcommand == "diminishing" then
		self:HandleDRCommand(subargs)
	elseif subcommand == "threat" then
		self:HandleThreatCommand(subargs)
	elseif subcommand == "interrupt" or subcommand == "int" then
		self:HandleInterruptCommand(subargs)
	elseif subcommand == "stats" or subcommand == "stat" then
		self:HandleStatsCommand(subargs)
	elseif subcommand == "help" or subcommand == "" then
		self:PrintIntelligenceHelp()
	else
		print("|cffff0000Unknown command: " .. subcommand .. "|r")
		self:PrintIntelligenceHelp()
	end
end

-- ===========================
-- HELP & DISPLAY
-- ===========================

function ArenaIntelligenceCommands:PrintIntelligenceHelp()
	print("|cff00aiff════════════════════════════════════════|r")
	print("|cff00aiff   ARENA INTELLIGENCE COMMANDS          |r")
	print("|cff00aiff════════════════════════════════════════|r")
	print("")
	print("|cff4dabf7Diminishing Returns:|r")
	print("  /ai dr - Show all DR status")
	print("  /ai dr arena1 - Show specific unit DR")
	print("")
	print("|cff4dabf7Threat Assessment:|r")
	print("  /ai threat - Show all opponents threat levels")
	print("")
	print("|cff4dabf7Interrupt Predictions:|r")
	print("  /ai interrupt - Show interrupt availability predictions")
	print("")
	print("|cff4dabf7Match Statistics:|r")
	print("  /ai stats - Show current match stats")
	print("  /ai stats opponents - Show all opponent intelligence")
	print("  /ai stats report - Generate full match report")
	print("")
end

-- ===========================
-- UTILITY FUNCTIONS
-- ===========================

function ArenaIntelligenceCommands:ParseCommand(input)
	if not input or input == "" then
		return "", ""
	end

	local subcommand, subargs = input:match("^(%w+)%s*(.*)")
	return (subcommand or ""):lower(), (subargs or ""):trim()
end

-- ===========================
-- PUBLIC API FOR MAIN MODULE
-- ===========================

function ArenaIntelligenceCommands:RegisterCommands()
	-- This is called by the main Arenamaster module to register commands
	if not Arenamaster.RegisterCommand then
		return
	end

	Arenamaster:RegisterCommand("ai", "Arena Intelligence", function(args)
		self:HandleIntelligenceCommand(args)
	end)

	Arenamaster:RegisterCommand("dr", "Show DR Status", function(args)
		self:HandleDRCommand(args)
	end)

	Arenamaster:RegisterCommand("threat", "Show Threat Assessment", function(args)
		self:HandleThreatCommand(args)
	end)

	Arenamaster:RegisterCommand("int", "Show Interrupt Predictions", function(args)
		self:HandleInterruptCommand(args)
	end)

	Arenamaster:RegisterCommand("aistats", "Show Arena Stats", function(args)
		self:HandleStatsCommand(args)
	end)

	Arenamaster:PrintDebug("Arena Intelligence commands registered")
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function ArenaIntelligenceCommands:OnEnable()
	if Arenamaster and type(Arenamaster.RegisterCommand) == "function" then
		self:RegisterCommands()
	end
end
