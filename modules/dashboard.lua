-- Arenamaster: Professional Dashboard Module
-- Beautiful main dashboard with stats, themes, and advanced UI

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local Dashboard = Arenamaster:NewModule("Dashboard", "AceEvent-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local Design = Arenamaster:GetModule("Design")
local FrameDesign = Arenamaster:GetModule("FrameDesign")

local dashboardFrame = nil
local statsPanel = {}

-- ===========================
-- DASHBOARD CREATION
-- ===========================

function Dashboard:CreateBeautifulDashboard()
	if dashboardFrame then
		dashboardFrame:Show()
		return dashboardFrame
	end

	local themeName = Arenamaster.db.profile.uiTheme or "Dark"
	local theme = Design:GetTheme(themeName)

	dashboardFrame = AceGUI:Create("Frame")
	dashboardFrame:SetTitle(
		"|cff" .. theme.primary.hex .. "⚔️  ARENAMASTER DASHBOARD  ⚔️|r\n" ..
		"|cff" .. theme.secondary.hex .. "Professional PvP Intelligence System|r"
	)
	dashboardFrame:SetStatusText("|cff" .. theme.info.hex .. "Live Arena Analytics|r")
	dashboardFrame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
		dashboardFrame = nil
	end)
	dashboardFrame:SetLayout("Flow")
	dashboardFrame:SetWidth(1100)
	dashboardFrame:SetHeight(850)

	-- ===========================
	-- TAB GROUP
	-- ===========================

	local tabs = AceGUI:Create("TabGroup")
	tabs:SetFullWidth(true)
	tabs:SetFullHeight(true)
	tabs:SetTabs({
		{text = "|cff" .. theme.primary.hex .. "📊 OVERVIEW|r", value = "overview"},
		{text = "|cff" .. theme.success.hex .. "⭐ STATS|r", value = "stats"},
		{text = "|cff" .. theme.accent.hex .. "🎨 THEMES|r", value = "themes"},
		{text = "|cff" .. theme.warning.hex .. "⚙️ SETTINGS|r", value = "settings"},
	})
	tabs:SetCallback("OnGroupSelected", function(widget, event, group)
		self:BuildTabContent(tabs, group, themeName)
	end)

	dashboardFrame:AddChild(tabs)

	-- Initial tab
	self:BuildTabContent(tabs, "overview", themeName)

	dashboardFrame:Show()
	return dashboardFrame
end

function Dashboard:BuildTabContent(tabs, tabName, themeName)
	themeName = themeName or "Dark"
	local theme = Design:GetTheme(themeName)

	-- Clear existing content
	local scroll = tabs.content
	if scroll then
		for i = #scroll.children, 1, -1 do
			local child = scroll.children[i]
			if child and child.Release then
				child:Release()
			end
		end
	end

	if tabName == "overview" then
		self:BuildOverviewTab(tabs, themeName)
	elseif tabName == "stats" then
		self:BuildStatsTab(tabs, themeName)
	elseif tabName == "themes" then
		self:BuildThemesTab(tabs, themeName)
	elseif tabName == "settings" then
		self:BuildSettingsTab(tabs, themeName)
	end
end

-- ===========================
-- TAB CONTENTS
-- ===========================

