-- Arenamaster: Ace3 Configuration Module
-- Beautiful configuration system using AceGUI-3.0 and AceConfig-3.0

local AM = Arenamaster
local Ace3Config = {}

-- Load Ace3 Libraries
local AceConfig = LibStub:GetLibrary("AceConfig-3.0")
local AceConfigDialog = LibStub:GetLibrary("AceConfigDialog-3.0")
local AceGUI = LibStub:GetLibrary("AceGUI-3.0")
local AceDB = LibStub:GetLibrary("AceDB-3.0")

-- Database defaults
local defaults = {
	profile = {
		frameLayout = "vertical",
		frameWidth = 220,
		frameHeight = 85,
		frameSpacing = 8,
		frameOpacity = 0.95,
		framePositionX = 100,
		framePositionY = 200,
		showFrameNames = true,
		showHealthText = true,
		showManaBar = true,
		showCastBar = true,
		showTrinket = true,
		showBuffs = true,
		showDebuffs = true,
		auraTrackingEnabled = true,
		trackCooldowns = true,
		trackBuffs = true,
		trackDebuffs = true,
		showCountdown = true,
		notifyMatchStart = true,
		notifyMatchEnd = true,
		soundAlerts = true,
		chatAnnouncements = false,
		colorChatMessages = true,
		showCloseButton = true,
		uiTheme = "Dark",
		fontSize = 11,
		trackGames = true,
		trackOpponents = true,
		trackRating = true,
	}
}

-- ===========================
-- INITIALIZATION
-- ===========================

function Ace3Config:Initialize()
	-- Create database
	if not ArenamasterDB then
		ArenamasterDB = {}
	end

	-- Initialize AceDB
	self.db = AceDB:New(ArenamasterDB, defaults)

	-- Register options table with AceConfig
	AceConfig:RegisterOptionsTable("Arenamaster", function()
		return self:GetOptions()
	end)

	-- Open config dialog
	AceConfigDialog:SetDefaultSize("Arenamaster", 900, 700)
end

-- ===========================
-- OPTIONS TABLE (AceConfig Format)
-- ===========================

