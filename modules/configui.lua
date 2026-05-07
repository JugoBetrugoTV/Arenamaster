-- Arenamaster: Beautiful Config UI Module
-- Wunderschönes grafisches Konfigurationsfenster mit AceGUI

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ConfigUI = Arenamaster:NewModule("ConfigUI", "AceEvent-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local mainFrame = nil

-- ===========================
-- INITIALIZATION
-- ===========================

function ConfigUI:OnInitialize()
	-- Initialize UI system
end

function ConfigUI:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
end

-- ===========================
-- UI CREATION
-- ===========================

function ConfigUI:CreateConfigWindow()
	if mainFrame then
		mainFrame:Show()
		return
	end

	mainFrame = AceGUI:Create("Frame")
	mainFrame:SetTitle("Arenamaster Configuration")
	mainFrame:SetStatusText("v2.0.0 - Ace3 Framework")
	mainFrame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
		mainFrame = nil
	end)
	mainFrame:SetLayout("Flow")
	mainFrame:SetWidth(900)
	mainFrame:SetHeight(700)

	-- Add header
	local header = AceGUI:Create("Heading")
	header:SetText("🎯 Arenamaster Configuration")
	mainFrame:AddChild(header)

	-- Add description
	local description = AceGUI:Create("Label")
	description:SetText("Configure your PvP arena addon settings")
	mainFrame:AddChild(description)

	-- Add open options button
	local openButton = AceGUI:Create("Button")
	openButton:SetText("Open Full Options")
	openButton:SetWidth(200)
	openButton:SetCallback("OnClick", function()
		AceConfigDialog:Open("Arenamaster")
	end)
	mainFrame:AddChild(openButton)

	-- Add presets section
	local presetHeader = AceGUI:Create("Heading")
	presetHeader:SetText("Quick Presets")
	mainFrame:AddChild(presetHeader)

	local presets = {
		{name = "Aggressive", desc = "Large frames, max visibility"},
		{name = "Competitive", desc = "Balanced setup"},
		{name = "Minimal", desc = "Minimal UI"},
	}

	for _, preset in ipairs(presets) do
		local btn = AceGUI:Create("Button")
		btn:SetText(preset.name)
		btn:SetWidth(150)
		btn:SetCallback("OnClick", function()
			Arenamaster_Config:ApplyPreset(preset.name)
			Arenamaster:PrintDebug("Preset: " .. preset.name)
		end)
		mainFrame:AddChild(btn)
	end

	-- Add reset button
	local resetBtn = AceGUI:Create("Button")
	resetBtn:SetText("Reset to Defaults")
	resetBtn:SetWidth(150)
	resetBtn:SetCallback("OnClick", function()
		Arenamaster_Config:ResetToDefaults()
	end)
	mainFrame:AddChild(resetBtn)

	mainFrame:Show()
end

function ConfigUI:ShowConfigWindow()
	self:CreateConfigWindow()
end

function ConfigUI:HideConfigWindow()
	if mainFrame then
		mainFrame:Hide()
	end
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function ConfigUI:PLAYER_LOGIN()
	Arenamaster:PrintDebug("ConfigUI module loaded")
end
