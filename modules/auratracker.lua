-- Arenamaster: Aura Tracker Module
-- Tracks enemy cooldowns, buffs, debuffs with visual countdown

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local AuraTracker = Arenamaster:NewModule("AuraTracker", "AceEvent-3.0", "AceTimer-3.0")

local IMPORTANT_ABILITIES = {
	-- Defensive
	["Divine Shield"] = {duration = 12, type = "defensive"},
	["Ice Block"] = {duration = 10, type = "defensive"},
	["Power Word: Shield"] = {duration = 15, type = "defensive"},
	["Unending Resolve"] = {duration = 8, type = "defensive"},

	-- Offensive CDs
	["Bloodlust"] = {duration = 40, type = "offensive"},
	["Time Warp"] = {duration = 40, type = "offensive"},
	["Heroism"] = {duration = 40, type = "offensive"},
	["Avatar"] = {duration = 20, type = "offensive"},

	-- CC
	["Stun"] = {duration = 4, type = "cc"},
	["Freeze"] = {duration = 4, type = "cc"},
	["Polymorph"] = {duration = 60, type = "cc"},
	["Hex"] = {duration = 60, type = "cc"},
}

local trackedAuras = {}

function AuraTracker:OnInitialize()
	trackedAuras = {}
end

function AuraTracker:OnEnable()
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
end

function AuraTracker:TrackAura(unit, auraName, duration)
	if not trackedAuras[unit] then
		trackedAuras[unit] = {}
	end

	trackedAuras[unit][auraName] = {
		startTime = GetTime(),
		duration = duration,
		endTime = GetTime() + duration,
		active = true
	}
end

function AuraTracker:GetTrackedAuras(unit)
	if not trackedAuras[unit] then
		return {}
	end

	local result = {}
	local currentTime = GetTime()

	for auraName, data in pairs(trackedAuras[unit]) do
		local remaining = data.endTime - currentTime
		if remaining > 0 then
			table.insert(result, {
				name = auraName,
				remaining = remaining,
				duration = data.duration
			})
		end
	end

	return result
end

function AuraTracker:UNIT_AURA(event, unit)
	-- Process unit auras
	if string.find(unit, "^arena%d$") then
		-- Update tracked auras for arena units
	end
end

function AuraTracker:ARENA_MATCH_START()
	trackedAuras = {}
	Arenamaster:PrintDebug("Aura tracker started")
end

function AuraTracker:ARENA_MATCH_END()
	trackedAuras = {}
end
