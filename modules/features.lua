-- Arenamaster: Complete Features Module
-- Integrates best features from Gladius and ArenaCore with auto-config binding

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local Features = Arenamaster:NewModule("Features", "AceEvent-3.0")

-- ===========================
-- FEATURE REGISTRY
-- ===========================

-- All features that can be toggled - automatically syncs with config
local FEATURE_REGISTRY = {
	-- CORE GLADIUS FEATURES
	{
		id = "enemy_frames",
		name = "Enemy Frames",
		category = "Display",
		description = "Show detailed enemy unit frames with health, mana, cast bars",
		icon = "🎬",
		enabled = true,
		settings = {
			show_names = true,
			show_health_text = true,
			show_mana_bar = true,
			show_cast_bar = true,
			show_trinket = true,
			show_class_icon = true,
			frame_opacity = 0.95,
			frame_scale = 1.0,
		}
	},

	{
		id = "cooldown_tracking",
		name = "Cooldown Tracking",
		category = "Arena",
		description = "Track and display enemy ability cooldowns (from Gladius)",
		icon = "⏱️",
		enabled = true,
		settings = {
			show_cooldown_numbers = true,
			cooldown_precision = "seconds",  -- seconds, tenths
			update_frequency = 0.1,
			show_on_frame = true,
			cooldown_icon_size = 24,
		}
	},

	{
		id = "cc_tracking",
		name = "CC & Interrupt Tracking",
		category = "Arena",
		description = "Track crowd control effects and interrupt availability",
		icon = "🔒",
		enabled = true,
		settings = {
			show_cc_duration = true,
			show_interrupt_available = true,
			cc_warning = true,
			cc_warning_color = "red",
		}
	},

	{
		id = "threat_detection",
		name = "Threat Detection (Gladius)",
		category = "Intelligence",
		description = "Intelligent threat scoring based on cooldowns and positioning",
		icon = "⚠️",
		enabled = true,
		settings = {
			focus_recommendation = true,
			threat_update_rate = 0.5,
			consider_cc_immunity = true,
			consider_offensive_cds = true,
			threat_algorithm = "advanced",  -- simple, advanced
		}
	},

	-- ARENACORE SPECIFIC FEATURES
	{
		id = "diminishing_returns",
		name = "Diminishing Returns (ArenaCore)",
		category = "Arena",
		description = "Track DR chains for crowd control abilities",
		icon = "📉",
		enabled = true,
		settings = {
			show_dr_indicator = true,
			show_dr_percentage = true,
			warn_at_full_dr = true,
			dr_reset_time = 15,  -- seconds
		}
	},

	{
		id = "interrupt_prediction",
		name = "Interrupt Prediction (ArenaCore)",
		category = "Intelligence",
		description = "Predict when interrupts will be available based on cooldown patterns",
		icon = "🔮",
		enabled = true,
		settings = {
			show_predictions = true,
			confidence_threshold = 0.75,
			learning_enabled = true,
			pattern_history = 20,  -- matches to learn from
		}
	},

	{
		id = "aura_tracking",
		name = "Advanced Aura Tracking",
		category = "Display",
		description = "Display buffs, debuffs, and important auras from ArenaCore",
		icon = "✨",
		enabled = true,
		settings = {
			show_buffs = true,
			show_debuffs = true,
			show_my_debuffs = true,
			show_important_only = false,
			aura_size = 20,
			aura_icon_count = 8,
		}
	},

	{
		id = "combat_log_analysis",
		name = "Combat Log Analysis",
		category = "Analytics",
		description = "Real-time combat log parsing for detailed stats (ArenaCore)",
		icon = "📊",
		enabled = true,
		settings = {
			track_damage = true,
			track_healing = true,
			track_cc = true,
			track_dispels = true,
			log_detail_level = "medium",  -- basic, medium, detailed
		}
	},

	{
		id = "rating_system",
		name = "Rating & Tier System",
		category = "Profile",
		description = "Track current rating and display tier badges",
		icon = "⭐",
		enabled = true,
		settings = {
			auto_update_rating = true,
			show_tier_badge = true,
			show_bracket_info = true,
		}
	},

	{
		id = "match_statistics",
		name = "Match Statistics (Both)",
		category = "Analytics",
		description = "Track win/loss, duration, opponents, and outcomes",
		icon = "📈",
		enabled = true,
		settings = {
			track_matches = true,
			auto_save_match = true,
			keep_history = true,
			history_limit = 100,
			calculate_winrate = true,
		}
	},

	{
		id = "opponent_profiling",
		name = "Opponent Profiling (ArenaCore+)",
		category = "Intelligence",
		description = "Build profiles of opponent playstyles and patterns",
		icon = "👤",
		enabled = true,
		settings = {
			learning_enabled = true,
			min_matches_for_profile = 3,
			playstyle_categories = 8,
			update_on_match = true,
		}
	},

	{
		id = "voice_integration",
		name = "Voice Communication",
		category = "Team",
		description = "Integrate with team voice (Discord, TeamSpeak, Skype)",
		icon = "🎤",
		enabled = false,
		settings = {
			voice_provider = "discord",  -- discord, teamspeak, skype, none
			announce_threats = true,
			announce_cooldowns = true,
		}
	},

	{
		id = "party_frames",
		name = "Party Frames (Gladius)",
		category = "Display",
		description = "Show teammate information and cooldowns",
		icon = "👥",
		enabled = true,
		settings = {
			show_party_health = true,
			show_party_cooldowns = true,
			show_party_position = true,
			frame_size = "medium",  -- small, medium, large
		}
	},

	{
		id = "customizable_layouts",
		name = "Customizable Layouts",
		category = "UI",
		description = "Multiple layout options (Vertical, Horizontal, Grid)",
		icon = "📐",
		enabled = true,
		settings = {
			layout_type = "vertical",  -- vertical, horizontal, grid
			frame_arrangement = "custom",
			allow_repositioning = true,
			save_positions = true,
		}
	},

	{
		id = "advanced_filters",
		name = "Advanced Filters",
		category = "Intelligence",
		description = "Filter displayed information by type and importance",
		icon = "🔍",
		enabled = true,
		settings = {
			filter_by_class = true,
			filter_by_priority = true,
			show_only_threats = false,
			priority_levels = 3,  -- 1-5
		}
	},

	{
		id = "spell_queue",
		name = "Spell Queue System",
		category = "Combat",
		description = "Display and manage spell queuing for optimal gameplay",
		icon = "📜",
		enabled = false,
		settings = {
			show_queue = true,
			queue_size = 5,
			auto_cast_enabled = false,
		}
	},

	{
		id = "rating_goals",
		name = "Rating Goals & Progression",
		category = "Profile",
		description = "Set and track rating goals with progression indicators",
		icon = "🎯",
		enabled = true,
		settings = {
			enable_goals = true,
			auto_calculate_progress = true,
			show_time_estimate = true,
			seasonal_tracking = true,
		}
	},

	{
		id = "win_probability",
		name = "Match Win Probability",
		category = "Intelligence",
		description = "Calculate estimated win probability before match starts",
		icon = "📊",
		enabled = true,
		settings = {
			show_prediction = true,
			accuracy_mode = "conservative",  -- conservative, moderate, aggressive
			consider_rating = true,
			consider_winrate = true,
		}
	},

	{
		id = "spell_notifications",
		name = "Smart Spell Notifications",
		category = "Notifications",
		description = "Alert on important enemy spell casts",
		icon = "📢",
		enabled = true,
		settings = {
			notify_on_cc = true,
			notify_on_interrupt = true,
			notify_on_heal = true,
			notify_on_damage_cd = true,
			notification_sound = true,
		}
	},

	{
		id = "arena_map",
		name = "Arena Minimap",
		category = "Display",
		description = "Display arena with player positions and team location",
		icon = "🗺️",
		enabled = true,
		settings = {
			show_map = true,
			show_positions = true,
			show_los_indicators = true,
			map_size = "medium",
			map_opacity = 0.8,
		}
	},

	{
		id = "multiple_profiles",
		name = "Multiple Profiles",
		category = "Profile",
		description = "Save and switch between multiple configuration profiles",
		icon = "💾",
		enabled = true,
		settings = {
			auto_switch_spec = false,
			allow_import_export = true,
			cloud_sync = false,
		}
	},

	-- ARENA INTELLIGENCE FEATURES
	{
		id = "diminishing_returns_ui",
		name = "DR Display",
		category = "Intelligence",
		description = "Display diminishing returns status on enemy frames",
		icon = "📉",
		enabled = true,
		settings = {
			show_dr_percentage = true,
			dr_warning_threshold = 50,
			highlight_low_dr = true,
		}
	},

	{
		id = "threat_assessment_ui",
		name = "Threat Assessment Display",
		category = "Intelligence",
		description = "Show threat level indicators on enemy frames with multi-factor analysis",
		icon = "⚠️",
		enabled = true,
		settings = {
			show_threat_bar = true,
			threat_update_rate = 0.5,
			color_by_threat = true,
		}
	},

	{
		id = "interrupt_prediction_ui",
		name = "Interrupt Predictions",
		category = "Intelligence",
		description = "Display interrupt availability predictions with confidence scoring",
		icon = "🔮",
		enabled = true,
		settings = {
			show_predictions = true,
			show_confidence = true,
			update_frequency = 1.0,
		}
	},

	{
		id = "combat_analytics_display",
		name = "Real-Time Analytics Panel",
		category = "Analytics",
		description = "Display live DPS, HPS, CC counts, and match duration",
		icon = "📊",
		enabled = true,
		settings = {
			show_dps = true,
			show_hps = true,
			show_cc_stats = true,
			show_duration = true,
		}
	},

	{
		id = "arena_intelligence_engine",
		name = "Arena Intelligence Core",
		category = "Intelligence",
		description = "Enable all Arena Intelligence systems (DR, threats, interrupts, analytics)",
		icon = "🧠",
		enabled = true,
		settings = {
			tracking_enabled = true,
			debug_output = false,
			performance_mode = "balanced",
		}
	},
}

