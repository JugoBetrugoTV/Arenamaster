-- Arenamaster: Professional Configuration System
-- Beautiful Ace3-based configuration with presets, themes, and profiles

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local Ace3Config = Arenamaster:NewModule("Ace3Config", "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local AceGUI = LibStub("AceGUI-3.0")

-- ===========================
-- CONFIGURATION DEFAULTS
-- ===========================

local defaults = {
	profile = {
		-- Enemy Frames
		frameLayout = "vertical",
		frameWidth = 220,
		frameHeight = 85,
		frameSpacing = 8,
		frameOpacity = 0.95,
		frameX = 100,
		frameY = 200,
		showFrameNames = true,
		showHealthText = true,
		showManaBar = true,
		showCastBar = true,
		showTrinket = true,
		showBuffs = true,
		showDebuffs = true,
		showClassIcon = true,

		-- Aura Tracking
		auraTrackingEnabled = true,
		trackCooldowns = true,
		trackBuffs = true,
		trackDebuffs = true,
		showCountdown = true,
		countdownFontSize = 14,

		-- Notifications
		soundAlerts = true,
		chatAnnouncements = true,
		screenAlerts = true,
		voiceCallouts = false,
		notificationVolume = 0.7,

		-- Analytics
		trackStats = true,
		trackMatches = true,
		keepHistory = true,
		historyLimit = 100,

		-- Threat Detection
		threatDetectionEnabled = true,
		threatUpdateInterval = 0.5,

		-- Theme & UI
		currentPreset = "Competitive",
		uiTheme = "Dark",
		fontSize = 11,
		showBorders = true,
		borderStyle = "Rounded",
		colorScheme = "Blue",

		-- Advanced
		debugMode = false,
		enableTooltips = true,
		enableAnimations = true,
		performanceMode = false,
	}
}

-- ===========================
-- INITIALIZATION
-- ===========================

function Ace3Config:OnInitialize()
	-- Initialize database
	Arenamaster.db = LibStub("AceDB-3.0"):New("ArenamasterDB", defaults, true)

	-- Register options table
	AceConfig:RegisterOptionsTable("Arenamaster", function()
		return self:GetOptionsTable()
	end)

	-- Add to Blizzard options (optional)
	local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
	if AceConfigDialog then
		pcall(function()
			AceConfigDialog:AddToBlizOptions("Arenamaster", "Arenamaster")
		end)
	end
end

function Ace3Config:OnEnable()
	-- Configuration enabled
end

-- ===========================
-- BEAUTIFUL OPTIONS TABLE
-- ===========================

function Ace3Config:GetOptionsTable()
	return {
		name = "|cff00aaffArenamaster|r |cffcccccc2.0.0|r",
		handler = Arenamaster,
		type = "group",
		childGroups = "tab",
		args = {
			-- FRAMES TAB
			frames = {
				name = "|cff00aaffEnemy Frames|r 🎯",
				type = "group",
				order = 10,
				args = {
					frameLayout = {
						name = "Layout Style",
						desc = "Choose frame arrangement (Vertical, Horizontal, Grid)",
						type = "select",
						values = {
							vertical = "|cff00aaffVertical|r - Stacked vertically",
							horizontal = "|cffffff00Horizontal|r - Side by side",
							grid = "|cffff00ffGrid|r - 2x3 grid layout"
						},
						get = function()
							return Arenamaster.db.profile.frameLayout
						end,
						set = function(info, value)
							Arenamaster.db.profile.frameLayout = value
							print("|cff00ff00✓ Frame layout changed to: " .. value .. "|r")
						end,
						order = 1,
					},

					frameSize = {
						name = "Frame Size",
						type = "group",
						inline = true,
						order = 2,
						args = {
							width = {
								name = "Width",
								desc = "Frame width (150-400)",
								type = "range",
								min = 150, max = 400, step = 10,
								get = function()
									return Arenamaster.db.profile.frameWidth
								end,
								set = function(info, value)
									Arenamaster.db.profile.frameWidth = value
								end,
								order = 1,
							},
							height = {
								name = "Height",
								desc = "Frame height (50-200)",
								type = "range",
								min = 50, max = 200, step = 10,
								get = function()
									return Arenamaster.db.profile.frameHeight
								end,
								set = function(info, value)
									Arenamaster.db.profile.frameHeight = value
								end,
								order = 2,
							},
							spacing = {
								name = "Spacing",
								desc = "Space between frames",
								type = "range",
								min = 0, max = 50, step = 1,
								get = function()
									return Arenamaster.db.profile.frameSpacing
								end,
								set = function(info, value)
									Arenamaster.db.profile.frameSpacing = value
								end,
								order = 3,
							},
						}
					},

					frameOpacity = {
						name = "Opacity",
						desc = "Frame transparency (0.1-1.0)",
						type = "range",
						min = 0.1, max = 1, step = 0.05,
						get = function()
							return Arenamaster.db.profile.frameOpacity
						end,
						set = function(info, value)
							Arenamaster.db.profile.frameOpacity = value
						end,
						order = 3,
					},

					frameDisplay = {
						name = "Display Options",
						type = "group",
						inline = true,
						order = 4,
						args = {
							showNames = {
								name = "Show Player Names",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.showFrameNames
								end,
								set = function(info, value)
									Arenamaster.db.profile.showFrameNames = value
								end,
								order = 1,
							},
							showHealth = {
								name = "Show Health Text",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.showHealthText
								end,
								set = function(info, value)
									Arenamaster.db.profile.showHealthText = value
								end,
								order = 2,
							},
							showMana = {
								name = "Show Mana Bar",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.showManaBar
								end,
								set = function(info, value)
									Arenamaster.db.profile.showManaBar = value
								end,
								order = 3,
							},
							showCast = {
								name = "Show Cast Bar",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.showCastBar
								end,
								set = function(info, value)
									Arenamaster.db.profile.showCastBar = value
								end,
								order = 4,
							},
							showTrinket = {
								name = "Show Trinket CD",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.showTrinket
								end,
								set = function(info, value)
									Arenamaster.db.profile.showTrinket = value
								end,
								order = 5,
							},
							showAuras = {
								name = "Show Buffs/Debuffs",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.showBuffs
								end,
								set = function(info, value)
									Arenamaster.db.profile.showBuffs = value
								end,
								order = 6,
							},
						}
					},
				}
			},

			-- AURAS TAB
			auras = {
				name = "|cffffff00Aura Tracking|r ⚡",
				type = "group",
				order = 20,
				args = {
					enabled = {
						name = "Enable Aura Tracking",
						desc = "Track cooldowns, buffs, and debuffs",
						type = "toggle",
						get = function()
							return Arenamaster.db.profile.auraTrackingEnabled
						end,
						set = function(info, value)
							Arenamaster.db.profile.auraTrackingEnabled = value
							print("|cff00ff00✓ Aura tracking " .. (value and "enabled" or "disabled") .. "|r")
						end,
						order = 1,
					},

					auraOptions = {
						name = "Tracking Options",
						type = "group",
						inline = true,
						order = 2,
						args = {
							trackCooldowns = {
								name = "Track Cooldowns",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.trackCooldowns
								end,
								set = function(info, value)
									Arenamaster.db.profile.trackCooldowns = value
								end,
								order = 1,
							},
							trackBuffs = {
								name = "Track Buffs",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.trackBuffs
								end,
								set = function(info, value)
									Arenamaster.db.profile.trackBuffs = value
								end,
								order = 2,
							},
							trackDebuffs = {
								name = "Track Debuffs",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.trackDebuffs
								end,
								set = function(info, value)
									Arenamaster.db.profile.trackDebuffs = value
								end,
								order = 3,
							},
							showCountdown = {
								name = "Show Countdown Timer",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.showCountdown
								end,
								set = function(info, value)
									Arenamaster.db.profile.showCountdown = value
								end,
								order = 4,
							},
						}
					},

					countdownSize = {
						name = "Countdown Font Size",
						desc = "Size of countdown numbers",
						type = "range",
						min = 8, max = 24, step = 1,
						get = function()
							return Arenamaster.db.profile.countdownFontSize
						end,
						set = function(info, value)
							Arenamaster.db.profile.countdownFontSize = value
						end,
						order = 3,
					},
				}
			},

			-- NOTIFICATIONS TAB
			notifications = {
				name = "|cff4dabf7Notifications|r 📢",
				type = "group",
				order = 30,
				args = {
					soundAlerts = {
						name = "Sound Alerts",
						desc = "Play sound for important events",
						type = "toggle",
						get = function()
							return Arenamaster.db.profile.soundAlerts
						end,
						set = function(info, value)
							Arenamaster.db.profile.soundAlerts = value
						end,
						order = 1,
					},

					volume = {
						name = "Alert Volume",
						desc = "Volume of sound alerts (0-1)",
						type = "range",
						min = 0, max = 1, step = 0.05,
						get = function()
							return Arenamaster.db.profile.notificationVolume
						end,
						set = function(info, value)
							Arenamaster.db.profile.notificationVolume = value
						end,
						order = 2,
						disabled = function()
							return not Arenamaster.db.profile.soundAlerts
						end,
					},

					displayOptions = {
						name = "Display Options",
						type = "group",
						inline = true,
						order = 3,
						args = {
							chatAlerts = {
								name = "Chat Announcements",
								desc = "Show alerts in chat",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.chatAnnouncements
								end,
								set = function(info, value)
									Arenamaster.db.profile.chatAnnouncements = value
								end,
								order = 1,
							},
							screenAlerts = {
								name = "Screen Alerts",
								desc = "Show visual alerts on screen",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.screenAlerts
								end,
								set = function(info, value)
									Arenamaster.db.profile.screenAlerts = value
								end,
								order = 2,
							},
							voiceCallouts = {
								name = "Voice Callouts",
								desc = "Voice notifications (experimental)",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.voiceCallouts
								end,
								set = function(info, value)
									Arenamaster.db.profile.voiceCallouts = value
								end,
								order = 3,
							},
						}
					},
				}
			},

			-- THEME TAB
			theme = {
				name = "|cff9775faTheme|r 🎨",
				type = "group",
				order = 40,
				args = {
					themeSelect = {
						name = "UI Theme",
						desc = "Choose color theme",
						type = "select",
						values = {
							Dark = "|cff333333Dark|r",
							Light = "|cffccccccLight|r",
							Ocean = "|cff00aaffOcean|r",
							Forest = "|cff00ff00Forest|r",
							Fire = "|cffff6600Fire|r",
						},
						get = function()
							return Arenamaster.db.profile.uiTheme
						end,
						set = function(info, value)
							Arenamaster.db.profile.uiTheme = value
							print("|cff00ff00✓ Theme changed to: " .. value .. "|r")
						end,
						order = 1,
					},

					fontSize = {
						name = "Font Size",
						desc = "UI text size",
						type = "range",
						min = 8, max = 18, step = 1,
						get = function()
							return Arenamaster.db.profile.fontSize
						end,
						set = function(info, value)
							Arenamaster.db.profile.fontSize = value
						end,
						order = 2,
					},

					styleOptions = {
						name = "Style Options",
						type = "group",
						inline = true,
						order = 3,
						args = {
							borders = {
								name = "Show Borders",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.showBorders
								end,
								set = function(info, value)
									Arenamaster.db.profile.showBorders = value
								end,
								order = 1,
							},
							animations = {
								name = "Enable Animations",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.enableAnimations
								end,
								set = function(info, value)
									Arenamaster.db.profile.enableAnimations = value
								end,
								order = 2,
							},
							tooltips = {
								name = "Show Tooltips",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.enableTooltips
								end,
								set = function(info, value)
									Arenamaster.db.profile.enableTooltips = value
								end,
								order = 3,
							},
						}
					},
				}
			},

			-- ADVANCED TAB
			advanced = {
				name = "|cffff6b6bAdvanced|r ⚙️",
				type = "group",
				order = 50,
				args = {
					threatDetection = {
						name = "Threat Detection",
						type = "group",
						inline = true,
						order = 1,
						args = {
							enabled = {
								name = "Enable Threat Detection",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.threatDetectionEnabled
								end,
								set = function(info, value)
									Arenamaster.db.profile.threatDetectionEnabled = value
								end,
								order = 1,
							},
							updateRate = {
								name = "Update Interval",
								desc = "How often to update (seconds)",
								type = "range",
								min = 0.1, max = 2, step = 0.1,
								get = function()
									return Arenamaster.db.profile.threatUpdateInterval
								end,
								set = function(info, value)
									Arenamaster.db.profile.threatUpdateInterval = value
								end,
								order = 2,
								disabled = function()
									return not Arenamaster.db.profile.threatDetectionEnabled
								end,
							},
						}
					},

					performance = {
						name = "Performance",
						type = "group",
						inline = true,
						order = 2,
						args = {
							performanceMode = {
								name = "Performance Mode",
								desc = "Disable animations and reduce updates for better FPS",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.performanceMode
								end,
								set = function(info, value)
									Arenamaster.db.profile.performanceMode = value
									print("|cff00ff00✓ Performance mode " .. (value and "enabled" or "disabled") .. "|r")
								end,
								order = 1,
							},
						}
					},

					analytics = {
						name = "Analytics",
						type = "group",
						inline = true,
						order = 3,
						args = {
							trackStats = {
								name = "Track Statistics",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.trackStats
								end,
								set = function(info, value)
									Arenamaster.db.profile.trackStats = value
								end,
								order = 1,
							},
							trackMatches = {
								name = "Track Matches",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.trackMatches
								end,
								set = function(info, value)
									Arenamaster.db.profile.trackMatches = value
								end,
								order = 2,
							},
							keepHistory = {
								name = "Keep Match History",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.keepHistory
								end,
								set = function(info, value)
									Arenamaster.db.profile.keepHistory = value
								end,
								order = 3,
							},
						}
					},

					debugging = {
						name = "Debug",
						type = "group",
						inline = true,
						order = 4,
						args = {
							debugMode = {
								name = "Debug Mode",
								desc = "Show debug messages in chat",
								type = "toggle",
								get = function()
									return Arenamaster.db.profile.debugMode
								end,
								set = function(info, value)
									Arenamaster.db.profile.debugMode = value
									print("|cff00ff00✓ Debug mode " .. (value and "enabled" or "disabled") .. "|r")
								end,
								order = 1,
							},
						}
					},
				}
			},

			-- PROFILES TAB
			profiles = {
				name = "|cff51cf66Profiles|r 💾",
				type = "group",
				order = 60,
				args = {
					profileSelect = {
						type = "group",
						guiInline = true,
						order = 1,
						name = "Profile Management",
						args = {
							new = {
								type = "input",
								name = "New Profile",
								desc = "Create a new profile",
								get = function() return "" end,
								set = function(info, value)
									if value and value ~= "" then
										Arenamaster.db:SetProfile(value)
										print("|cff00ff00✓ Profile created: " .. value .. "|r")
									end
								end,
								order = 1,
							},
							delete = {
								type = "execute",
								name = "Delete Current",
								desc = "Delete the current profile",
								func = function()
									local currentProfile = Arenamaster.db:GetCurrentProfile()
									if currentProfile ~= "Default" then
										Arenamaster.db:DeleteProfile(currentProfile)
										print("|cff00ff00✓ Profile deleted|r")
									else
										print("|cffff0000Cannot delete Default profile|r")
									end
								end,
								order = 2,
							},
							reset = {
								type = "execute",
								name = "Reset Profile",
								desc = "Reset to profile defaults",
								func = function()
									Arenamaster.db:ResetProfile()
									print("|cff00ff00✓ Profile reset to defaults|r")
								end,
								order = 3,
							},
						}
					},
				}
			},

			-- INFO TAB
			info = {
				name = "|cff4dabf7Info|r ℹ️",
				type = "group",
				order = 70,
				args = {
					header = {
						type = "description",
						name = "|cff00aaffArenamaster|r v|cff00ff002.0.0-Ace3|r\n\n" ..
							"|cffccccccProfessional PvP Arena Assistant for World of Warcraft 12.0.5|r\n\n" ..
							"|cff4dabf7Features:|r\n" ..
							"  • Real-time Enemy Frame Tracking\n" ..
							"  • Cooldown Prediction System\n" ..
							"  • Threat Detection Algorithm\n" ..
							"  • Opponent Profiling & Analytics\n" ..
							"  • Win Probability Calculation\n" ..
							"  • Goal Tracking System\n" ..
							"  • Full Ace3 Framework\n\n" ..
							"|cff4dabf7Commands:|r\n" ..
							"  /am config - Open configuration\n" ..
							"  /am stats - Show statistics\n" ..
							"  /am help - Show help\n",
						order = 1,
					},
				}
			},
		}
	}
end

-- ===========================
-- UTILITY FUNCTIONS
-- ===========================

function Ace3Config:GetDatabase()
	return Arenamaster.db
end

function Ace3Config:ResetToDefaults()
	Arenamaster.db:ResetProfile()
	print("|cff00ff00✓ Configuration reset to defaults|r")
end

function Ace3Config:GetProfile()
	return Arenamaster.db.profile
end
