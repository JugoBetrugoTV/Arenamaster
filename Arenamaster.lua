-- Arenamaster - Professional PvP Arena Addon
-- Complete Ace3 Framework Implementation for WoW 12.0.5

local ADDON_NAME = "Arenamaster"
local ADDON_VERSION = "2.0.0-Ace3"

-- Create addon instance using AceAddon framework
local Arenamaster = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

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

function Arenamaster:SetupOptions()
	local options = {
		name = ADDON_NAME,
		handler = Arenamaster,
		type = 'group',
		args = {
			config = {
				name = "Config",
				desc = "Open configuration",
				type = 'execute',
				func = function()
					AceConfigDialog:Open(ADDON_NAME)
				end
			},
			stats = {
				name = "Stats",
				desc = "Show statistics",
				type = 'execute',
				func = function()
					Arenamaster:ShowStats()
				end
			},
			reset = {
				name = "Reset",
				desc = "Reset all settings",
				type = 'execute',
				func = function()
					Arenamaster.db:ResetProfile()
				end
			},
			debug = {
				name = "Debug",
				desc = "Toggle debug mode",
				type = 'toggle',
				get = function()
					return Arenamaster.db.profile.debugMode
				end,
				set = function(info, value)
					Arenamaster.db.profile.debugMode = value
					print("Debug mode: " .. (value and "|cff00ff00ON|r" or "|cffff7700OFF|r"))
				end
			}
		}
	}

	AceConfig:RegisterOptionsTable(ADDON_NAME, options)
	AceConfigDialog:AddToBlizOptions(ADDON_NAME, ADDON_NAME)

	self:RegisterChatCommand("am", "HandleChatCommand")
	self:RegisterChatCommand("arenamaster", "HandleChatCommand")
end

function Arenamaster:HandleChatCommand(input)
	if not input or input:trim() == "" then
		AceConfigDialog:Open(ADDON_NAME)
	else
		AceConsole:ProcessLine(input)
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