-- ===========================
-- INITIALIZATION
-- ===========================

function Features:OnInitialize()
	-- Sync all features with config database
	self:SyncFeaturesWithConfig()
end

function Features:OnEnable()
	self:RegisterEvent("ADDON_LOADED")
end

-- ===========================
-- FEATURE MANAGEMENT
-- ===========================

function Features:SyncFeaturesWithConfig()
	-- Ensure all features have config entries
	if not Arenamaster.db.profile.features then
		Arenamaster.db.profile.features = {}
	end

	for _, feature in ipairs(FEATURE_REGISTRY) do
		if not Arenamaster.db.profile.features[feature.id] then
			Arenamaster.db.profile.features[feature.id] = {
				enabled = feature.enabled,
				settings = CopyTable(feature.settings),
			}
		end
	end
end

function Features:EnableFeature(featureId)
	if not Arenamaster.db.profile.features[featureId] then
		return false
	end

	Arenamaster.db.profile.features[featureId].enabled = true
	Arenamaster:SendMessage("FEATURE_ENABLED", featureId)
	print("|cff00ff00✓ Feature enabled: " .. featureId .. "|r")
	return true
end

function Features:DisableFeature(featureId)
	if not Arenamaster.db.profile.features[featureId] then
		return false
	end

	Arenamaster.db.profile.features[featureId].enabled = false
	Arenamaster:SendMessage("FEATURE_DISABLED", featureId)
	print("|cff00ff00✓ Feature disabled: " .. featureId .. "|r")
	return true
