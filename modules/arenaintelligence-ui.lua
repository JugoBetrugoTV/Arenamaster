-- Arenamaster: Arena Intelligence UI Display Module
-- Displays DR status, interrupt predictions, and threat scores on enemy frames

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ArenaIntelligenceUI = Arenamaster:NewModule("ArenaIntelligenceUI", "AceEvent-3.0", "AceTimer-3.0")

local Design = Arenamaster:GetModule("Design")
local FrameDesign = Arenamaster:GetModule("FrameDesign")
local ArenaIntelligence = Arenamaster:GetModule("ArenaIntelligence")

-- Display elements cache
local drIndicators = {}
local threatIndicators = {}
local interruptPredictions = {}

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaIntelligenceUI:OnInitialize()
	drIndicators = {}
	threatIndicators = {}
	interruptPredictions = {}
end

function ArenaIntelligenceUI:OnEnable()
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
	self:ScheduleRepeatingTimer("UpdateDRDisplay", 0.2)
	self:ScheduleRepeatingTimer("UpdateThreatDisplay", 0.5)
	self:ScheduleRepeatingTimer("UpdateInterruptDisplay", 1.0)
end

-- ===========================
-- DR INDICATOR CREATION
-- ===========================

function ArenaIntelligenceUI:CreateDRIndicator(parent, unit)
	if drIndicators[unit] then
		return drIndicators[unit]
	end

	local indicator = CreateFrame("Frame", nil, parent)
	indicator:SetSize(120, 20)
	indicator:SetPoint("BOTTOM", parent, "TOP", 0, 5)

	-- Background
	indicator.bg = indicator:CreateTexture(nil, "BACKGROUND")
	indicator.bg:SetAllPoints()
	indicator.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

	-- Border
	indicator.border = indicator:CreateLine(nil, "ARTWORK")
	indicator.border:SetStartPoint("TOPLEFT", indicator)
	indicator.border:SetEndPoint("TOPRIGHT", indicator)
	indicator.border:SetThickness(1)
	indicator.border:SetColorTexture(0.3, 0.3, 0.3, 1)

	-- Text
	indicator.text = indicator:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	indicator.text:SetAllPoints()
	indicator.text:SetJustifyH("CENTER")
	indicator.text:SetJustifyV("MIDDLE")
	indicator.text:SetText("DR: 100%")

	drIndicators[unit] = indicator
	return indicator
end

function ArenaIntelligenceUI:UpdateDRDisplay()
	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) then
			local parent = _G["ArenamasterEnemyFrame" .. i]
			if not parent then return end

			if not drIndicators[unit] then
				self:CreateDRIndicator(parent, unit)
			end

			-- Get DR status for main CC chains (stun/root)
			local stunStatus = ArenaIntelligence:GetDRStatus(unit, "stun")
			local rootStatus = ArenaIntelligence:GetDRStatus(unit, "root")

			-- Show worst DR
			local worstPercent = math.min(tonumber(stunStatus.percentage) or 100, tonumber(rootStatus.percentage) or 100)
			local indicator = drIndicators[unit]

			if indicator then
				local color = self:GetDRColor(worstPercent)
				indicator.text:SetTextColor(color.r, color.g, color.b)
				indicator.text:SetText("|cffccccccDR:|r " .. worstPercent .. "%")

				-- Show background based on DR level
				if worstPercent < 50 then
					indicator.bg:SetColorTexture(0.5, 0.1, 0.1, 0.8)
				elseif worstPercent < 100 then
					indicator.bg:SetColorTexture(0.3, 0.2, 0.1, 0.8)
				else
					indicator.bg:SetColorTexture(0.1, 0.3, 0.1, 0.8)
				end
			end
		end
	end
end

-- ===========================
-- THREAT INDICATOR CREATION
-- ===========================

function ArenaIntelligenceUI:CreateThreatIndicator(parent, unit)
	if threatIndicators[unit] then
		return threatIndicators[unit]
	end

	local indicator = CreateFrame("Frame", nil, parent)
	indicator:SetSize(100, 16)
	indicator:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -5, -5)

	-- Background
	indicator.bg = indicator:CreateTexture(nil, "BACKGROUND")
	indicator.bg:SetAllPoints()
	indicator.bg:SetColorTexture(0.1, 0.1, 0.1, 0.9)

	-- Threat bar
	indicator.bar = indicator:CreateTexture(nil, "ARTWORK")
	indicator.bar:SetPoint("LEFT", indicator, "LEFT", 2, 0)
	indicator.bar:SetHeight(12)
	indicator.bar:SetColorTexture(0.8, 0.2, 0.2, 1)

	-- Icon
	indicator.icon = indicator:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	indicator.icon:SetPoint("LEFT", indicator, "LEFT", 3, 0)
	indicator.icon:SetText("⚠️")

	threatIndicators[unit] = indicator
	return indicator
