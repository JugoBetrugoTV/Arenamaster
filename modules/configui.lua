-- Arenamaster: Stunning Configuration UI Module
-- Professional, beautiful configuration window with AceGUI

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ConfigUI = Arenamaster:NewModule("ConfigUI", "AceEvent-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local mainFrame = nil
local presetButtons = {}

-- ===========================
-- INITIALIZATION
-- ===========================

function ConfigUI:OnInitialize()
	-- UI initialized
end

function ConfigUI:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
end

-- ===========================
-- MAIN CONFIG WINDOW
-- ===========================

function ConfigUI:CreateBeautifulConfigWindow()
	if mainFrame then
		mainFrame:Show()
		return
	end

	mainFrame = AceGUI:Create("Frame")
	mainFrame:SetTitle("|cff00aaffArenamaster|r Configuration v|cff00ff002.0.0-Ace3|r")
	mainFrame:SetStatusText("Professional PvP Arena Assistant")
	mainFrame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
		mainFrame = nil
	end)
	mainFrame:SetLayout("Flow")
	mainFrame:SetWidth(1000)
	mainFrame:SetHeight(750)

	-- ===========================
	-- HEADER SECTION
	-- ===========================

	local headerGroup = AceGUI:Create("SimpleGroup")
	headerGroup:SetFullWidth(true)
	headerGroup:SetHeight(80)
	headerGroup:SetLayout("Flow")
	mainFrame:AddChild(headerGroup)

	-- Logo text
	local logoLabel = AceGUI:Create("Label")
	logoLabel:SetText("|cff00auff⚔️  ARENAMASTER  ⚔️|r")
	logoLabel:SetFont(nil, 16, "outline")
	logoLabel:SetFullWidth(true)
	headerGroup:AddChild(logoLabel)

	-- Description
	local descLabel = AceGUI:Create("Label")
	descLabel:SetText("|cffccccccElevate your PvP game with professional arena intelligence|r")
	descLabel:SetFont(nil, 12)
	descLabel:SetFullWidth(true)
	headerGroup:AddChild(descLabel)

	-- Version info
	local versionLabel = AceGUI:Create("Label")
	versionLabel:SetText("|cff4dabf7Version 2.0.0-Ace3  |  Full Ace3 Framework  |  124 Known Spells|r")
	versionLabel:SetFont(nil, 10)
	versionLabel:SetFullWidth(true)
	headerGroup:AddChild(versionLabel)

	-- ===========================
	-- QUICK PRESETS SECTION
	-- ===========================

	local presetsHeader = AceGUI:Create("Heading")
	presetsHeader:SetText("|cff00ffff⚡ QUICK PRESETS|r")
	presetsHeader:SetFullWidth(true)
	mainFrame:AddChild(presetsHeader)

	local presetGroup = AceGUI:Create("SimpleGroup")
	presetGroup:SetFullWidth(true)
	presetGroup:SetHeight(100)
	presetGroup:SetLayout("Flow")
	mainFrame:AddChild(presetGroup)

	-- Preset buttons
	local presets = {
		{
			name = "🔥 Aggressive",
			desc = "Large frames, max visibility\nPerfect for aggressive playstyle",
			key = "AGGRESSIVE"
		},
		{
			name = "⚔️ Competitive",
			desc = "Balanced setup for ranked\nOptimized for serious play",
			key = "COMPETITIVE"
		},
		{
			name = "🧘 Minimal",
			desc = "Clean, distraction-free\nLess UI, more focus",
			key = "MINIMAL"
		},
		{
			name = "📺 Streamer",
			desc = "Beautiful, stream-ready\nImpressive for audience",
			key = "STREAMER"
		},
	}

	for i, preset in ipairs(presets) do
		local btn = AceGUI:Create("Button")
		btn:SetText(preset.name)
		btn:SetWidth(200)
		btn:SetCallback("OnClick", function()
			self:ApplyPreset(preset.key)
		end)

		-- Add description as tooltip
		local tooltip = "|cff00auff" .. preset.name .. "|r\n" .. "|cffcccccc" .. preset.desc .. "|r"
		btn.userdata.tooltip = tooltip

		presetGroup:AddChild(btn)
		presetButtons[i] = btn
	end

	-- ===========================
	-- QUICK SETTINGS SECTION
	-- ===========================

	local quickHeader = AceGUI:Create("Heading")
	quickHeader:SetText("|cff00ff00🎯 QUICK SETTINGS|r")
	quickHeader:SetFullWidth(true)
	mainFrame:AddChild(quickHeader)

	-- Frame Layout
	local layoutLabel = AceGUI:Create("Label")
	layoutLabel:SetText("Frame Layout:")
	layoutLabel:SetWidth(100)
	mainFrame:AddChild(layoutLabel)

	local layoutDropdown = AceGUI:Create("Dropdown")
	layoutDropdown:SetList({
		vertical = "Vertical ⬇️",
		horizontal = "Horizontal ➡️",
		grid = "Grid 📊"
	})
	layoutDropdown:SetValue(Arenamaster.db.profile.frameLayout)
	layoutDropdown:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.frameLayout = value
		print("|cff00ff00✓ Layout changed to: " .. value .. "|r")
	end)
	layoutDropdown:SetWidth(150)
	mainFrame:AddChild(layoutDropdown)

	-- Frame Opacity
	local opacityLabel = AceGUI:Create("Label")
	opacityLabel:SetText("Opacity:")
	opacityLabel:SetWidth(80)
	mainFrame:AddChild(opacityLabel)

	local opacitySlider = AceGUI:Create("Slider")
	opacitySlider:SetSliderValues(0.1, 1, 0.05)
	opacitySlider:SetValue(Arenamaster.db.profile.frameOpacity)
	opacitySlider:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.frameOpacity = value
	end)
	opacitySlider:SetWidth(150)
	mainFrame:AddChild(opacitySlider)

	-- Sound Alerts Toggle
	local soundToggle = AceGUI:Create("CheckBox")
	soundToggle:SetLabel("🔊 Sound Alerts")
	soundToggle:SetValue(Arenamaster.db.profile.soundAlerts)
	soundToggle:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.soundAlerts = value
	end)
	soundToggle:SetWidth(150)
	mainFrame:AddChild(soundToggle)

	-- ===========================
	-- THEME SECTION
	-- ===========================

	local themeHeader = AceGUI:Create("Heading")
	themeHeader:SetText("|cff9775fa🎨 APPEARANCE|r")
	themeHeader:SetFullWidth(true)
	mainFrame:AddChild(themeHeader)

	local themeLabel = AceGUI:Create("Label")
	themeLabel:SetText("Color Theme:")
	themeLabel:SetWidth(100)
	mainFrame:AddChild(themeLabel)

	local themeDropdown = AceGUI:Create("Dropdown")
	themeDropdown:SetList({
		Dark = "🌙 Dark",
		Light = "☀️ Light",
		Ocean = "🌊 Ocean",
		Forest = "🌲 Forest",
		Fire = "🔥 Fire"
	})
	themeDropdown:SetValue(Arenamaster.db.profile.uiTheme)
	themeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.uiTheme = value
		print("|cff00ff00✓ Theme changed to: " .. value .. "|r")
	end)
	themeDropdown:SetWidth(150)
	mainFrame:AddChild(themeDropdown)

	-- Font Size
	local fontLabel = AceGUI:Create("Label")
	fontLabel:SetText("Font Size:")
	fontLabel:SetWidth(80)
	mainFrame:AddChild(fontLabel)

	local fontSlider = AceGUI:Create("Slider")
	fontSlider:SetSliderValues(8, 18, 1)
	fontSlider:SetValue(Arenamaster.db.profile.fontSize)
	fontSlider:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.fontSize = value
	end)
	fontSlider:SetWidth(150)
	mainFrame:AddChild(fontSlider)

	-- ===========================
	-- ADVANCED OPTIONS BUTTON
	-- ===========================

	local advancedGroup = AceGUI:Create("SimpleGroup")
	advancedGroup:SetFullWidth(true)
	advancedGroup:SetHeight(50)
	advancedGroup:SetLayout("Flow")
	mainFrame:AddChild(advancedGroup)

	local advancedBtn = AceGUI:Create("Button")
	advancedBtn:SetText("🔧 Advanced Options")
	advancedBtn:SetWidth(200)
	advancedBtn:SetCallback("OnClick", function()
		AceConfigDialog:Open("Arenamaster")
		if mainFrame then
			mainFrame:Hide()
		end
	end)
	advancedGroup:AddChild(advancedBtn)

	-- Reset button
	local resetBtn = AceGUI:Create("Button")
	resetBtn:SetText("↺ Reset to Defaults")
	resetBtn:SetWidth(200)
	resetBtn:SetCallback("OnClick", function()
		Arenamaster.db:ResetProfile()
		print("|cff00ff00✓ Configuration reset to defaults|r")
		mainFrame:Hide()
		self:CreateBeautifulConfigWindow()
	end)
	advancedGroup:AddChild(resetBtn)

	-- ===========================
	-- INFO FOOTER
	-- ===========================

	local footerGroup = AceGUI:Create("SimpleGroup")
	footerGroup:SetFullWidth(true)
	footerGroup:SetHeight(60)
	footerGroup:SetLayout("Flow")
	mainFrame:AddChild(footerGroup)

	local infoLabel = AceGUI:Create("Label")
	infoLabel:SetText(
		"|cff4dabf7Need help?|r Type |cffff00ff/am help|r for commands\n" ..
		"|cffccccccFor detailed configuration, use |cffff00ffAdvanced Options|r"
	)
	infoLabel:SetFullWidth(true)
	footerGroup:AddChild(infoLabel)

	mainFrame:Show()
end

-- ===========================
-- UTILITY FUNCTIONS
-- ===========================

function ConfigUI:ApplyPreset(presetName)
	-- Presets are defined in config module
	local ConfigModule = Arenamaster:GetModule("Config")
	if ConfigModule then
		ConfigModule:ApplyPreset(presetName)
		print("|cff00ff00✓ Preset '" .. presetName .. "' applied!|r")
	end
end

function ConfigUI:ShowConfigWindow()
	self:CreateBeautifulConfigWindow()
end

function ConfigUI:HideConfigWindow()
	if mainFrame then
		mainFrame:Hide()
	end
end

function ConfigUI:ToggleConfigWindow()
	if mainFrame and mainFrame:IsShown() then
		mainFrame:Hide()
	else
		self:ShowConfigWindow()
	end
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function ConfigUI:PLAYER_LOGIN()
	Arenamaster:PrintDebug("Beautiful ConfigUI loaded and ready")
end
