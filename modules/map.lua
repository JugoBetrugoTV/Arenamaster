-- Arenamaster: Arena Map Module
-- Taktische Arena-Anzeige mit Gegner-Positionen

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ArenaMap = Arenamaster:NewModule("Map", "AceEvent-3.0")

local arenaMapFrame = nil

function ArenaMap:OnInitialize()
	-- Initialize map
end

function ArenaMap:OnEnable()
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function ArenaMap:CreateMapFrame()
	if arenaMapFrame then return end

	arenaMapFrame = CreateFrame("Frame", "ArenamasterMapFrame", UIParent)
	arenaMapFrame:SetSize(200, 200)
	arenaMapFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -20, -20)

	Arenamaster:PrintDebug("Arena map frame created")
end

function ArenaMap:UpdatePlayerPositions()
	-- Update player positions on map
end

function ArenaMap:ARENA_MATCH_START()
	self:CreateMapFrame()
	Arenamaster:PrintDebug("Arena map enabled for match")
end

function ArenaMap:ARENA_MATCH_END()
	if arenaMapFrame then
		arenaMapFrame:Hide()
	end
end

function ArenaMap:PLAYER_ENTERING_WORLD()
	-- Check if in arena
end
