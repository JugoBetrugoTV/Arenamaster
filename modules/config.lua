-- Arenamaster: Configuration Module
-- Advanced configuration system with presets and profiles

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ConfigManager = Arenamaster:NewModule("Config", "AceEvent-3.0")

local PRESETS = {
	AGGRESSIVE = {
		name = "Aggressive",
		description = "Large frames, maximum visibility",
		frameLayout = "horizontal",
		frameWidth = 280,
		frameHeight = 110,
		frameOpacity = 1,
		showHealthText = true,
		showManaBar = true,
		showCastBar = true,
	},
	COMPETITIVE = {
		name = "Competitive",
		description = "Balanced setup for ranked play",
		frameLayout = "vertical",
		frameWidth = 220,
		frameHeight = 85,
		frameOpacity = 0.95,
		frameSpacing = 8,
		showHealthText = true,
		showManaBar = true,
		showCastBar = true,
	},
	MINIMAL = {
		name = "Minimal",
		description = "Minimal UI, distraction-free",
		frameLayout = "grid",
		frameWidth = 180,
		frameHeight = 70,
		frameOpacity = 0.8,
		showHealthText = false,
		showManaBar = false,
		showCastBar = true,
	},
}

function ConfigManager:OnInitialize()
	if not Arenamaster.db.profile.config then
		Arenamaster.db.profile.config = CopyTable(PRESETS.COMPETITIVE)
	end
end

function ConfigManager:OnEnable()
	-- Configuration enabled
end

function ConfigManager:ApplyPreset(presetName)
	if not PRESETS[presetName] then return false end

	local preset = PRESETS[presetName]
	for key, value in pairs(preset) do
		if key ~= "name" and key ~= "description" then
			Arenamaster.db.profile.config[key] = value
		end
	end

	Arenamaster:PrintDebug("Preset applied: " .. presetName)
	return true
end

function ConfigManager:GetConfig()
	return Arenamaster.db.profile.config
end

function ConfigManager:SetConfigValue(key, value)
	Arenamaster.db.profile.config[key] = value
end

function ConfigManager:GetConfigValue(key)
	return Arenamaster.db.profile.config[key]
end

function ConfigManager:GetPresets()
	return PRESETS
end

function ConfigManager:ResetToDefaults()
	Arenamaster.db.profile.config = CopyTable(PRESETS.COMPETITIVE)
	Arenamaster:PrintDebug("Config reset to defaults")
end