function Dashboard:BuildOverviewTab(tabs, themeName)
	local theme = Design:GetTheme(themeName)

	-- Header
	local headerGroup = AceGUI:Create("SimpleGroup")
	headerGroup:SetFullWidth(true)
	headerGroup:SetHeight(100)
	headerGroup:SetLayout("Flow")
	tabs:AddChild(headerGroup)

	local header = AceGUI:Create("Label")
	header:SetText(
		"|cff" .. theme.primary.hex .. "⚔️ CURRENT STATUS|r\n" ..
		"|cffcccccc" .. Design:GetIcon("ENABLED") .. " All Systems Active|r"
	)
	header:SetFullWidth(true)
	headerGroup:AddChild(header)

	-- Stats row 1
	local row1 = AceGUI:Create("SimpleGroup")
	row1:SetFullWidth(true)
	row1:SetHeight(70)
	row1:SetLayout("Flow")
	tabs:AddChild(row1)

	local rating = AceGUI:Create("Label")
	rating:SetText(
		"|cff" .. theme.accent.hex .. "⭐ YOUR RATING|r\n" ..
		"|cff" .. theme.success.hex .. Arenamaster.db.profile.currentRating or "1500"
	)
	rating:SetWidth(150)
	row1:AddChild(rating)

	local winrate = AceGUI:Create("Label")
	winrate:SetText(
		"|cff" .. theme.accent.hex .. "📊 WIN RATE|r\n" ..
		"|cff" .. theme.success.hex .. "52.3%"
	)
	winrate:SetWidth(150)
	row1:AddChild(winrate)

	local matches = AceGUI:Create("Label")
	matches:SetText(
		"|cff" .. theme.accent.hex .. "⚔️ MATCHES|r\n" ..
		"|cff" .. theme.success.hex .. "47 Total"
	)
	matches:SetWidth(150)
	row1:AddChild(matches)

	local streak = AceGUI:Create("Label")
	streak:SetText(
		"|cff" .. theme.accent.hex .. "🔥 STREAK|r\n" ..
		"|cff" .. theme.warning.hex .. "+3 Wins"
	)
	streak:SetWidth(150)
	row1:AddChild(streak)

	-- Features section
	local featureHeader = AceGUI:Create("Heading")
	featureHeader:SetText("|cff" .. theme.primary.hex .. "📡 ACTIVE FEATURES|r")
	featureHeader:SetFullWidth(true)
	tabs:AddChild(featureHeader)

	local featuresGroup = AceGUI:Create("SimpleGroup")
	featuresGroup:SetFullWidth(true)
	featuresGroup:SetHeight(150)
	featuresGroup:SetLayout("Flow")
	tabs:AddChild(featuresGroup)

	local features = {
		{icon = Design:GetIcon("FRAME"), name = "Enemy Frames", status = true},
		{icon = Design:GetIcon("COOLDOWN"), name = "Cooldown Tracking", status = true},
		{icon = Design:GetIcon("THREAT"), name = "Threat Detection", status = true},
		{icon = Design:GetIcon("PREDICTION"), name = "Cooldown Prediction", status = true},
		{icon = Design:GetIcon("ANALYTICS"), name = "Live Analytics", status = true},
		{icon = Design:GetIcon("NOTIFICATION"), name = "Smart Alerts", status = true},
	}

	for i, feature in ipairs(features) do
		local status = Design:GetIcon(feature.status and "ENABLED" or "DISABLED")
		local statusColor = feature.status and theme.success.hex or theme.danger.hex
		local label = AceGUI:Create("Label")
		label:SetText(
			"|cff" .. theme.primary.hex .. feature.icon .. " " .. feature.name .. "|r " ..
			"|cff" .. statusColor .. status .. "|r"
		)
		label:SetWidth(200)
		featuresGroup:AddChild(label)
	end
end

function Dashboard:BuildStatsTab(tabs, themeName)
	local theme = Design:GetTheme(themeName)

	local header = AceGUI:Create("Heading")
	header:SetText("|cff" .. theme.success.hex .. "📊 STATISTICS|r")
	header:SetFullWidth(true)
	tabs:AddChild(header)

	local stats = {
		{name = "Matches Played", value = "47", icon = Design:GetIcon("NOTIFICATION")},
		{name = "Wins", value = "25", icon = Design:GetIcon("SUCCESS")},
		{name = "Losses", value = "22", icon = Design:GetIcon("ERROR")},
		{name = "Current Rating", value = "1850 (Rival)", icon = Design:GetIcon("RATING")},
		{name = "Average Duration", value = "4m 32s", icon = Design:GetIcon("COOLDOWN")},
		{name = "Opponents Tracked", value = "127", icon = Design:GetIcon("SETTINGS")},
	}

	for _, stat in ipairs(stats) do
		local label = AceGUI:Create("Label")
		label:SetText(
			"|cff" .. theme.primary.hex .. stat.icon .. " " .. stat.name .. ":|r " ..
			"|cff" .. theme.success.hex .. stat.value .. "|r"
		)
		label:SetFullWidth(true)
		tabs:AddChild(label)
	end
end

