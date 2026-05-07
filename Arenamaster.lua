-- Arenamaster - Professional PvP Arena Addon
-- Complete Ace3 Framework Implementation for WoW 12.0.5

local ADDON_NAME = "Arenamaster"
local ADDON_VERSION = "2.0.0-Ace3"

-- Create addon instance using AceAddon framework
local Arenamaster = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceGUI = LibStub("AceGUI-3.0")

-- AceConfigDialog is loaded later to avoid dependency issues
local AceConfigDialog

-- ===========================
-- ADDON DEFAULTS
-- ===========================

local defaults = {
	profile = {
		windowPos = { x = 100, y = 200 },
		windowScale = 1.0,
		debugMode = false,

		-- Frame Settings
		showEnemyFrames = true,
		enemyFrameOpacity = 0.9,
		enemyFrameScale = 1.0,

		-- Aura Tracking
		showAuraTracker = true,
		showCooldownPrediction = true,

		-- Notifications
		enableNotifications = true,
		notificationVolume = 0.7,
		showVisualAlerts = true,

		-- Analytics
		trackStats = true,
		trackMatches = true,

		-- UI Preset
		currentPreset = "Competitive",
	}
}

-- ===========================
-- INITIALIZATION
-- ===========================

function Arenamaster:OnInitialize()
	-- Initialize database with AceDB
	self.db = AceDB:New("ArenamasterDB", defaults, true)

	-- Setup options table
	self:SetupOptions()

	print("|cff00ff00[" .. ADDON_NAME .. "]|r v" .. ADDON_VERSION .. " initializing...")
end

function Arenamaster:OnEnable()
	-- Register events
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("PLAYER_LOGIN")

	-- Initialize modules
	self:InitializeModules()

	-- Create UI
	self:CreateMainUI()

	-- Start threat detection timer
	self:ScheduleRepeatingTimer("UpdateThreats", 0.5)

	print("|cff00ff00[" .. ADDON_NAME .. "]|r enabled!")
	print("|cff4dabf7Use |cff00ffff/am|r or |cff00ffff/arenamaster|r for commands")
end

function Arenamaster:OnDisable()
	self:CancelAllTimers()
	print("|cffff7700[" .. ADDON_NAME .. "]|r disabled")
end

-- ===========================
-- SLASH COMMANDS
-- ===========================

function Arenamaster:GetAceConfigDialog()
	if not AceConfigDialog then
		AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
	end
	return AceConfigDialog
end

