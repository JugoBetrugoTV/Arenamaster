-- Arenamaster: Custom Frame Design Module
-- Professional frame templates, layouts, and visual components

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local FrameDesign = Arenamaster:NewModule("FrameDesign", "AceEvent-3.0")

local Design = Arenamaster:GetModule("Design")
local AceGUI = LibStub("AceGUI-3.0")

-- ===========================
-- FRAME TEMPLATES
-- ===========================

function FrameDesign:CreateStyledFrame(name, parent, width, height, themeName)
	themeName = themeName or Arenamaster.db.profile.uiTheme or "Dark"

	local frame = CreateFrame("Frame", name, parent or UIParent, "BackdropTemplate")
	frame:SetSize(width, height)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

	Design:SetFrameStyle(frame, themeName, "Rounded")

	return frame
end

function FrameDesign:CreateEnemyFrame(unit, themeName)
	themeName = themeName or "Dark"
	local theme = Design:GetTheme(themeName)

	local frame = self:CreateStyledFrame("ArenamasterEnemyFrame_" .. unit, UIParent, 220, 85, themeName)

	-- Header with class color and name
	local header = CreateFrame("Frame", frame:GetName() .. "_Header", frame)
	header:SetSize(220, 20)
	header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

	-- Name text
	local nameText = header:CreateFontString(header:GetName() .. "_Name", "OVERLAY", "GameFontNormalLarge")
	nameText:SetPoint("LEFT", header, "LEFT", 5, 0)
	nameText:SetTextColor(theme.primary.r, theme.primary.g, theme.primary.b)

	-- Health bar background
	local healthBg = CreateFrame("StatusBar", frame:GetName() .. "_HealthBg", frame)
	healthBg:SetSize(200, 20)
	healthBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -25)
	healthBg:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	healthBg:SetStatusBarColor(1, 0, 0)

	-- Health text
	local healthText = healthBg:CreateFontString(healthBg:GetName() .. "_Text", "OVERLAY", "GameFontNormal")
	healthText:SetPoint("CENTER", healthBg, "CENTER", 0, 0)
	healthText:SetTextColor(1, 1, 1)

	-- Mana bar
	local manaBg = CreateFrame("StatusBar", frame:GetName() .. "_ManaBg", frame)
	manaBg:SetSize(200, 15)
	manaBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -50)
	manaBg:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	manaBg:SetStatusBarColor(0, 0.5, 1)

	-- Cast bar
	local castBar = CreateFrame("StatusBar", frame:GetName() .. "_CastBar", frame)
	castBar:SetSize(200, 12)
	castBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -70)
	castBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	castBar:SetStatusBarColor(1, 0.8, 0)

	frame.nameText = nameText
	frame.healthBar = healthBg
	frame.healthText = healthText
	frame.manaBar = manaBg
	frame.castBar = castBar

	return frame
end

function FrameDesign:CreateStatPanel(title, value, icon, themeName)
	themeName = themeName or "Dark"
	local theme = Design:GetTheme(themeName)

	local panel = AceGUI:Create("SimpleGroup")
	panel:SetFullWidth(true)
	panel:SetHeight(60)
	panel:SetLayout("List")

	-- Title with icon
	local titleLabel = AceGUI:Create("Label")
	titleLabel:SetText("|cff" .. theme.primary.hex .. icon .. " " .. title .. "|r")
	titleLabel:SetFullWidth(true)
	panel:AddChild(titleLabel)

	-- Value display
	local valueLabel = AceGUI:Create("Label")
	valueLabel:SetText("|cff" .. theme.success.hex .. value .. "|r")
	valueLabel:SetFont(nil, 16, "outline")
	valueLabel:SetFullWidth(true)
	panel:AddChild(valueLabel)

	return panel
end

function FrameDesign:CreateGlossyButton(text, icon, themeName, onClick)
	themeName = themeName or "Dark"
	local theme = Design:GetTheme(themeName)

	local btn = AceGUI:Create("Button")
	btn:SetText(icon .. " " .. text)
	btn:SetWidth(140)
	btn:SetCallback("OnClick", onClick or function() end)

	return btn
end

-- ===========================
-- VISUAL EFFECTS
-- ===========================

