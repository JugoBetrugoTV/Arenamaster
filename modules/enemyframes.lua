-- Arenamaster: Enemy Frames Module
-- Displays opponent health, mana, cast bars, and status information

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local EnemyFrames = Arenamaster:NewModule("EnemyFrames", "AceEvent-3.0", "AceTimer-3.0")

local config = {
	enabled = true,
	layout = "vertical",
	frameWidth = 220,
	frameHeight = 85,
	spacing = 8,
	showNames = true,
	showHealthText = true,
	showManaBar = true,
	showCastBar = true,
	showTrinket = true,
	showBuffs = true,
	showDebuffs = true,
	showClassIcon = true,
	opacity = 0.95,
	frameX = 100,
	frameY = 200,
}

local frames = {}

function EnemyFrames:OnInitialize()
	frames = {}
end

function EnemyFrames:OnEnable()
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UNIT_MAXHEALTH")
	self:RegisterEvent("UNIT_AURA")
end

function EnemyFrames:CreateEnemyFrames()
	for i = 1, 5 do
		local unit = "arena" .. i
		if not frames[unit] then
			local frame = CreateFrame("Frame", "ArenamasterEnemyFrame" .. i, UIParent)
			frame:SetSize(config.frameWidth, config.frameHeight)

			if config.layout == "vertical" then
				local y = config.frameY + (i - 1) * (config.frameHeight + config.spacing)
				frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", config.frameX, -y)
			end

			frames[unit] = frame
		end
	end
end

function EnemyFrames:UpdateFrames()
	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) and frames[unit] then
			local health = UnitHealth(unit)
			local maxHealth = UnitHealthMax(unit)
			-- Update display
		end
	end
end

function EnemyFrames:ARENA_MATCH_START()
	self:CreateEnemyFrames()
	Arenamaster:PrintDebug("Enemy frames created")
end

function EnemyFrames:ARENA_MATCH_END()
	for _, frame in pairs(frames) do
		if frame then
			frame:Hide()
		end
	end
end

function EnemyFrames:UNIT_HEALTH(event, unit)
	self:UpdateFrames()
end

function EnemyFrames:UNIT_MAXHEALTH(event, unit)
	self:UpdateFrames()
end

function EnemyFrames:UNIT_AURA(event, unit)
	self:UpdateFrames()
end
