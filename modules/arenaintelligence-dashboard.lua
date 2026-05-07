-- Arenamaster: Arena Intelligence Dashboard Integration
-- Beautiful dashboard tabs and displays for Arena Intelligence data

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ArenaIntelligenceDashboard = Arenamaster:NewModule("ArenaIntelligenceDashboard", "AceEvent-3.0")

local Design = Arenamaster:GetModule("Design")
local Dashboard = Arenamaster:GetModule("Dashboard")
local ArenaIntelligence = Arenamaster:GetModule("ArenaIntelligence")
local ArenaIntelligenceStats = Arenamaster:GetModule("ArenaIntelligenceStats")
local AceGUI = LibStub("AceGUI-3.0")

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaIntelligenceDashboard:OnInitialize()
	-- Initialize dashboard panels
end

function ArenaIntelligenceDashboard:OnEnable()
	self:RegisterEvent("ADDON_LOADED")
end

-- ===========================
-- DASHBOARD TAB BUILDERS
-- ===========================

function ArenaIntelligenceDashboard:BuildIntelligenceTab(tabs, themeName)
	if not Dashboard then return end

	themeName = themeName or "Dark"
	local theme = Design:GetTheme(themeName)

	-- Title
	local titleGroup = AceGUI:Create("SimpleGroup")
	titleGroup:SetFullWidth(true)
	titleGroup:SetHeight(40)
	titleGroup:SetLayout("Flow")
	tabs:AddChild(titleGroup)

	local title = AceGUI:Create("Label")
	title:SetText("|cff" .. theme.primary.hex .. "🧠 ARENA INTELLIGENCE|r")
	title:SetFullWidth(true)
	title:SetFontObject("GameFontNormalLarge")
	titleGroup:AddChild(title)

	-- Current Match Stats
	local statsGroup = AceGUI:Create("SimpleGroup")
	statsGroup:SetFullWidth(true)
	statsGroup:SetHeight(100)
	statsGroup:SetLayout("Flow")
	statsGroup:SetTitle("|cff" .. theme.accent.hex .. "📊 CURRENT MATCH|r")
	tabs:AddChild(statsGroup)

	local stats = ArenaIntelligence and ArenaIntelligence:GetMatchStats() or {}
	local dps = ArenaIntelligence and ArenaIntelligence:GetDPS() or 0
	local hps = ArenaIntelligence and ArenaIntelligence:GetHPS() or 0

	local dpsLabel = AceGUI:Create("Label")
	dpsLabel:SetText("|cff4dabf7DPS:|r " .. dps)
	dpsLabel:SetWidth(150)
	statsGroup:AddChild(dpsLabel)

	local hpsLabel = AceGUI:Create("Label")
	hpsLabel:SetText("|cff4dabf7HPS:|r " .. hps)
	hpsLabel:SetWidth(150)
	statsGroup:AddChild(hpsLabel)

	local ccAppliedLabel = AceGUI:Create("Label")
	ccAppliedLabel:SetText("|cff4dabf7CCs Applied:|r " .. (stats.ccsApplied or 0))
	ccAppliedLabel:SetWidth(150)
	statsGroup:AddChild(ccAppliedLabel)

	local damageLabel = AceGUI:Create("Label")
	damageLabel:SetText("|cff4dabf7Damage Dealt:|r " .. (stats.damageDealt or 0))
	damageLabel:SetWidth(150)
	statsGroup:AddChild(damageLabel)

	-- DR Status Group
	local drGroup = AceGUI:Create("SimpleGroup")
	drGroup:SetFullWidth(true)
	drGroup:SetHeight(80)
	drGroup:SetLayout("Flow")
	drGroup:SetTitle("|cff4dabf7📉 DIMINISHING RETURNS|r")
	tabs:AddChild(drGroup)

	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) then
			local name = UnitName(unit)
			local stunStatus = ArenaIntelligence and ArenaIntelligence:GetDRStatus(unit, "stun") or {}

			local drLabel = AceGUI:Create("Label")
			drLabel:SetText("|cffcccccc" .. (name or "Arena " .. i) .. ":|r " .. (stunStatus.percentage or "100%"))
			drLabel:SetWidth(120)
			drGroup:AddChild(drLabel)
		end
	end

	-- Threat Assessment Group
	local threatGroup = AceGUI:Create("SimpleGroup")
	threatGroup:SetFullWidth(true)
	threatGroup:SetHeight(80)
	threatGroup:SetLayout("Flow")
	threatGroup:SetTitle("|cff" .. theme.warning.hex .. "⚠️ THREAT ASSESSMENT|r")
	tabs:AddChild(threatGroup)

	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) then
			local name = UnitName(unit)
			local threat = ArenaIntelligence and ArenaIntelligence:CalculateAdvancedThreat(unit) or {percentage = 0}

			local threatLabel = AceGUI:Create("Label")
			local threatColor = self:GetThreatColor(threat.percentage)
			threatLabel:SetText("|cff" .. threatColor .. name .. ": " .. threat.percentage .. "%|r")
			threatLabel:SetWidth(120)
			threatGroup:AddChild(threatLabel)
		end
	end
end

