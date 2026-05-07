-- Arenamaster: Cooldown Tracking Module
-- Verfolgt Cooldowns von gegnerischen Spielern

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local CooldownTracker = Arenamaster:NewModule("Cooldowns", "AceEvent-3.0", "AceTimer-3.0")

-- Cooldown data reference
local cooldownData = {
	-- Defensiv
	["Bubbles"] = { duration = 12, icon = "Interface/Icons/spell_holy_powerwordshield" },
	["Divine Shield"] = { duration = 12, icon = "Interface/Icons/spell_holy_divineShield" },
	["Ice Block"] = { duration = 10, icon = "Interface/Icons/spell_frost_frostward" },
	["Hand of Protection"] = { duration = 10, icon = "Interface/Icons/spell_holy_sealofprotection" },

	-- Offensive
	["Mortal Strike"] = { duration = 6, icon = "Interface/Icons/ability_warrior_warstomp" },
	["Kick"] = { duration = 15, icon = "Interface/Icons/ability_rogue_kick" },
	["Counterspell"] = { duration = 24, icon = "Interface/Icons/spell_mage_counterspell" },
	["Spellsteal"] = { duration = 10, icon = "Interface/Icons/spell_mage_spellsteal" },

	-- Crowd Control
	["Stun"] = { duration = 4, icon = "Interface/Icons/spell_icon_stun" },
	["Root"] = { duration = 8, icon = "Interface/Icons/spell_nature_root" },
}

local activeCooldowns = {}

-- ===========================
-- INITIALIZATION
-- ===========================

function CooldownTracker:OnInitialize()
	activeCooldowns = {}
end

function CooldownTracker:OnEnable()
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("ARENA_MATCH_END")
end

function CooldownTracker:OnDisable()
	-- Cleanup
end

-- ===========================
-- COOLDOWN TRACKING
-- ===========================

function CooldownTracker:TrackCooldown(playerName, ability, duration)
	if not activeCooldowns[playerName] then
		activeCooldowns[playerName] = {}
	end

	local endTime = GetTime() + (duration or 10)
	activeCooldowns[playerName][ability] = {
		endTime = endTime,
		remaining = duration,
		active = true
	}
end

function CooldownTracker:UpdateCooldowns()
	local currentTime = GetTime()

	for playerName, abilities in pairs(activeCooldowns) do
		for ability, data in pairs(abilities) do
			data.remaining = math.max(0, data.endTime - currentTime)
			data.active = data.remaining > 0
		end
	end
end

function CooldownTracker:GetPlayerCooldowns(playerName)
	if not activeCooldowns[playerName] then
		return {}
	end

	self:UpdateCooldowns()

	local result = {}
	for ability, data in pairs(activeCooldowns[playerName]) do
		if data.active then
			table.insert(result, {
				ability = ability,
				remaining = math.ceil(data.remaining),
				total = data.remaining
			})
		end
	end

	table.sort(result, function(a, b) return a.remaining < b.remaining end)
	return result
end

function CooldownTracker:GetActiveCooldownCount(playerName)
	if not activeCooldowns[playerName] then return 0 end

	self:UpdateCooldowns()

	local count = 0
	for _, data in pairs(activeCooldowns[playerName]) do
		if data.active then count = count + 1 end
	end

	return count
end

function CooldownTracker:ClearCooldowns(playerName)
	if playerName then
		activeCooldowns[playerName] = nil
	else
		activeCooldowns = {}
	end
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function CooldownTracker:UNIT_SPELLCAST_SUCCEEDED(event, unit, castGUID, spellID)
	-- Handled by predictor module
end

function CooldownTracker:ARENA_MATCH_END()
	self:ClearCooldowns()
	Arenamaster:PrintDebug("Cooldowns cleared for match end")
end
