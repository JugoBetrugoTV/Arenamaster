-- Arenamaster: Configuration Manager Module
-- Advanced configuration system with presets and profiles

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ConfigManager = Arenamaster:NewModule("Config", "AceEvent-3.0")

-- ===========================
-- PRESET DEFINITIONS
-- ===========================

local PRESETS = {
	AGGRESSIVE = {
		name = "🔥 Aggressive",
		description = "Large frames with maximum visibility and information",
		frameLayout = "horizontal",
		frameWidth = 280,
		frameHeight = 110,
		frameSpacing = 10,
		frameOpacity = 1,
		showFrameNames = true,
		showHealthText = true,
		showManaBar = true,
		showCastBar = true,
		showTrinket = true,
		showBuffs = true,
		showDebuffs = true,
		showClassIcon = true,
		auraTrackingEnabled = true,
		trackCooldowns = true,
		trackBuffs = true,
		trackDebuffs = true,
		showCountdown = true,
		soundAlerts = true,
		chatAnnouncements = true,
		screenAlerts = true,
		uiTheme = "Fire",
		fontSize = 13,
		enableAnimations = true,
	},

	COMPETITIVE = {
		name = "⚔️ Competitive",
		description = "Balanced setup optimized for serious ranked PvP",
		frameLayout = "vertical",
		frameWidth = 220,
		frameHeight = 85,
		frameSpacing = 8,
		frameOpacity = 0.95,
		showFrameNames = true,
		showHealthText = true,
		showManaBar = true,
		showCastBar = true,
		showTrinket = true,
		showBuffs = true,
		showDebuffs = true,
		showClassIcon = true,
		auraTrackingEnabled = true,
		trackCooldowns = true,
		trackBuffs = true,
		trackDebuffs = true,
		showCountdown = true,
		soundAlerts = true,
		chatAnnouncements = false,
		screenAlerts = true,
		uiTheme = "Ocean",
		fontSize = 11,
		enableAnimations = true,
	},

	MINIMAL = {
		name = "🧘 Minimal",
		description = "Clean, distraction-free UI for ultimate focus",
		frameLayout = "grid",
		frameWidth = 180,
		frameHeight = 70,
		frameSpacing = 6,
		frameOpacity = 0.8,
		showFrameNames = false,
		showHealthText = false,
		showManaBar = false,
		showCastBar = true,
		showTrinket = false,
		showBuffs = false,
		showDebuffs = false,
		showClassIcon = false,
		auraTrackingEnabled = true,
		trackCooldowns = true,
		trackBuffs = false,
		trackDebuffs = false,
		showCountdown = true,
		soundAlerts = true,
		chatAnnouncements = false,
		screenAlerts = false,
		uiTheme = "Dark",
		fontSize = 9,
		enableAnimations = false,
	},

	STREAMER = {
		name = "📺 Streamer",
		description = "Beautiful, visually impressive setup for streaming",
		frameLayout = "horizontal",
		frameWidth = 250,
		frameHeight = 100,
		frameSpacing = 12,
		frameOpacity = 0.92,
		showFrameNames = true,
		showHealthText = true,
		showManaBar = true,
		showCastBar = true,
		showTrinket = true,
		showBuffs = true,
		showDebuffs = true,
		showClassIcon = true,
		auraTrackingEnabled = true,
		trackCooldowns = true,
		trackBuffs = true,
		trackDebuffs = true,
		showCountdown = true,
		soundAlerts = true,
		chatAnnouncements = true,
		screenAlerts = true,
		uiTheme = "Ocean",
		fontSize = 12,
		showBorders = true,
		borderStyle = "Rounded",
		enableAnimations = true,
	},

	CASUAL = {
		name = "😎 Casual",
		description = "Relaxed setup for casual play and learning",
		frameLayout = "vertical",
		frameWidth = 200,
		frameHeight = 80,
		frameSpacing = 5,
		frameOpacity = 0.9,
		showFrameNames = true,
		showHealthText = true,
		showManaBar = true,
		showCastBar = true,
		showTrinket = false,
		showBuffs = true,
		showDebuffs = true,
		showClassIcon = true,
		auraTrackingEnabled = true,
		trackCooldowns = true,
		trackBuffs = true,
		trackDebuffs = true,
		showCountdown = false,
		soundAlerts = false,
		chatAnnouncements = true,
		screenAlerts = true,
		uiTheme = "Forest",
		fontSize = 10,
		enableAnimations = true,
	},
}