end

function ArenaIntelligenceUI:UpdateThreatDisplay()
	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) then
			local parent = _G["ArenamasterEnemyFrame" .. i]
			if not parent then return end

			if not threatIndicators[unit] then
				self:CreateThreatIndicator(parent, unit)
			end

			local threat = ArenaIntelligence:CalculateAdvancedThreat(unit)
			local indicator = threatIndicators[unit]

			if indicator and threat then
				-- Update bar width based on threat percentage
				local barWidth = (threat.percentage / 100) * 90
				indicator.bar:SetWidth(barWidth)

				-- Update color based on threat level
				local color = self:GetThreatColor(threat.percentage)
				indicator.bar:SetColorTexture(color.r, color.g, color.b, 1)
			end
		end
	end
end

-- ===========================
-- INTERRUPT PREDICTION DISPLAY
-- ===========================

function ArenaIntelligenceUI:CreateInterruptPrediction(parent, unit)
	if interruptPredictions[unit] then
		return interruptPredictions[unit]
	end

	local container = CreateFrame("Frame", nil, parent)
	container:SetSize(120, 50)
	container:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, 10)

	-- Background
	container.bg = container:CreateTexture(nil, "BACKGROUND")
	container.bg:SetAllPoints()
	container.bg:SetColorTexture(0.05, 0.05, 0.1, 0.85)

	-- Border
	container.border = container:CreateLine(nil, "ARTWORK")
	container.border:SetStartPoint("TOPLEFT", container)
	container.border:SetEndPoint("TOPRIGHT", container)
	container.border:SetThickness(1)
	container.border:SetColorTexture(0.2, 0.4, 0.8, 1)

	-- Title
	container.title = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	container.title:SetPoint("TOP", container, "TOP", 0, -3)
	container.title:SetText("|cff4dabf7Interrupts|r")

	-- Interrupt lines (up to 3)
	for j = 1, 3 do
		local line = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		line:SetPoint("TOPLEFT", container, "TOPLEFT", 5, -15 - (j * 12))
		line:SetWidth(110)
		line:SetJustifyH("LEFT")
		line:SetText("")
		container["interrupt_" .. j] = line
	end

	interruptPredictions[unit] = container
	return container
end

function ArenaIntelligenceUI:UpdateInterruptDisplay()
	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) then
			local parent = _G["ArenamasterEnemyFrame" .. i]
			if not parent then return end

			if not interruptPredictions[unit] then
				self:CreateInterruptPrediction(parent, unit)
			end

			local container = interruptPredictions[unit]
			if container then
				-- Get prediction for common interrupts
				local interrupts = {"Kick", "Counterspell", "Pummel"}
				local displayCount = 0

				for j, spellName in ipairs(interrupts) do
					if displayCount < 3 then
						local prediction = ArenaIntelligence:PredictInterruptAvailability(unit, spellName)
						local line = container["interrupt_" .. j]

						if line and prediction then
							local status = prediction.available and "|cff00ff00✓|r" or "|cffff0000✗|r"
							local time = math.ceil(prediction.remainingTime)
							line:SetText(status .. " " .. spellName:sub(1, 8) .. ": " .. time .. "s")
							displayCount = displayCount + 1
						end
					end
				end
			end
		end
	end
end

-- ===========================
-- ANALYTICS PANEL
-- ===========================