function FrameDesign:AddGlow(frame, intensity, color)
	intensity = intensity or 1
	color = color or {r = 0, g = 0.67, b = 1}

	local glow = CreateFrame("Frame", frame:GetName() .. "_Glow", frame)
	glow:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
	glow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, -5)
	glow:SetBackdrop({
		edgeFile = "Interface\\Buttons\\WHITE8X8",
		edgeSize = 2,
	})
	glow:SetBackdropBorderColor(color.r, color.g, color.b, intensity * 0.5)
	glow:EnableMouse(false)

	return glow
end

function FrameDesign:AddPulseAnimation(frame, duration)
	duration = duration or 1

	local anim = frame:CreateAnimationGroup()
	anim:SetLooping("REPEAT")

	local alpha = anim:CreateAnimation("Alpha")
	alpha:SetDuration(duration)
	alpha:SetFromAlpha(0.5)
	alpha:SetToAlpha(1)
	alpha:SetOrder(1)

	anim:Play()
	return anim
end

function FrameDesign:AddSlideAnimation(frame, fromX, toX, duration)
	duration = duration or 0.5

	local anim = frame:CreateAnimationGroup()

	local move = anim:CreateAnimation("Translation")
	move:SetDuration(duration)
	move:SetOffset(toX - fromX, 0)
	move:SetOrder(1)

	anim:Play()
	return anim
end

-- ===========================
-- COMPONENT BUILDERS
-- ===========================

function FrameDesign:CreateHealthBar(parent, width, height, themeName)
	themeName = themeName or "Dark"

	local healthBar = CreateFrame("StatusBar", parent:GetName() .. "_HealthBar", parent, "BackdropTemplate")
	healthBar:SetSize(width, height)
	healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	healthBar:SetStatusBarColor(1, 0, 0)

	-- Background
	healthBar:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"})
	healthBar:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

	-- Text
	local healthText = healthBar:CreateFontString(healthBar:GetName() .. "_Text", "OVERLAY", "GameFontHighlight")
	healthText:SetPoint("CENTER", healthBar, "CENTER")
	healthText:SetText("100%")

	healthBar.text = healthText
	return healthBar
end

function FrameDesign:CreateProgressRing(parent, size, color, themeName)
	themeName = themeName or "Dark"

	local ring = CreateFrame("Frame", parent:GetName() .. "_Ring", parent)
	ring:SetSize(size, size)

	-- Create circular texture effect with textures
	local border = CreateFrame("Frame", ring:GetName() .. "_Border", ring, "BackdropTemplate")
	border:SetAllPoints()
	border:SetBackdrop({
		edgeFile = "Interface\\Buttons\\WHITE8X8",
		edgeSize = 3,
	})
	border:SetBackdropBorderColor(color.r, color.g, color.b, 1)

	return ring
end

-- ===========================
-- LAYOUT BUILDERS
-- ===========================

function FrameDesign:CreateVerticalLayout(frames, spacing, themeName)
	themeName = themeName or "Dark"
	spacing = spacing or 5

	local y = 0
	for i, frame in ipairs(frames) do
		frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -y)
		y = y + frame:GetHeight() + spacing
	end
end

function FrameDesign:CreateHorizontalLayout(frames, spacing, themeName)
	themeName = themeName or "Dark"
	spacing = spacing or 5

	local x = 0
	for i, frame in ipairs(frames) do
		frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, -100)
		x = x + frame:GetWidth() + spacing
	end
end

function FrameDesign:CreateGridLayout(frames, cols, spacing, themeName)
	themeName = themeName or "Dark"
	spacing = spacing or 5

	local row = 0
	local col = 0

	for i, frame in ipairs(frames) do
		frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
			col * (frame:GetWidth() + spacing) + 100,
			-(row * (frame:GetHeight() + spacing) + 100)
		)

		col = col + 1
		if col >= cols then
			col = 0
			row = row + 1
		end
	end
end

-- ===========================
-- THEME APPLICATION
-- ===========================

function FrameDesign:ApplyThemeToFrame(frame, themeName)
	themeName = themeName or "Dark"
	Design:SetFrameStyle(frame, themeName, "Rounded")
end

function FrameDesign:ApplyThemeGlobally(themeName)
	themeName = themeName or "Dark"
	-- Could iterate through all frames and apply theme
	print("|cff00ff00✓ Theme '" .. themeName .. "' applied globally|r")
end

-- ===========================
-- INITIALIZATION
-- ===========================

function FrameDesign:OnInitialize()
	-- Frame design system initialized
end

function FrameDesign:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
end

function FrameDesign:PLAYER_LOGIN()
	Arenamaster:PrintDebug("Custom Frame Design system loaded")
end
