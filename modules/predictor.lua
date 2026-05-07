-- Arenamaster: Cooldown Predictor Module
-- Vorhersagen über gegnerische Cooldowns und wichtige Fähigkeiten

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local CooldownPredictor = Arenamaster:NewModule("Predictor", "AceEvent-3.0", "AceTimer-3.0")

local ABILITY_COOLDOWNS = {
	-- Defensive
	["Divine Shield"] = 60,
	["Bubble"] = 60,
	["Ice Block"] = 24,
	["Power Word: Shield"] = 6,
	["Unending Resolve"] = 180,
	["Deterrence"] = 120,
	["Anti-Magic Shell"] = 60,
	["Evasion"] = 120,
	["Shadow Dance"] = 60,

	-- Offensive
	["Bloodlust"] = 120,
	["Time Warp"] = 60,
	["Heroism"] = 120,
	["Avatar"] = 180,
	["Power Infusion"] = 45,

	-- CC
	["Stun"] = 40,
	["Freeze"] = 20,
	["Blind"] = 60,
}

local predictions = {}

function CooldownPredictor:OnInitialize()
	predictions = {}
end

function CooldownPredictor:OnEnable()
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

function CooldownPredictor:PredictCooldown(unit, ability)
	local baseCooldown = ABILITY_COOLDOWNS[ability] or 60
	local estimatedReady = GetTime() + baseCooldown

	if not predictions[unit] then
		predictions[unit] = {}
	end

	predictions[unit][ability] = {
		cooldown = baseCooldown,
		estimatedReady = estimatedReady,
		confidence = 0.8
	}
end

function CooldownPredictor:GetPrediction(unit, ability)
	if not predictions[unit] or not predictions[unit][ability] then
		return nil
	end

	local pred = predictions[unit][ability]
	local timeRemaining = pred.estimatedReady - GetTime()

	return {
		remaining = math.max(0, timeRemaining),
		confidence = pred.confidence,
		cooldown = pred.cooldown
	}
end

function CooldownPredictor:UNIT_SPELLCAST_SUCCEEDED(event, unit, castGUID, spellID)
	-- Could use spellID to look up ability name and predict its cooldown
end