end

function Features:IsFeatureEnabled(featureId)
	if not Arenamaster.db.profile.features or not Arenamaster.db.profile.features[featureId] then
		return false
	end
	return Arenamaster.db.profile.features[featureId].enabled
end

function Features:ToggleFeature(featureId)
	if self:IsFeatureEnabled(featureId) then
		self:DisableFeature(featureId)
	else
		self:EnableFeature(featureId)
	end
end

-- ===========================
-- SETTINGS MANAGEMENT
-- ===========================

function Features:SetFeatureSetting(featureId, settingKey, value)
	if not Arenamaster.db.profile.features[featureId] then
		return false
	end

	Arenamaster.db.profile.features[featureId].settings[settingKey] = value
	Arenamaster:SendMessage("FEATURE_SETTING_CHANGED", featureId, settingKey, value)
	return true
end

function Features:GetFeatureSetting(featureId, settingKey)
	if not Arenamaster.db.profile.features or not Arenamaster.db.profile.features[featureId] then
		return nil
	end

	local settings = Arenamaster.db.profile.features[featureId].settings
	return settings[settingKey]
end

function Features:GetFeatureSettings(featureId)
	if not Arenamaster.db.profile.features or not Arenamaster.db.profile.features[featureId] then
		return {}
	end

	return CopyTable(Arenamaster.db.profile.features[featureId].settings)
end

-- ===========================
-- FEATURE REGISTRY ACCESS
-- ===========================

function Features:GetFeatureInfo(featureId)
	for _, feature in ipairs(FEATURE_REGISTRY) do
		if feature.id == featureId then
			return feature
		end
	end
	return nil
end

function Features:GetAllFeatures()
	return FEATURE_REGISTRY
end

function Features:GetFeaturesByCategory(category)
	local result = {}
	for _, feature in ipairs(FEATURE_REGISTRY) do
		if feature.category == category then
			table.insert(result, feature)
		end
	end
	return result
end

function Features:GetCategories()
	local categories = {}
	for _, feature in ipairs(FEATURE_REGISTRY) do
		if not tContains(categories, feature.category) then
			table.insert(categories, feature.category)
		end
	end
	table.sort(categories)
	return categories
end

-- ===========================
-- FEATURE STATUS
-- ===========================

function Features:GetEnabledFeatures()
	local enabled = {}
	for _, feature in ipairs(FEATURE_REGISTRY) do
		if self:IsFeatureEnabled(feature.id) then
			table.insert(enabled, feature.id)
		end
	end
	return enabled
end

function Features:GetFeatureStatus()
	local status = {}
	for _, feature in ipairs(FEATURE_REGISTRY) do
		status[feature.id] = {
			enabled = self:IsFeatureEnabled(feature.id),
			name = feature.name,
			icon = feature.icon,
			category = feature.category,
		}
	end
	return status
end

function Features:PrintFeatureStatus()
	print("|cff00aiff━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━|r")
	print("|cff00aiff          ARENAMASTER FEATURES STATUS          |r")
	print("|cff00aiff━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━|r")

	local currentCategory = nil
	for _, feature in ipairs(FEATURE_REGISTRY) do
		if feature.category ~= currentCategory then
			currentCategory = feature.category
			print("|cff4dabf7" .. currentCategory .. "|r")
		end

		local status = self:IsFeatureEnabled(feature.id) and "|cff00ff00✓|r" or "|cffff0000✗|r"
		print("  " .. status .. " " .. feature.icon .. " " .. feature.name)
	end

	print("|cff00aiff━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━|r")
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function Features:ADDON_LOADED(event, addon)
	if addon == "Arenamaster" then
		self:SyncFeaturesWithConfig()
		Arenamaster:PrintDebug("All features synced with config")
	end
end
