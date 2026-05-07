-- Arenamaster: Feature Configuration Binding Module
-- Automatically creates config options for all features in Features module

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local FeatureConfig = Arenamaster:NewModule("FeatureConfig", "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")

-- ===========================
-- AUTO-GENERATE CONFIG OPTIONS
-- ===========================

function FeatureConfig:GenerateFeaturesOptionsTable()
	local Features = Arenamaster:GetModule("Features")
	if not Features then
		return {}
	end

	local featuresOptions = {
		type = "group",
		name = "⚔️ Features Management",
		order = 100,
		args = {}
	}

	local categories = Features:GetCategories()
	local orderCounter = 1

	for _, category in ipairs(categories) do
		local categoryFeatures = Features:GetFeaturesByCategory(category)

		-- Create category group
		local categoryGroup = {
			type = "group",
			name = category,
			order = orderCounter,
			inline = true,
			args = {}
		}

		local settingOrder = 1

		for _, feature in ipairs(categoryFeatures) do
			-- Feature toggle
			categoryGroup.args[feature.id .. "_enabled"] = {
				name = feature.icon .. " " .. feature.name,
				desc = feature.description,
				type = "toggle",
				get = function()
					return Features:IsFeatureEnabled(feature.id)
				end,
				set = function(info, value)
					if value then
						Features:EnableFeature(feature.id)
					else
						Features:DisableFeature(feature.id)
					end
				end,
				order = settingOrder,
			}

			settingOrder = settingOrder + 1

			-- Feature settings (if enabled)
			if feature.settings and next(feature.settings) then
				for settingKey, settingValue in pairs(feature.settings) do
					local settingType = type(settingValue)
					local optionDef = {
						name = self:FormatSettingName(settingKey),
						desc = "Configure " .. feature.name:lower() .. " - " .. settingKey,
						order = settingOrder,
						disabled = function()
							return not Features:IsFeatureEnabled(feature.id)
						end,
					}

					if settingType == "boolean" then
						optionDef.type = "toggle"
						optionDef.get = function()
							return Features:GetFeatureSetting(feature.id, settingKey)
						end
						optionDef.set = function(info, value)
							Features:SetFeatureSetting(feature.id, settingKey, value)
						end
					elseif settingType == "number" then
						optionDef.type = "range"
						optionDef.min = 0
						optionDef.max = 100
						optionDef.step = 1
						optionDef.get = function()
							return Features:GetFeatureSetting(feature.id, settingKey) or settingValue
						end
						optionDef.set = function(info, value)
							Features:SetFeatureSetting(feature.id, settingKey, value)
						end
					elseif settingType == "string" then
						-- Check if it's a choice setting (contains underscores or specific patterns)
						if string.find(settingKey, "_") or settingKey:match("^[a-z]+_[a-z]+") then
							optionDef.type = "select"
							optionDef.values = self:GetSettingValues(settingKey)
							optionDef.get = function()
								return Features:GetFeatureSetting(feature.id, settingKey) or settingValue
							end
							optionDef.set = function(info, value)
								Features:SetFeatureSetting(feature.id, settingKey, value)
							end
						else
							optionDef.type = "input"
							optionDef.multiline = false
							optionDef.get = function()
								return Features:GetFeatureSetting(feature.id, settingKey) or settingValue
							end
							optionDef.set = function(info, value)
								Features:SetFeatureSetting(feature.id, settingKey, value)
							end
						end
					end

					categoryGroup.args[feature.id .. "_" .. settingKey] = optionDef
					settingOrder = settingOrder + 1
				end
			end

			settingOrder = settingOrder + 1
		end

		featuresOptions.args[category] = categoryGroup
		orderCounter = orderCounter + 1
	end

	return featuresOptions
end

-- ===========================
-- HELPER FUNCTIONS
-- ===========================

function FeatureConfig:FormatSettingName(settingKey)
	-- Convert snake_case to Title Case
	local formatted = settingKey:gsub("_", " "):gsub("^%l", string.upper)
	-- Capitalize each word
	formatted = formatted:gsub("%s(%l)", function(a) return " " .. a:upper() end)
	return formatted
