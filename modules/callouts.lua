-- Arenamaster: Smart Visual Callouts Module
-- Zeigt wichtige Infos visuell auf dem Bildschirm

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local SmartCallouts = Arenamaster:NewModule("Callouts", "AceEvent-3.0", "AceTimer-3.0")

local calloutFrames = {}
local activeCallouts = {}

local config = {
	enabled = true,
	showCallouts = true,
	calloutSize = 40,
	calloutX = 960,
	calloutY = 300,
	opacity = 0.9,
	duration = 3,
}

function SmartCallouts:OnInitialize()
	calloutFrames = {}
	activeCallouts = {}
end

function SmartCallouts:OnEnable()
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

function SmartCallouts:ShowCallout(message, type)
	if not config.enabled then return end

	local callout = {
		message = message,
		type = type or "info",
		startTime = GetTime(),
		duration = config.duration
	}

	table.insert(activeCallouts, callout)
	Arenamaster:PrintDebug("Callout: " .. message)
end

function SmartCallouts:CreateCalloutFrame()
	if calloutFrames.main then return end

	local frame = CreateFrame("Frame", "ArenamasterCalloutFrame", UIParent)
	frame:SetSize(200, 100)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
	calloutFrames.main = frame
end

function SmartCallouts:UpdateCallouts()
	local currentTime = GetTime()
	local toRemove = {}

	for i, callout in ipairs(activeCallouts) do
		local elapsed = currentTime - callout.startTime
		if elapsed > callout.duration then
			table.insert(toRemove, i)
		end
	end

	for i = #toRemove, 1, -1 do
		table.remove(activeCallouts, toRemove[i])
	end
end

function SmartCallouts:ARENA_MATCH_START()
	self:CreateCalloutFrame()
	activeCallouts = {}
	Arenamaster:PrintDebug("Callouts enabled")
end

function SmartCallouts:ARENA_MATCH_END()
	activeCallouts = {}
end

function SmartCallouts:UNIT_SPELLCAST_SUCCEEDED(event, unit, castGUID, spellID)
	-- Show callouts for important spells
end
