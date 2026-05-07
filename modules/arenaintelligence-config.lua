-- Arenamaster: Arena Intelligence Configuration Module
-- Detailed settings and options for Arena Intelligence systems

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ArenaIntelligenceConfig = Arenamaster:NewModule("ArenaIntelligenceConfig", "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaIntelligenceConfig:OnInitialize()
	self:InitializeDefaults()
	self:RegisterOptions()
end

function ArenaIntelligenceConfig:InitializeDefaults()
	if not Arenamaster.db.profile.arenaIntelligence then
		Arenamaster.db.profile.arenaIntelligence = {
			-- DR Settings
			dr = {
				enabled = true,
				show_indicator = true,
				show_percentage = true,
				warn_below_threshold = 50,
				reset_time = 15,
				track_all_chains = true,
			},
			-- Threat Settings
			threat = {
				enabled = true,
				show_indicator = true,
				update_frequency = 0.5,
				health_weight = 30,
				offensive_weight = 25,
				defensive_weight = 20,
				class_weight = 15,
				distance_weight = 10,
			},
			-- Interrupt Settings
			interrupt = {
				enabled = true,
				show_predictions = true,
				show_confidence = true,
				min_confidence = 0.5,
				learning_enabled = true,
				pattern_history = 20,
				update_frequency = 1.0,
			},
			-- Analytics Settings
			analytics = {
				enabled = true,
				track_damage = true,
				track_healing = true,
				track_cc = true,
				track_dispels = true,
				max_events = 1000,
				calculate_efficiency = true,
			},
			-- Display Settings
			display = {
				show_dr_on_frames = true,
				show_threat_on_frames = true,
				show_interrupts_on_frames = true,
				frame_opacity = 0.85,
				show_analytics_panel = true,
				analytics_panel_pos = {x = 0, y = 0},
			},
		}
	end
end

function ArenaIntelligenceConfig:RegisterOptions()
	-- Create AceConfig options table
	local optionsTable = self:BuildOptionsTable()

	if AceConfig then
		AceConfig:RegisterOptionsTable("Arenamaster_ArenaIntelligence", optionsTable)
	end

	if AceConfigDialog then
		AceConfigDialog:AddToBlizOptions("Arenamaster_ArenaIntelligence", "⚔️ Arena Intelligence", "Arenamaster")
	end
end

function ArenaIntelligenceConfig:BuildOptionsTable()
	return {
		type = "group",
		name = "⚔️ Arena Intelligence Configuration",
		desc = "Advanced settings for Arena Intelligence systems",
		args = {
			drSection = self:BuildDROptions(),
			threatSection = self:BuildThreatOptions(),
			interruptSection = self:BuildInterruptOptions(),
			analyticsSection = self:BuildAnalyticsOptions(),
			displaySection = self:BuildDisplayOptions(),
		}
	}
end

-- ===========================
-- DR OPTIONS
-- ===========================

function ArenaIntelligenceConfig:BuildDROptions()
	return {
		type = "group",
		name = "📉 Diminishing Returns",
		order = 1,
		args = {
			enabled = {
				type = "toggle",
				name = "Enable DR Tracking",
				desc = "Track diminishing returns on all CC abilities",
				get = function() return Arenamaster.db.profile.arenaIntelligence.dr.enabled end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.dr.enabled = value end,
				order = 1,
			},
			showIndicator = {
				type = "toggle",
				name = "Show DR Indicator",
				desc = "Display DR status on enemy frames",
				get = function() return Arenamaster.db.profile.arenaIntelligence.dr.show_indicator end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.dr.show_indicator = value end,
				order = 2,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.dr.enabled end,
			},
			showPercentage = {
				type = "toggle",
				name = "Show Percentage",
				desc = "Display DR percentage alongside indicator",
				get = function() return Arenamaster.db.profile.arenaIntelligence.dr.show_percentage end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.dr.show_percentage = value end,
				order = 3,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.dr.enabled end,
			},
			warnThreshold = {
				type = "range",
				name = "Warning Threshold (%)",
				desc = "Warn when DR drops below this percentage",
				min = 0,
				max = 100,
				step = 5,
				get = function() return Arenamaster.db.profile.arenaIntelligence.dr.warn_below_threshold end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.dr.warn_below_threshold = value end,
				order = 4,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.dr.enabled end,
			},
			resetTime = {
				type = "range",
				name = "DR Reset Time (seconds)",
				desc = "Time before DR chains reset",
				min = 5,
				max = 30,
				step = 1,
				get = function() return Arenamaster.db.profile.arenaIntelligence.dr.reset_time end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.dr.reset_time = value end,
				order = 5,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.dr.enabled end,
			},
		}
	}
end

-- ===========================
-- THREAT OPTIONS
-- ===========================

function ArenaIntelligenceConfig:BuildThreatOptions()
	return {
		type = "group",
		name = "⚠️ Threat Assessment",
		order = 2,
		args = {
			enabled = {
				type = "toggle",
				name = "Enable Threat Detection",
				desc = "Calculate and display threat levels for opponents",
				get = function() return Arenamaster.db.profile.arenaIntelligence.threat.enabled end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.threat.enabled = value end,
				order = 1,
			},
			showIndicator = {
				type = "toggle",
				name = "Show Threat Bars",
				desc = "Display threat level bars on frames",
				get = function() return Arenamaster.db.profile.arenaIntelligence.threat.show_indicator end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.threat.show_indicator = value end,
				order = 2,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.threat.enabled end,
			},
			updateFrequency = {
				type = "range",
				name = "Update Frequency (seconds)",
				desc = "How often to recalculate threat scores",
				min = 0.1,
				max = 2.0,
				step = 0.1,
				get = function() return Arenamaster.db.profile.arenaIntelligence.threat.update_frequency end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.threat.update_frequency = value end,
				order = 3,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.threat.enabled end,
			},
			healthWeight = {
				type = "range",
				name = "Health Weight (%)",
				desc = "Importance of current health in threat calculation",
				min = 0,
				max = 50,
				step = 5,
				get = function() return Arenamaster.db.profile.arenaIntelligence.threat.health_weight end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.threat.health_weight = value end,
				order = 4,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.threat.enabled end,
			},
			offensiveWeight = {
				type = "range",
				name = "Offensive Weight (%)",
				desc = "Importance of offensive cooldowns",
				min = 0,
				max = 50,
				step = 5,
				get = function() return Arenamaster.db.profile.arenaIntelligence.threat.offensive_weight end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.threat.offensive_weight = value end,
				order = 5,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.threat.enabled end,
			},
			defensiveWeight = {
				type = "range",
				name = "Defensive Weight (%)",
				desc = "Importance of defensive cooldowns",
				min = 0,
				max = 50,
				step = 5,
				get = function() return Arenamaster.db.profile.arenaIntelligence.threat.defensive_weight end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.threat.defensive_weight = value end,
				order = 6,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.threat.enabled end,
			},
		}
	}
end

-- ===========================
-- INTERRUPT OPTIONS
-- ===========================

function ArenaIntelligenceConfig:BuildInterruptOptions()
	return {
		type = "group",
		name = "🔮 Interrupt Prediction",
		order = 3,
		args = {
			enabled = {
				type = "toggle",
				name = "Enable Prediction Engine",
				desc = "Predict interrupt ability availability",
				get = function() return Arenamaster.db.profile.arenaIntelligence.interrupt.enabled end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.interrupt.enabled = value end,
				order = 1,
			},
			showPredictions = {
				type = "toggle",
				name = "Show Predictions",
				desc = "Display interrupt predictions on frames",
				get = function() return Arenamaster.db.profile.arenaIntelligence.interrupt.show_predictions end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.interrupt.show_predictions = value end,
				order = 2,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.interrupt.enabled end,
			},
			showConfidence = {
				type = "toggle",
				name = "Show Confidence",
				desc = "Display confidence percentage for predictions",
				get = function() return Arenamaster.db.profile.arenaIntelligence.interrupt.show_confidence end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.interrupt.show_confidence = value end,
				order = 3,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.interrupt.enabled end,
			},
			minConfidence = {
				type = "range",
				name = "Minimum Confidence",
				desc = "Only show predictions with this confidence level",
				min = 0,
				max = 1.0,
				step = 0.1,
				get = function() return Arenamaster.db.profile.arenaIntelligence.interrupt.min_confidence end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.interrupt.min_confidence = value end,
				order = 4,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.interrupt.enabled end,
			},
			learningEnabled = {
				type = "toggle",
				name = "Enable Learning",
				desc = "Learn interrupt patterns from opponent behavior",
				get = function() return Arenamaster.db.profile.arenaIntelligence.interrupt.learning_enabled end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.interrupt.learning_enabled = value end,
				order = 5,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.interrupt.enabled end,
			},
		}
	}
end

-- ===========================
-- ANALYTICS OPTIONS
-- ===========================

function ArenaIntelligenceConfig:BuildAnalyticsOptions()
	return {
		type = "group",
		name = "📊 Combat Analytics",
		order = 4,
		args = {
			enabled = {
				type = "toggle",
				name = "Enable Analytics",
				desc = "Track and analyze combat statistics",
				get = function() return Arenamaster.db.profile.arenaIntelligence.analytics.enabled end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.analytics.enabled = value end,
				order = 1,
			},
			trackDamage = {
				type = "toggle",
				name = "Track Damage",
				desc = "Record damage dealt and taken",
				get = function() return Arenamaster.db.profile.arenaIntelligence.analytics.track_damage end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.analytics.track_damage = value end,
				order = 2,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.analytics.enabled end,
			},
			trackHealing = {
				type = "toggle",
				name = "Track Healing",
				desc = "Record healing done",
				get = function() return Arenamaster.db.profile.arenaIntelligence.analytics.track_healing end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.analytics.track_healing = value end,
				order = 3,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.analytics.enabled end,
			},
			trackCC = {
				type = "toggle",
				name = "Track CC",
				desc = "Record crowd control applications",
				get = function() return Arenamaster.db.profile.arenaIntelligence.analytics.track_cc end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.analytics.track_cc = value end,
				order = 4,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.analytics.enabled end,
			},
			calculateEfficiency = {
				type = "toggle",
				name = "Calculate Efficiency",
				desc = "Compute combat efficiency metrics",
				get = function() return Arenamaster.db.profile.arenaIntelligence.analytics.calculate_efficiency end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.analytics.calculate_efficiency = value end,
				order = 5,
				disabled = function() return not Arenamaster.db.profile.arenaIntelligence.analytics.enabled end,
			},
		}
	}
end

-- ===========================
-- DISPLAY OPTIONS
-- ===========================

function ArenaIntelligenceConfig:BuildDisplayOptions()
	return {
		type = "group",
		name = "🎨 Display Settings",
		order = 5,
		args = {
			showDRFrames = {
				type = "toggle",
				name = "Show DR on Frames",
				desc = "Display DR indicators on enemy frames",
				get = function() return Arenamaster.db.profile.arenaIntelligence.display.show_dr_on_frames end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.display.show_dr_on_frames = value end,
				order = 1,
			},
			showThreatFrames = {
				type = "toggle",
				name = "Show Threat on Frames",
				desc = "Display threat bars on enemy frames",
				get = function() return Arenamaster.db.profile.arenaIntelligence.display.show_threat_on_frames end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.display.show_threat_on_frames = value end,
				order = 2,
			},
			showInterruptsFrames = {
				type = "toggle",
				name = "Show Interrupts on Frames",
				desc = "Display interrupt predictions on frames",
				get = function() return Arenamaster.db.profile.arenaIntelligence.display.show_interrupts_on_frames end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.display.show_interrupts_on_frames = value end,
				order = 3,
			},
			frameOpacity = {
				type = "range",
				name = "Frame Opacity",
				desc = "Opacity of intelligence indicator frames",
				min = 0.1,
				max = 1.0,
				step = 0.05,
				get = function() return Arenamaster.db.profile.arenaIntelligence.display.frame_opacity end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.display.frame_opacity = value end,
				order = 4,
			},
			showAnalyticsPanel = {
				type = "toggle",
				name = "Show Analytics Panel",
				desc = "Display real-time analytics panel",
				get = function() return Arenamaster.db.profile.arenaIntelligence.display.show_analytics_panel end,
				set = function(info, value) Arenamaster.db.profile.arenaIntelligence.display.show_analytics_panel = value end,
				order = 5,
			},
		}
	}
end

-- ===========================
-- VALIDATION & RESET
-- ===========================

function ArenaIntelligenceConfig:ValidateAllSettings()
	local ai = Arenamaster.db.profile.arenaIntelligence
	if not ai then
		self:InitializeDefaults()
		return true
	end

	-- Validate ranges
	ai.dr.warn_below_threshold = math.max(0, math.min(100, ai.dr.warn_below_threshold or 50))
	ai.threat.update_frequency = math.max(0.1, math.min(2.0, ai.threat.update_frequency or 0.5))
	ai.interrupt.min_confidence = math.max(0, math.min(1.0, ai.interrupt.min_confidence or 0.5))
	ai.display.frame_opacity = math.max(0.1, math.min(1.0, ai.display.frame_opacity or 0.85))

	return true
end

function ArenaIntelligenceConfig:ResetToDefaults()
	Arenamaster.db.profile.arenaIntelligence = nil
	self:InitializeDefaults()
	print("|cff00ff00✓ Arena Intelligence settings reset to defaults|r")
end

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaIntelligenceConfig:OnEnable()
	self:ValidateAllSettings()
	Arenamaster:PrintDebug("Arena Intelligence configuration loaded")
end