end

function FeatureConfig:GetSettingValues(settingKey)
	local values = {}

	if settingKey == "layout_type" then
		values = {vertical = "Vertical", horizontal = "Horizontal", grid = "Grid"}
	elseif settingKey == "frame_arrangement" then
		values = {custom = "Custom", auto = "Auto", manual = "Manual"}
	elseif settingKey == "cooldown_precision" then
		values = {seconds = "Seconds", tenths = "Tenths"}
	elseif settingKey == "threat_algorithm" then
		values = {simple = "Simple", advanced = "Advanced"}
	elseif settingKey == "log_detail_level" then
		values = {basic = "Basic", medium = "Medium", detailed = "Detailed"}
	elseif settingKey == "voice_provider" then
		values = {discord = "Discord", teamspeak = "TeamSpeak", skype = "Skype", none = "None"}
	elseif settingKey == "frame_size" then
		values = {small = "Small", medium = "Medium", large = "Large"}
	elseif settingKey == "accuracy_mode" then
		values = {conservative = "Conservative", moderate = "Moderate", aggressive = "Aggressive"}
	elseif settingKey == "map_size" then
		values = {small = "Small", medium = "Medium", large = "Large"}
	else
		-- Generic values
		values = {
			["true"] = "Enabled",
			["false"] = "Disabled",
			yes = "Yes",
			no = "No",
		}
	end

	return values
end

-- ===========================
-- INTEGRATION WITH ACE3CONFIG
-- ===========================

function FeatureConfig:OnInitialize()
	-- Register features options after a short delay to ensure Features module is loaded
	Arenamaster:ScheduleTimer(function()
		self:RegisterFeaturesOptions()
	end, 1)
end

function FeatureConfig:RegisterFeaturesOptions()
	local AceConfigDialog = LibStub("AceConfigDialog-3.0")
	local featuresOptions = self:GenerateFeaturesOptionsTable()

	-- Register in the main options
	AceConfig:RegisterOptionsTable("Arenamaster_Features", featuresOptions)
	AceConfigDialog:AddToBlizOptions("Arenamaster_Features", "⚔️ Features", "Arenamaster")

	Arenamaster:PrintDebug("Features configuration registered")
end

function FeatureConfig:OnEnable()
	self:RegisterEvent("ADDON_LOADED")
end

-- ===========================
-- FEATURE TEMPLATES FOR EASY ADDING
-- ===========================

-- Template for adding new features
function FeatureConfig:CreateFeatureTemplate(id, name, category, description, icon, defaultSettings)
	return {
		id = id,
		name = name,
		category = category,
		description = description,
		icon = icon or "⚙️",
		enabled = true,
		settings = defaultSettings or {}
	}
end

-- ===========================
-- SYNC HELPERS
-- ===========================

function FeatureConfig:SyncNewSettings()
	-- Called when new features are added to sync them with config
	local Features = Arenamaster:GetModule("Features")
	if Features then
		Features:SyncFeaturesWithConfig()
		self:RegisterFeaturesOptions()
		print("|cff00ff00✓ All features synced with configuration|r")
	end
end

function FeatureConfig:ValidateAllSettings()
	-- Validate all feature settings are valid
	local Features = Arenamaster:GetModule("Features")
	if not Features then return end

	local status = Features:GetFeatureStatus()
	local issues = 0

	for featureId, info in pairs(status) do
		local settings = Features:GetFeatureSettings(featureId)
		if settings and next(settings) then
			-- Validate each setting has a value
			for key, value in pairs(settings) do
				if value == nil then
					issues = issues + 1
				end
			end
		end
	end

	if issues == 0 then
		print("|cff00ff00✓ All feature settings are valid|r")
	else
		print("|cffff0000✗ Found " .. issues .. " invalid settings|r")
	end

	return issues == 0
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function FeatureConfig:ADDON_LOADED(event, addon)
	if addon == "Arenamaster" then
		self:SyncNewSettings()
	end
end