function Ace3Config:GetOptions()
	return {
		name = "Arenamaster v4.0.0",
		handler = self.db,
		type = "group",
		args = {
			-- Presets Section
			presets = {
				name = "🎨 Presets",
				type = "group",
				order = 0,
				args = {
					aggressive = {
						name = "🔥 Aggressive",
						desc = "Large frames, all notifications enabled",
						type = "execute",
						func = function() self:ApplyPreset("AGGRESSIVE") end,
						order = 1,
					},
					competitive = {
						name = "⚔️ Competitive",
						desc = "Balanced setup for ranked play",
						type = "execute",
						func = function() self:ApplyPreset("COMPETITIVE") end,
						order = 2,
					},
					streamer = {
						name = "🎥 Streamer",
						desc = "Optimized for stream visibility",
						type = "execute",
						func = function() self:ApplyPreset("STREAMER") end,
						order = 3,
					},
					minimal = {
						name = "⚪ Minimal",
						desc = "Ultra-clean, distraction-free",
						type = "execute",
						func = function() self:ApplyPreset("MINIMAL") end,
						order = 4,
					},
					casual = {
						name = "🎮 Casual",
						desc = "Relaxed setup with optional alerts",
						type = "execute",
						func = function() self:ApplyPreset("CASUAL") end,
						order = 5,
					},
				}
			},

			-- Frames Section
			frames = {
				name = "🎯 Enemy Frames",
				type = "group",
				order = 1,
				args = {
					layout = {
						name = "Frame Layout",
						type = "select",
						values = {vertical = "Vertical", horizontal = "Horizontal", grid = "Grid"},
						order = 1,
					},
					width = {
						name = "Frame Width",
						type = "range",
						min = 150, max = 350, step = 10,
						order = 2,
					},
					height = {
						name = "Frame Height",
						type = "range",
						min = 60, max = 150, step = 5,
						order = 3,
					},
					spacing = {
						name = "Frame Spacing",
						type = "range",
						min = 0, max = 20, step = 1,
						order = 4,
					},
					opacity = {
						name = "Frame Opacity",
						type = "range",
						min = 0.3, max = 1, step = 0.05,
						order = 5,
					},
					showNames = {
						name = "Show Names",
						type = "toggle",
						order = 6,
					},
					showHealthText = {
						name = "Show Health %",
						type = "toggle",
						order = 7,
					},
					showManaBar = {
						name = "Show Mana Bar",
						type = "toggle",
						order = 8,
					},
					showCastBar = {
						name = "Show Cast Bar",
						type = "toggle",
						order = 9,
					},
					showTrinket = {
						name = "Show Trinket",
						type = "toggle",
						order = 10,
					},
					showBuffs = {
						name = "Show Buffs",
						type = "toggle",
						order = 11,
					},
					showDebuffs = {
						name = "Show Debuffs",
						type = "toggle",
						order = 12,
					},
				}
			},

			-- Auras Section
			auras = {
				name = "⚡ Aura Tracking",
				type = "group",
				order = 2,
				args = {
					enabled = {
						name = "Enable Tracking",
						type = "toggle",
						order = 1,
					},
					trackCooldowns = {
						name = "Track Cooldowns",
						type = "toggle",
						order = 2,
					},
					trackBuffs = {
						name = "Track Buffs",
						type = "toggle",
						order = 3,
					},
					trackDebuffs = {
						name = "Track Debuffs",
						type = "toggle",
						order = 4,
					},
					showCountdown = {
						name = "Show Countdown",
						type = "toggle",
						order = 5,
					},
				}
			},

			-- Notifications Section
			notifications = {
				name = "📢 Notifications",
				type = "group",
				order = 3,
				args = {
					matchStart = {
						name = "Match Start Notification",
						type = "toggle",
						order = 1,
					},
					matchEnd = {
						name = "Match End Notification",
						type = "toggle",
						order = 2,
					},
					soundAlerts = {
						name = "Sound Alerts",
						type = "toggle",
						order = 3,
					},
					chatAnnouncements = {
						name = "Chat Announcements",
						type = "toggle",
						order = 4,
					},
					colorChat = {
						name = "Colored Messages",
						type = "toggle",
						order = 5,
					},
				}
			},

			-- UI Section
			ui = {
				name = "🎨 UI Settings",
				type = "group",
				order = 4,
				args = {
					showClose = {
						name = "Show Close Button",
						type = "toggle",
						order = 1,
					},
					theme = {
						name = "UI Theme",
						type = "select",
						values = {Dark = "Dark", Light = "Light", Classic = "Classic"},
						order = 2,
					},
					fontSize = {
						name = "Font Size",
						type = "range",
						min = 8, max = 16, step = 1,
						order = 3,
					},
				}
			},

			-- Stats Section
			stats = {
				name = "📊 Statistics",
				type = "group",
				order = 5,
				args = {
					trackGames = {
						name = "Track Games",
						type = "toggle",
						order = 1,
					},
					trackOpponents = {
						name = "Track Opponents",
						type = "toggle",
						order = 2,
					},
					trackRating = {
						name = "Track Rating",
						type = "toggle",
						order = 3,
					},
				}
			},

			-- Actions Section
			actions = {
				name = "⚙️ Actions",
				type = "group",
				order = 6,
				args = {
					reset = {
						name = "Reset to Defaults",
						type = "execute",
						func = function()
							ArenamasterDB = {}
							AM.ConfigManager:Initialize()
							print("|cff00ff00✓ Settings reset to defaults|r")
						end,
						order = 1,
					},
					export = {
						name = "Export Configuration",
						type = "execute",
						func = function()
							local export = AM.ConfigManager:ExportConfig()
							print("|cff00ffff[EXPORT]|r " .. export)
						end,
						order = 2,
					},
				}
			},
		}
	}
end

-- ===========================
-- PRESET SYSTEM
-- ===========================

function Ace3Config:ApplyPreset(preset)
	local presets = {
		AGGRESSIVE = {
			frameLayout = "horizontal",
			frameWidth = 280,
			frameHeight = 110,
			frameOpacity = 1,
			showHealthText = true,
			showManaBar = true,
			showCastBar = true,
			showTrinket = true,
			soundAlerts = true,
		},
		COMPETITIVE = {
			frameLayout = "vertical",
			frameWidth = 220,
			frameHeight = 85,
			frameOpacity = 0.95,
			showHealthText = true,
			showManaBar = true,
			showCastBar = true,
			fontSize = 11,
		},
		STREAMER = {
			frameLayout = "horizontal",
			frameWidth = 320,
			frameHeight = 120,
			frameOpacity = 1,
			showHealthText = true,
			showManaBar = true,
			showCastBar = true,
			fontSize = 13,
		},
		MINIMAL = {
			frameLayout = "vertical",
			frameWidth = 180,
			frameHeight = 60,
			frameOpacity = 0.75,
			showHealthText = false,
			showManaBar = false,
			showCastBar = true,
			fontSize = 9,
		},
		CASUAL = {
			frameLayout = "grid",
			frameWidth = 200,
			frameHeight = 80,
			frameOpacity = 0.85,
			showHealthText = true,
			showManaBar = true,
			fontSize = 10,
		}
	}

	if presets[preset] then
		for key, value in pairs(presets[preset]) do
			self.db.profile[key] = value
		end
		print("|cff00ff00✓ Preset applied: " .. preset .. "|r")
	end
end

-- ===========================
-- DIALOG MANAGEMENT
-- ===========================

function Ace3Config:OpenConfigDialog()
	AceConfigDialog:Open("Arenamaster")
end

-- Export
AM.Ace3Config = Ace3Config

return Ace3Config