function ArenaIntelligenceDashboard:BuildHistoryTab(tabs, themeName)
	themeName = themeName or "Dark"
	local theme = Design:GetTheme(themeName)

	-- Title
	local titleGroup = AceGUI:Create("SimpleGroup")
	titleGroup:SetFullWidth(true)
	titleGroup:SetHeight(40)
	titleGroup:SetLayout("Flow")
	tabs:AddChild(titleGroup)

	local title = AceGUI:Create("Label")
	title:SetText("|cff" .. theme.primary.hex .. "📈 MATCH HISTORY & STATISTICS|r")
	title:SetFullWidth(true)
	title:SetFontObject("GameFontNormalLarge")
	titleGroup:AddChild(title)

	-- Statistics Summary
	local statsGroup = AceGUI:Create("SimpleGroup")
	statsGroup:SetFullWidth(true)
	statsGroup:SetHeight(120)
	statsGroup:SetLayout("Flow")
	statsGroup:SetTitle("|cff" .. theme.accent.hex .. "📊 PERFORMANCE AVERAGES|r")
	tabs:AddChild(statsGroup)

	local avgStats = ArenaIntelligenceStats and ArenaIntelligenceStats:GetAverageStats() or {}
	local peakStats = ArenaIntelligenceStats and ArenaIntelligenceStats:GetPeakPerformance() or {}

	local matchesLabel = AceGUI:Create("Label")
	matchesLabel:SetText("|cff4dabf7Matches:|r " .. (avgStats.matches or 0))
	matchesLabel:SetWidth(150)
	statsGroup:AddChild(matchesLabel)

	local avgDpsLabel = AceGUI:Create("Label")
	avgDpsLabel:SetText("|cff4dabf7Avg DPS:|r " .. (avgStats.avgDps or 0))
	avgDpsLabel:SetWidth(150)
	statsGroup:AddChild(avgDpsLabel)

	local avgHpsLabel = AceGUI:Create("Label")
	avgHpsLabel:SetText("|cff4dabf7Avg HPS:|r " .. (avgStats.avgHps or 0))
	avgHpsLabel:SetWidth(150)
	statsGroup:AddChild(avgHpsLabel)

	local efficiencyLabel = AceGUI:Create("Label")
	efficiencyLabel:SetText("|cff4dabf7Avg Efficiency:|r " .. (avgStats.avgEfficiency or 0))
	efficiencyLabel:SetWidth(150)
	statsGroup:AddChild(efficiencyLabel)

	-- Peak Performance
	local peakGroup = AceGUI:Create("SimpleGroup")
	peakGroup:SetFullWidth(true)
	peakGroup:SetHeight(80)
	peakGroup:SetLayout("Flow")
	peakGroup:SetTitle("|cff" .. theme.success.hex .. "🏆 PEAK PERFORMANCE|r")
	tabs:AddChild(peakGroup)

	local peakDpsLabel = AceGUI:Create("Label")
	peakDpsLabel:SetText("|cff4dabf7Peak DPS:|r " .. (peakStats.peakDps or 0))
	peakDpsLabel:SetWidth(150)
	peakGroup:AddChild(peakDpsLabel)

	local peakHpsLabel = AceGUI:Create("Label")
	peakHpsLabel:SetText("|cff4dabf7Peak HPS:|r " .. (peakStats.peakHps or 0))
	peakHpsLabel:SetWidth(150)
	peakGroup:AddChild(peakHpsLabel)

	local peakDamageLabel = AceGUI:Create("Label")
	local peakDmgFormatted = peakStats.peakDamage and (peakStats.peakDamage >= 1000 and string.format("%.1fK", peakStats.peakDamage/1000) or peakStats.peakDamage) or "0"
	peakDamageLabel:SetText("|cff4dabf7Peak Damage:|r " .. peakDmgFormatted)
	peakDamageLabel:SetWidth(150)
	peakGroup:AddChild(peakDamageLabel)

	-- Rating Trend
	local trendLabel = AceGUI:Create("Label")
	local trendDir = ArenaIntelligenceStats and ArenaIntelligenceStats:GetTrendDirection() or "📊 Neutral"
	trendLabel:SetText("|cff4dabf7Trend:|r " .. trendDir)
	trendLabel:SetWidth(150)
	peakGroup:AddChild(trendLabel)
end

-- ===========================
-- COLOR UTILITIES
-- ===========================

function ArenaIntelligenceDashboard:GetThreatColor(percentage)
	if percentage >= 75 then
		return "ff3333"  -- Bright red
	elseif percentage >= 50 then
		return "ff8833"  -- Orange
	elseif percentage >= 25 then
		return "ffff00"  -- Yellow
	else
		return "33ff33"  -- Green
	end
end

-- ===========================
-- INTEGRATION WITH DASHBOARD
-- ===========================

function ArenaIntelligenceDashboard:RegisterDashboardTabs()
	if not Dashboard or not Dashboard.BuildTabContent then
		return
	end

	-- Hook into the dashboard tab system
	-- Note: This would require modifying the dashboard module to support additional tabs
	-- For now, we provide the tab builders for manual integration
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function ArenaIntelligenceDashboard:ADDON_LOADED(event, addon)
	if addon == "Arenamaster" then
		self:RegisterDashboardTabs()
	end
end

-- ===========================
-- PUBLIC API
-- ===========================

function ArenaIntelligenceDashboard:GetIntelligenceTabBuilder()
	return function(tabs, themeName)
		self:BuildIntelligenceTab(tabs, themeName)
	end
end

function ArenaIntelligenceDashboard:GetHistoryTabBuilder()
	return function(tabs, themeName)
		self:BuildHistoryTab(tabs, themeName)
	end
end