function Arenamaster:SetupOptions()
	local options = {
		name = ADDON_NAME,
		handler = Arenamaster,
		type = 'group',
		args = {
			general = {
				name = "🎮 General",
				type = 'group',
				order = 1,
				args = {
					enabled = {
						name = "Enable Addon",
						desc = "Enable/disable the entire addon",
						type = 'toggle',
						get = function()
							return Arenamaster.db.profile.enabled ~= false
						end,
						set = function(info, value)
							Arenamaster.db.profile.enabled = value
							print("Arenamaster " .. (value and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
						end,
						order = 1,
					},
					debugMode = {
						name = "Debug Mode",
						desc = "Show debug information in chat",
						type = 'toggle',
						get = function()
							return Arenamaster.db.profile.debugMode
						end,
						set = function(info, value)
							Arenamaster.db.profile.debugMode = value
							print("Debug mode: " .. (value and "|cff00ff00ON|r" or "|cffff7700OFF|r"))
						end,
						order = 2,
					},
					windowScale = {
						name = "Window Scale",
						desc = "Scale of the main window",
						type = 'range',
						min = 0.5,
						max = 2.0,
						step = 0.1,
						get = function()
							return Arenamaster.db.profile.windowScale or 1.0
						end,
						set = function(info, value)
							Arenamaster.db.profile.windowScale = value
						end,
						order = 3,
					},
				}
			},
			frames = {
				name = "🖼️ Frames",
				type = 'group',
				order = 2,
				args = {
					showEnemyFrames = {
						name = "Show Enemy Frames",
						desc = "Display enemy health/mana frames",
						type = 'toggle',
						get = function()
							return Arenamaster.db.profile.showEnemyFrames
						end,
						set = function(info, value)
							Arenamaster.db.profile.showEnemyFrames = value
						end,
						order = 1,
					},
					enemyFrameOpacity = {
						name = "Enemy Frame Opacity",
						desc = "Transparency of enemy frames",
						type = 'range',
						min = 0.1,
						max = 1.0,
						step = 0.05,
						get = function()
							return Arenamaster.db.profile.enemyFrameOpacity
						end,
						set = function(info, value)
							Arenamaster.db.profile.enemyFrameOpacity = value
						end,
						order = 2,
					},
					enemyFrameScale = {
						name = "Enemy Frame Scale",
						desc = "Size of enemy frames",
						type = 'range',
						min = 0.5,
						max = 2.0,
						step = 0.1,
						get = function()
							return Arenamaster.db.profile.enemyFrameScale
						end,
						set = function(info, value)
							Arenamaster.db.profile.enemyFrameScale = value
						end,
						order = 3,
					},
				}
			},
			auras = {
				name = "✨ Auras & Cooldowns",
				type = 'group',
				order = 3,
				args = {
					showAuraTracker = {
						name = "Show Aura Tracker",
						desc = "Track buffs and debuffs",
						type = 'toggle',
						get = function()
							return Arenamaster.db.profile.showAuraTracker
						end,
						set = function(info, value)
							Arenamaster.db.profile.showAuraTracker = value
						end,
						order = 1,
					},
					showCooldownPrediction = {
						name = "Show Cooldown Prediction",
						desc = "Predict cooldown availability",
						type = 'toggle',
						get = function()
							return Arenamaster.db.profile.showCooldownPrediction
						end,
						set = function(info, value)
							Arenamaster.db.profile.showCooldownPrediction = value
						end,
						order = 2,
					},
				}
			},
			notifications = {
				name = "🔔 Notifications",
				type = 'group',
				order = 4,
				args = {
					enableNotifications = {
						name = "Enable Notifications",
						desc = "Show alerts and notifications",
						type = 'toggle',
						get = function()
							return Arenamaster.db.profile.enableNotifications
						end,
						set = function(info, value)
							Arenamaster.db.profile.enableNotifications = value
						end,
						order = 1,
					},
					notificationVolume = {
						name = "Notification Volume",
						desc = "Volume of alert sounds",
						type = 'range',
						min = 0.0,
						max = 1.0,
						step = 0.05,
						get = function()
							return Arenamaster.db.profile.notificationVolume
						end,
						set = function(info, value)
							Arenamaster.db.profile.notificationVolume = value
						end,
						order = 2,
					},
					showVisualAlerts = {
						name = "Show Visual Alerts",
						desc = "Display visual notifications",
						type = 'toggle',
						get = function()
							return Arenamaster.db.profile.showVisualAlerts
						end,
						set = function(info, value)
							Arenamaster.db.profile.showVisualAlerts = value
						end,
						order = 3,
					},
				}
			},
			analytics = {
				name = "📊 Analytics",
				type = 'group',
				order = 5,
				args = {
					trackStats = {
						name = "Track Match Statistics",
						desc = "Collect match data for analysis",
						type = 'toggle',
						get = function()
							return Arenamaster.db.profile.trackStats
						end,
						set = function(info, value)
							Arenamaster.db.profile.trackStats = value
						end,
						order = 1,
					},
					trackMatches = {
						name = "Track Match History",
						desc = "Keep history of your matches",
						type = 'toggle',
						get = function()
							return Arenamaster.db.profile.trackMatches
						end,
						set = function(info, value)
							Arenamaster.db.profile.trackMatches = value
						end,
						order = 2,
					},
				}
			},
			actions = {
				name = "⚙️ Actions",
				type = 'group',
				order = 6,
				args = {
					reset = {
						name = "Reset All Settings",
						desc = "Reset all settings to default",
						type = 'execute',
						func = function()
							Arenamaster.db:ResetProfile()
							print("|cff4dabf7Arenamaster|r settings reset to default!")
						end,
						order = 1,
					},
				}
			},
		}
	}

	AceConfig:RegisterOptionsTable(ADDON_NAME, options)

	local dialog = self:GetAceConfigDialog()
	if dialog and dialog.AddToBlizOptions then
		pcall(function()
			dialog:AddToBlizOptions(ADDON_NAME, ADDON_NAME)
		end)
	end

	self:RegisterChatCommand("am", "HandleChatCommand")
	self:RegisterChatCommand("arenamaster", "HandleChatCommand")
end

function Arenamaster:HandleChatCommand(input)
	input = input and input:trim() or ""

	if input == "" or input == "config" then
		-- Open beautiful config UI
		local ConfigUI = self:GetModule("ConfigUI")
		if ConfigUI then
			ConfigUI:ShowConfigWindow()
		else
			local dialog = self:GetAceConfigDialog()
			if dialog then
				dialog:Open(ADDON_NAME)
			end
		end
	elseif input == "advanced" then
		-- Open advanced options
		local dialog = self:GetAceConfigDialog()
		if dialog then
			dialog:Open(ADDON_NAME)
		end
	elseif input == "export" then
		-- Export settings
		local ConfigAdvanced = self:GetModule("ConfigAdvanced")
		if ConfigAdvanced then
			ConfigAdvanced:ShowExportDialog()
		end
	elseif input == "import" then
		-- Import settings
		local ConfigAdvanced = self:GetModule("ConfigAdvanced")
		if ConfigAdvanced then
			ConfigAdvanced:ShowImportDialog()
		end
	elseif input == "preset" then
		print("|cff00ff00Available presets:|r")
		local ConfigMod = self:GetModule("Config")
		if ConfigMod then
			for name, preset in pairs(ConfigMod:GetPresets()) do
				print("  |cff00aeff" .. name .. "|r - " .. preset.description)
			end
		end
	elseif input:sub(1, 6) == "preset" then
		local presetName = input:sub(8):upper()
		local ConfigMod = self:GetModule("Config")
		if ConfigMod then
			ConfigMod:ApplyPreset(presetName)
		end
	elseif input == "stats" then
		self:ShowStats()
	elseif input == "help" then
		print("|cff00aiffArenamaster Commands:|r")
		print("  |cffff00ff/am|r or |cffff00ff/am config|r - Open configuration")
		print("  |cffff00ff/am advanced|r - Advanced options")
		print("  |cffff00ff/am export|r - Export your settings")
		print("  |cffff00ff/am import|r - Import settings")
		print("  |cffff00ff/am preset|r - Show available presets")
		print("  |cffff00ff/am preset <name>|r - Apply preset")
		print("  |cffff00ff/am stats|r - Show statistics")
		print("  |cffff00ff/am help|r - Show this help")
	else
		print("|cffff0000Unknown command:|r " .. input)
		print("|cff00aiff/am help|r for available commands")
	end
end

-- ===========================
-- MODULE INITIALIZATION
-- ===========================

function Arenamaster:InitializeModules()
	-- Tier 0: Foundation modules (no dependencies)
	if Arenamaster_Opponents then
		Arenamaster_Opponents:Initialize()
	end

	if Arenamaster_Cooldowns then
		Arenamaster_Cooldowns:Initialize()
	end

	if Arenamaster_Rating then
		Arenamaster_Rating:Initialize()
	end

	-- Tier 1: UI modules (depends on Tier 0)
	if Arenamaster_ConfigUI then
		Arenamaster_ConfigUI:Initialize()
	end

	if Arenamaster_AuraTracker then
		Arenamaster_AuraTracker:Initialize()
	end

	if Arenamaster_EnemyFrames then
		Arenamaster_EnemyFrames:Initialize()
	end

	-- Tier 2: Analysis modules (depends on Tier 0-1)
	if Arenamaster_Threat then
		Arenamaster_Threat:Initialize()
	end

	if Arenamaster_Predictor then
		Arenamaster_Predictor:Initialize()
	end

	if Arenamaster_Analytics then
		Arenamaster_Analytics:Initialize()
	end

	-- Tier 3: Notification modules (depends on Tier 0-2)
	if Arenamaster_Notifications then
		Arenamaster_Notifications:Initialize()
	end

	if Arenamaster_Map then
		Arenamaster_Map:Initialize()
	end

	if Arenamaster_Callouts then
		Arenamaster_Callouts:Initialize()
	end

	-- Tier 4: AI modules (depends on all)
	if Arenamaster_Profiler then
		Arenamaster_Profiler:Initialize()
	end

	if Arenamaster_PredictorMatch then
		Arenamaster_PredictorMatch:Initialize()
	end

	if Arenamaster_Goals then
		Arenamaster_Goals:Initialize()
	end
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function Arenamaster:ADDON_LOADED(event, addon)
	if addon == ADDON_NAME then
		-- Addon loaded, already handled in OnEnable
	end
end

function Arenamaster:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
	if self.db.profile.debugMode then
		print("|cff00ffff[Arena Prep]|r Specializations available")
	end
end

function Arenamaster:ARENA_MATCH_START()
	if self.db.profile.debugMode then
		print("|cff00ff00[Arena Match]|r Match started!")
	end
end

function Arenamaster:ARENA_MATCH_END()
	if self.db.profile.debugMode then
		print("|cffff7700[Arena Match]|r Match ended")
	end
end

function Arenamaster:UNIT_SPELLCAST_SUCCEEDED(event, unit, castGUID, spellID)
	-- Handled by modules
end

function Arenamaster:UNIT_AURA(event, unit)
	-- Handled by modules
end

function Arenamaster:PLAYER_LOGIN()
	-- Addon fully loaded
end

-- ===========================
-- TIMER CALLBACKS
-- ===========================

function Arenamaster:UpdateThreats()
	-- Call threat detection update
	if Arenamaster_Threat then
		Arenamaster_Threat:UpdateAllThreats()
	end
end

-- ===========================
-- UI CREATION
-- ===========================

function Arenamaster:CreateMainUI()
	-- Main UI creation handled by modules
	-- ConfigUI, EnemyFrames, Map, etc. create their own frames
end

-- ===========================
-- UTILITY FUNCTIONS
-- ===========================

function Arenamaster:ShowStats()
	if Arenamaster_Analytics then
		Arenamaster_Analytics:ShowStats()
	else
		print("|cffff7700Analytics module not loaded|r")
	end
end

function Arenamaster:GetDB()
	return self.db
end

function Arenamaster:PrintDebug(message)
	if self.db.profile.debugMode then
		print("|cff4dabf7[DEBUG]|r " .. message)
	end
end

-- ===========================
-- EXPOSE GLOBAL REFERENCE
-- ===========================

_G.Arenamaster = Arenamaster
