-- Arenamaster: Ace3 Configuration Module
-- Beautiful configuration system using AceGUI-3.0 and AceConfig-3.0

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local Ace3Config = Arenamaster:NewModule("Ace3Config", "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

-- ===========================
-- INITIALIZATION
-- ===========================

function Ace3Config:OnInitialize()
	-- Setup options table with AceConfig
	self:SetupOptions()
end

function Ace3Config:OnEnable()
	-- Configuration enabled
end

-- ===========================
-- OPTIONS TABLE (AceConfig Format)
-- ===========================

function Ace3Config:SetupOptions()
	local options = {
		name = "Arenamaster",
		type = "group",
		args = {
			frames = {
				name = "Enemy Frames",
				type = "group",
				args = {
					layout = {
						name = "Layout",
						desc = "Frame layout style",
						type = "select",
						values = { vertical = "Vertical", horizontal = "Horizontal", grid = "Grid" },
						get = function() return Arenamaster.db.profile.frameLayout or "vertical" end,
						set = function(info, value) Arenamaster.db.profile.frameLayout = value end,
					},
					width = {
						name = "Frame Width",
						desc = "Width of each enemy frame",
						type = "range",
						min = 150, max = 400, step = 10,
						get = function() return Arenamaster.db.profile.frameWidth or 220 end,
						set = function(info, value) Arenamaster.db.profile.frameWidth = value end,
					},
					height = {
						name = "Frame Height",
						desc = "Height of each enemy frame",
						type = "range",
						min = 50, max = 200, step = 10,
						get = function() return Arenamaster.db.profile.frameHeight or 85 end,
						set = function(info, value) Arenamaster.db.profile.frameHeight = value end,
					},
					opacity = {
						name = "Opacity",
						desc = "Frame transparency",
						type = "range",
						min = 0.1, max = 1, step = 0.05,
						get = function() return Arenamaster.db.profile.frameOpacity or 0.95 end,
						set = function(info, value) Arenamaster.db.profile.frameOpacity = value end,
					},
				}
			},
			auras = {
				name = "Aura Tracking",
				type = "group",
				args = {
					enabled = {
						name = "Enable Aura Tracking",
						desc = "Track enemy buffs and debuffs",
						type = "toggle",
						get = function() return Arenamaster.db.profile.auraTrackingEnabled ~= false end,
						set = function(info, value) Arenamaster.db.profile.auraTrackingEnabled = value end,
					},
					cooldowns = {
						name = "Track Cooldowns",
						desc = "Track ability cooldowns",
						type = "toggle",
						get = function() return Arenamaster.db.profile.trackCooldowns ~= false end,
						set = function(info, value) Arenamaster.db.profile.trackCooldowns = value end,
					},
					countdown = {
						name = "Show Countdown",
						desc = "Display countdown timers",
						type = "toggle",
						get = function() return Arenamaster.db.profile.showCountdown ~= false end,
						set = function(info, value) Arenamaster.db.profile.showCountdown = value end,
					},
				}
			},
			notifications = {
				name = "Notifications",
				type = "group",
				args = {
					soundAlerts = {
						name = "Sound Alerts",
						desc = "Play sound notifications",
						type = "toggle",
						get = function() return Arenamaster.db.profile.soundAlerts ~= false end,
						set = function(info, value) Arenamaster.db.profile.soundAlerts = value end,
					},
					chatAnnouncements = {
						name = "Chat Announcements",
						desc = "Show chat notifications",
						type = "toggle",
						get = function() return Arenamaster.db.profile.chatAnnouncements end,
						set = function(info, value) Arenamaster.db.profile.chatAnnouncements = value end,
					},
				}
			},
		}
	}

	AceConfig:RegisterOptionsTable("Arenamaster", options)
	AceConfigDialog:AddToBlizOptions("Arenamaster", "Arenamaster")
end

-- ===========================
-- UTILITY FUNCTIONS
-- ===========================

function Ace3Config:GetDatabase()
	return Arenamaster.db
end
