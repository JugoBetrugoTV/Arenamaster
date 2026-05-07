-- Arenamaster: Threat Detection Module
-- Intelligente Analyse wem man focusen sollte

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ThreatDetector = Arenamaster:NewModule("Threat", "AceEvent-3.0", "AceTimer-3.0")

local THREAT_WEIGHTS = {
	health = 0.2,
	defensiveCooldowns = 0.15,
	offensiveCooldowns = 0.25,
	crowdControl = 0.2,
	damageClass = 0.2,
}

local threatLevels = {}
local focusRecommendation = nil

function ThreatDetector:OnInitialize()
	for i = 1, 5 do
		threatLevels["arena" .. i] = {
			score = 0,
			reasons = {},
			lastUpdate = 0,
		}
	end
end

function ThreatDetector:OnEnable()
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("ARENA_MATCH_START")
end

function ThreatDetector:CalculateThreat(unit)
	local healthPercent = 50
	if C_Unit and C_Unit.GetHealthPercent then
		healthPercent = C_Unit.GetHealthPercent(unit) or 50
	else
		local health = UnitHealth(unit)
		local maxHealth = UnitHealthMax(unit)
		if maxHealth > 0 then
			healthPercent = (health / maxHealth) * 100
		end
	end

	local threatScore = healthPercent * THREAT_WEIGHTS.health

	threatLevels[unit] = {
		score = threatScore,
		lastUpdate = GetTime(),
	}

	return threatScore
end

function ThreatDetector:UpdateAllThreats()
	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) then
			self:CalculateThreat(unit)
		end
	end
end

function ThreatDetector:GetThreatLevels()
	return threatLevels
end

function ThreatDetector:GetFocusTarget()
	return focusRecommendation
end

function ThreatDetector:UNIT_SPELLCAST_SUCCEEDED(event, unit, castGUID, spellID)
	-- Update threat on spell cast
	self:CalculateThreat(unit)
end

function ThreatDetector:UNIT_AURA(event, unit)
	-- Update threat on aura change
	self:CalculateThreat(unit)
end

function ThreatDetector:ARENA_MATCH_START()
	Arenamaster:PrintDebug("Threat detection started")
end
