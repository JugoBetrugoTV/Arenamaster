-- Arenamaster: Simple Configuration UI Module
-- Professional, beautiful configuration window with AceGUI

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ConfigUI = Arenamaster:NewModule("ConfigUI", "AceEvent-3.0")

local AceGUI = LibStub("AceGUI-3.0")

local mainFrame = nil

-- ===========================
-- MAIN CONFIG WINDOW
-- ===========================

function ConfigUI:CreateBeautifulConfigWindow()
	if mainFrame then
		mainFrame:Show()
		return
	end

	mainFrame = AceGUI:Create("Frame")
	mainFrame:SetTitle("|cff00aaffArenamaster Configuration v2.0.0-Ace3|r")
	mainFrame:SetStatusText("Professional PvP Arena Assistant")
	mainFrame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
		mainFrame = nil
	end)
	mainFrame:SetLayout("Flow")
	mainFrame:SetWidth(900)
	mainFrame:SetHeight(600)
	mainFrame:SetPoint("CENTER")

	-- ===========================
	-- TITLE
	-- ===========================

	local title = AceGUI:Create("Label")
	title:SetText("|cff00aeff⚔️  ARENAMASTER CONFIGURATION  ⚔️|r")
	title:SetFont(nil, 16, "outline")
	title:SetFullWidth(true)
	title:SetHeight(40)
	mainFrame:AddChild(title)

	-- ===========================
	-- GENERAL SETTINGS
	-- ===========================

	local generalHeader = AceGUI:Create("Label")
	generalHeader:SetText("|cff4dabf7🎮 GENERAL SETTINGS|r")
	generalHeader:SetFont(nil, 14, "outline")
	generalHeader:SetFullWidth(true)
	mainFrame:AddChild(generalHeader)

	-- Enable/Disable
	local enabledCheckbox = AceGUI:Create("CheckBox")
	enabledCheckbox:SetLabel("Enable Addon")
	enabledCheckbox:SetValue(Arenamaster.db.profile.enabled ~= false)
	enabledCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.enabled = value
	end)
	enabledCheckbox:SetFullWidth(true)
	mainFrame:AddChild(enabledCheckbox)

	-- Debug Mode
	local debugCheckbox = AceGUI:Create("CheckBox")
	debugCheckbox:SetLabel("Debug Mode")
	debugCheckbox:SetValue(Arenamaster.db.profile.debugMode or false)
	debugCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.debugMode = value
	end)
	debugCheckbox:SetFullWidth(true)
	mainFrame:AddChild(debugCheckbox)

	-- ===========================
	-- FRAME SETTINGS
	-- ===========================

	local frameHeader = AceGUI:Create("Label")
	frameHeader:SetText("|cff4dabf7🖼️  ENEMY FRAMES|r")
	frameHeader:SetFont(nil, 14, "outline")
	frameHeader:SetFullWidth(true)
	mainFrame:AddChild(frameHeader)

	-- Show Enemy Frames
	local showFramesCheckbox = AceGUI:Create("CheckBox")
	showFramesCheckbox:SetLabel("Show Enemy Frames")
	showFramesCheckbox:SetValue(Arenamaster.db.profile.showEnemyFrames or true)
	showFramesCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.showEnemyFrames = value
	end)
	showFramesCheckbox:SetFullWidth(true)
	mainFrame:AddChild(showFramesCheckbox)

	-- Frame Opacity
	local opacitySlider = AceGUI:Create("Slider")
	opacitySlider:SetLabel("Frame Opacity")
	opacitySlider:SetSliderValues(0.1, 1.0, 0.05)
	opacitySlider:SetValue(Arenamaster.db.profile.enemyFrameOpacity or 0.9)
	opacitySlider:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.enemyFrameOpacity = value
	end)
	opacitySlider:SetFullWidth(true)
	mainFrame:AddChild(opacitySlider)

	-- Frame Scale
	local scaleSlider = AceGUI:Create("Slider")
	scaleSlider:SetLabel("Frame Scale")
	scaleSlider:SetSliderValues(0.5, 2.0, 0.1)
	scaleSlider:SetValue(Arenamaster.db.profile.enemyFrameScale or 1.0)
	scaleSlider:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.enemyFrameScale = value
	end)
	scaleSlider:SetFullWidth(true)
	mainFrame:AddChild(scaleSlider)

	-- ===========================
	-- NOTIFICATIONS
	-- ===========================

	local notifHeader = AceGUI:Create("Label")
	notifHeader:SetText("|cff4dabf7🔔 NOTIFICATIONS|r")
	notifHeader:SetFont(nil, 14, "outline")
	notifHeader:SetFullWidth(true)
	mainFrame:AddChild(notifHeader)

	-- Enable Notifications
	local enableNotifCheckbox = AceGUI:Create("CheckBox")
	enableNotifCheckbox:SetLabel("Enable Notifications")
	enableNotifCheckbox:SetValue(Arenamaster.db.profile.enableNotifications or true)
	enableNotifCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.enableNotifications = value
	end)
	enableNotifCheckbox:SetFullWidth(true)
	mainFrame:AddChild(enableNotifCheckbox)

	-- Notification Volume
	local volumeSlider = AceGUI:Create("Slider")
	volumeSlider:SetLabel("Notification Volume")
	volumeSlider:SetSliderValues(0.0, 1.0, 0.05)
	volumeSlider:SetValue(Arenamaster.db.profile.notificationVolume or 0.7)
	volumeSlider:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.notificationVolume = value
	end)
	volumeSlider:SetFullWidth(true)
	mainFrame:AddChild(volumeSlider)

	-- ===========================
	-- ANALYTICS
	-- ===========================

	local analyticsHeader = AceGUI:Create("Label")
	analyticsHeader:SetText("|cff4dabf7📊 ANALYTICS|r")
	analyticsHeader:SetFont(nil, 14, "outline")
	analyticsHeader:SetFullWidth(true)
	mainFrame:AddChild(analyticsHeader)

	-- Track Statistics
	local trackStatsCheckbox = AceGUI:Create("CheckBox")
	trackStatsCheckbox:SetLabel("Track Match Statistics")
	trackStatsCheckbox:SetValue(Arenamaster.db.profile.trackStats or true)
	trackStatsCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
		Arenamaster.db.profile.trackStats = value
	end)
	trackStatsCheckbox:SetFullWidth(true)
	mainFrame:AddChild(trackStatsCheckbox)

	-- ===========================
	-- ACTIONS
	-- ===========================

	local spacer = AceGUI:Create("Label")
	spacer:SetText("")
	spacer:SetHeight(10)
	spacer:SetFullWidth(true)
	mainFrame:AddChild(spacer)

	local resetBtn = AceGUI:Create("Button")
	resetBtn:SetText("Reset All Settings to Default")
	resetBtn:SetFullWidth(true)
	resetBtn:SetHeight(30)
	resetBtn:SetCallback("OnClick", function()
		if Arenamaster.db then
			Arenamaster.db:ResetProfile()
			print("|cff00ff00✓ Settings reset to default!|r")
		end
	end)
	mainFrame:AddChild(resetBtn)

	mainFrame:Show()
end

-- ===========================
-- PUBLIC API
-- ===========================

function ConfigUI:OnInitialize()
	-- UI initialized
end

function ConfigUI:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
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

function ConfigUI:PLAYER_LOGIN()
	Arenamaster:PrintDebug("Beautiful ConfigUI loaded and ready")
end