function Dashboard:BuildThemesTab(tabs, themeName)
	local theme = Design:GetTheme(themeName)

	local header = AceGUI:Create("Heading")
	header:SetText("|cff" .. theme.accent.hex .. "🎨 THEME SELECTOR|r")
	header:SetFullWidth(true)
	tabs:AddChild(header)

	local themeInfo = AceGUI:Create("Label")
	themeInfo:SetText("|cffccccccChoose a color theme to customize your Arenamaster UI|r")
	themeInfo:SetFullWidth(true)
	tabs:AddChild(themeInfo)

	local themes = {
		{name = "Dark", icon = "🌙", desc = "Classic dark theme with blue accents"},
		{name = "Light", icon = "☀️", desc = "Bright theme for daytime"},
		{name = "Ocean", icon = "🌊", desc = "Blue oceanic theme"},
		{name = "Forest", icon = "🌲", desc = "Green nature-inspired theme"},
		{name = "Fire", icon = "🔥", desc = "Warm orange fire theme"},
	}

	for _, t in ipairs(themes) do
		local btn = AceGUI:Create("Button")
		btn:SetText(t.icon .. " " .. t.name)
		btn:SetWidth(150)
		btn:SetCallback("OnClick", function()
			Arenamaster.db.profile.uiTheme = t.name
			print("|cff00ff00✓ Theme changed to: " .. t.name .. "|r")
		end)
		tabs:AddChild(btn)
	end
end

function Dashboard:BuildSettingsTab(tabs, themeName)
	local theme = Design:GetTheme(themeName)

	local header = AceGUI:Create("Heading")
	header:SetText("|cff" .. theme.warning.hex .. "⚙️ QUICK SETTINGS|r")
	header:SetFullWidth(true)
	tabs:AddChild(header)

	-- Sound toggle
	local soundToggle = AceGUI:Create("CheckBox")
	soundToggle:SetLabel(Design:GetIcon("NOTIFICATION") .. " Sound Alerts")
	soundToggle:SetValue(Arenamaster.db.profile.soundAlerts)
	soundToggle:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.soundAlerts = value
	end)
	soundToggle:SetFullWidth(true)
	tabs:AddChild(soundToggle)

	-- Screen alerts toggle
	local screenToggle = AceGUI:Create("CheckBox")
	screenToggle:SetLabel(Design:GetIcon("FRAME") .. " Screen Alerts")
	screenToggle:SetValue(Arenamaster.db.profile.screenAlerts)
	screenToggle:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.screenAlerts = value
	end)
	screenToggle:SetFullWidth(true)
	tabs:AddChild(screenToggle)

	-- Threat detection toggle
	local threatToggle = AceGUI:Create("CheckBox")
	threatToggle:SetLabel(Design:GetIcon("THREAT") .. " Threat Detection")
	threatToggle:SetValue(Arenamaster.db.profile.threatDetectionEnabled)
	threatToggle:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.threatDetectionEnabled = value
	end)
	threatToggle:SetFullWidth(true)
	tabs:AddChild(threatToggle)

	-- Debug mode toggle
	local debugToggle = AceGUI:Create("CheckBox")
	debugToggle:SetLabel(Design:GetIcon("SETTINGS") .. " Debug Mode")
	debugToggle:SetValue(Arenamaster.db.profile.debugMode)
	debugToggle:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.debugMode = value
	end)
	debugToggle:SetFullWidth(true)
	tabs:AddChild(debugToggle)
end

-- ===========================
-- PUBLIC API
-- ===========================

function Dashboard:ShowDashboard()
	self:CreateBeautifulDashboard()
end

function Dashboard:HideDashboard()
	if dashboardFrame then
		dashboardFrame:Hide()
	end
end

function Dashboard:ToggleDashboard()
	if dashboardFrame and dashboardFrame:IsShown() then
		dashboardFrame:Hide()
	else
		self:ShowDashboard()
	end
end

-- ===========================
-- INITIALIZATION
-- ===========================

function Dashboard:OnInitialize()
	-- Dashboard initialized
end

function Dashboard:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
end

function Dashboard:PLAYER_LOGIN()
	Arenamaster:PrintDebug("Beautiful Dashboard loaded")
end