function ArenaIntelligenceUI:CreateAnalyticsPanel(parent)
	local panel = CreateFrame("Frame", nil, parent)
	panel:SetSize(200, 120)
	panel:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, 10)

	-- Background
	panel.bg = panel:CreateTexture(nil, "BACKGROUND")
	panel.bg:SetAllPoints()
	panel.bg:SetColorTexture(0.05, 0.05, 0.1, 0.85)

	-- Border
	panel.border = panel:CreateLine(nil, "ARTWORK")
	panel.border:SetStartPoint("TOPLEFT", panel)
	panel.border:SetEndPoint("TOPRIGHT", panel)
	panel.border:SetThickness(1)
	panel.border:SetColorTexture(0.2, 0.8, 0.4, 1)

	-- Title
	panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	panel.title:SetPoint("TOP", panel, "TOP", 0, -3)
	panel.title:SetText("|cff4dabf7ANALYTICS|r")

	-- DPS line
	panel.dps = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	panel.dps:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -20)
	panel.dps:SetText("DPS: 0")

	-- HPS line
	panel.hps = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	panel.hps:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -35)
	panel.hps:SetText("HPS: 0")

	-- CC Applied line
	panel.cc = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	panel.cc:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -50)
	panel.cc:SetText("CCs: 0")

	-- Duration line
	panel.duration = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	panel.duration:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -65)
	panel.duration:SetText("Time: 0:00")

	return panel
end

-- ===========================
-- COLOR UTILITIES
-- ===========================

function ArenaIntelligenceUI:GetDRColor(percentage)
	if percentage >= 100 then
		return {r = 0.2, g = 0.8, b = 0.2}  -- Green - Full
	elseif percentage >= 75 then
		return {r = 0.8, g = 0.8, b = 0.2}  -- Yellow - 75%
	elseif percentage >= 50 then
		return {r = 0.8, g = 0.5, b = 0.2}  -- Orange - 50%
	elseif percentage >= 25 then
		return {r = 0.8, g = 0.2, b = 0.2}  -- Red - 25%
	else
		return {r = 0.5, g = 0.1, b = 0.1}  -- Dark red - Immune
	end
end

function ArenaIntelligenceUI:GetThreatColor(percentage)
	if percentage >= 75 then
		return {r = 1, g = 0.2, b = 0.2}  -- Bright red - Critical
	elseif percentage >= 50 then
		return {r = 0.8, g = 0.3, b = 0.2}  -- Orange - High
	elseif percentage >= 25 then
		return {r = 0.8, g = 0.6, b = 0.2}  -- Yellow - Medium
	else
		return {r = 0.3, g = 0.8, b = 0.3}  -- Green - Low
	end
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function ArenaIntelligenceUI:ARENA_MATCH_START()
	drIndicators = {}
	threatIndicators = {}
	interruptPredictions = {}
	Arenamaster:PrintDebug("Arena Intelligence UI initialized for new match")
end

function ArenaIntelligenceUI:ARENA_MATCH_END()
	for unit, _ in pairs(drIndicators) do
		if drIndicators[unit] then
			drIndicators[unit]:Hide()
		end
	end
	for unit, _ in pairs(threatIndicators) do
		if threatIndicators[unit] then
			threatIndicators[unit]:Hide()
		end
	end
	for unit, _ in pairs(interruptPredictions) do
		if interruptPredictions[unit] then
			interruptPredictions[unit]:Hide()
		end
	end
end

-- ===========================
-- DEBUG & VISUALIZATION
-- ===========================

function ArenaIntelligenceUI:PrintDRStatus()
	print("|cff00aiff═══════════════════════════════════════|r")
	print("|cff00aiff         DR STATUS REPORT              |r")
	print("|cff00aiff═══════════════════════════════════════|r")

	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) then
			local name = UnitName(unit)
			print("|cff4dabf7" .. name .. "|r")

			for _, chainType in ipairs({"stun", "root", "silence", "disorient"}) do
				local status = ArenaIntelligence:GetDRStatus(unit, chainType)
				print("  " .. chainType .. ": " .. status.percentage .. " (" .. status.applications .. " applications)")
			end
		end
	end
end

function ArenaIntelligenceUI:PrintThreatAssessment()
	print("|cff00aiff═══════════════════════════════════════|r")
	print("|cff00aiff      THREAT ASSESSMENT                |r")
	print("|cff00aiff═══════════════════════════════════════|r")

	for i = 1, 5 do
		local unit = "arena" .. i
		if UnitExists(unit) then
			local name = UnitName(unit)
			local threat = ArenaIntelligence:CalculateAdvancedThreat(unit)

			print("|cff4dabf7" .. name .. "|r - Threat: " .. threat.percentage .. "%")
			print("  Health: " .. math.floor(threat.factors.health) .. "%")
			print("  Offensive: " .. threat.factors.offensive .. "%")
			print("  Defensive: " .. threat.factors.defensive .. "%")
		end
	end
end