-- ===========================
-- INITIALIZATION
-- ===========================

function ConfigManager:OnInitialize()
	if not Arenamaster.db.profile.config then
		Arenamaster.db.profile.config = CopyTable(PRESETS.COMPETITIVE)
	end
end

function ConfigManager:OnEnable()
	-- Configuration enabled
end

-- ===========================
-- PRESET MANAGEMENT
-- ===========================

function ConfigManager:ApplyPreset(presetName)
	if not PRESETS[presetName] then
		print("|cffff0000Preset not found: " .. presetName .. "|r")
		return false
	end

	local preset = PRESETS[presetName]

	-- Apply all settings from preset
	for key, value in pairs(preset) do
		if key ~= "name" and key ~= "description" then
			Arenamaster.db.profile[key] = value
		end
	end

	Arenamaster.db.profile.currentPreset = presetName

	print("|cff00ff00✓ Preset applied: |cffff00ff" .. preset.name .. "|r")
	return true
end

function ConfigManager:GetPresets()
	return PRESETS
end

function ConfigManager:GetPresetInfo(presetName)
	return PRESETS[presetName]
end

function ConfigManager:GetCurrentPreset()
	return Arenamaster.db.profile.currentPreset or "COMPETITIVE"
end

-- ===========================
-- CONFIGURATION ACCESS
-- ===========================

function ConfigManager:GetConfig()
	return Arenamaster.db.profile
end

function ConfigManager:SetConfigValue(key, value)
	Arenamaster.db.profile[key] = value
end

function ConfigManager:GetConfigValue(key)
	return Arenamaster.db.profile[key]
end

function ConfigManager:ResetToDefaults()
	-- Reset to Competitive preset
	self:ApplyPreset("COMPETITIVE")
	print("|cff00ff00✓ Configuration reset to defaults|r")
end

function ConfigManager:ResetToPreset(presetName)
	if not PRESETS[presetName] then
		return false
	end

	return self:ApplyPreset(presetName)
end

-- ===========================
-- UTILITY FUNCTIONS
-- ===========================

function ConfigManager:GetFrameSettings()
	return {
		layout = Arenamaster.db.profile.frameLayout,
		width = Arenamaster.db.profile.frameWidth,
		height = Arenamaster.db.profile.frameHeight,
		spacing = Arenamaster.db.profile.frameSpacing,
		opacity = Arenamaster.db.profile.frameOpacity,
		x = Arenamaster.db.profile.frameX,
		y = Arenamaster.db.profile.frameY,
	}
end

function ConfigManager:GetNotificationSettings()
	return {
		soundAlerts = Arenamaster.db.profile.soundAlerts,
		chatAnnouncements = Arenamaster.db.profile.chatAnnouncements,
		screenAlerts = Arenamaster.db.profile.screenAlerts,
		voiceCallouts = Arenamaster.db.profile.voiceCallouts,
		volume = Arenamaster.db.profile.notificationVolume,
	}
end

function ConfigManager:ValidateSettings()
	-- Ensure all settings are within valid ranges
	local profile = Arenamaster.db.profile

	profile.frameWidth = math.max(150, math.min(400, profile.frameWidth or 220))
	profile.frameHeight = math.max(50, math.min(200, profile.frameHeight or 85))
	profile.frameOpacity = math.max(0.1, math.min(1, profile.frameOpacity or 0.95))
	profile.frameSpacing = math.max(0, math.min(50, profile.frameSpacing or 8))
	profile.fontSize = math.max(8, math.min(18, profile.fontSize or 11))
	profile.countdownFontSize = math.max(8, math.min(24, profile.countdownFontSize or 14))
	profile.notificationVolume = math.max(0, math.min(1, profile.notificationVolume or 0.7))

	return true
end
