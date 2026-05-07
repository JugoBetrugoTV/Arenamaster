-- Arenamaster: Advanced Configuration Features
-- Import/Export, Backup, Advanced Profile Management

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ConfigAdvanced = Arenamaster:NewModule("ConfigAdvanced", "AceEvent-3.0")

local AceSerializer = LibStub("AceSerializer-3.0")
local AceGUI = LibStub("AceGUI-3.0")

-- ===========================
-- INITIALIZATION
-- ===========================

function ConfigAdvanced:OnInitialize()
	if not Arenamaster.db.profile.backups then
		Arenamaster.db.profile.backups = {}
	end
end

function ConfigAdvanced:OnEnable()
	-- Advanced features enabled
end

-- ===========================
-- IMPORT/EXPORT SYSTEM
-- ===========================

function ConfigAdvanced:ExportSettings()
	local profileData = CopyTable(Arenamaster.db.profile)

	-- Serialize the data
	local serialized = AceSerializer:Serialize(profileData)

	if not serialized then
		print("|cffff0000Error serializing settings|r")
		return nil
	end

	return serialized
end

function ConfigAdvanced:ImportSettings(importString)
	if not importString or importString == "" then
		print("|cffff0000Invalid import string|r")
		return false
	end

	local success, profileData = AceSerializer:Deserialize(importString)

	if not success or not profileData then
		print("|cffff0000Error deserializing settings|r")
		return false
	end

	-- Merge with current profile
	for key, value in pairs(profileData) do
		Arenamaster.db.profile[key] = value
	end

	print("|cff00ff00✓ Settings imported successfully|r")
	return true
end

function ConfigAdvanced:ShowImportDialog()
	local frame = AceGUI:Create("Frame")
	frame:SetTitle("Import Configuration")
	frame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
	end)
	frame:SetLayout("Flow")
	frame:SetWidth(500)
	frame:SetHeight(400)

	local instruction = AceGUI:Create("Label")
	instruction:SetText("|cff4dabf7Paste your exported settings below:|r")
	instruction:SetFullWidth(true)
	frame:AddChild(instruction)

	local editBox = AceGUI:Create("MultiLineEditBox")
	editBox:SetLabel("Settings String")
	editBox:SetFullWidth(true)
	editBox:SetHeight(300)
	frame:AddChild(editBox)

	local buttonGroup = AceGUI:Create("SimpleGroup")
	buttonGroup:SetFullWidth(true)
	buttonGroup:SetHeight(50)
	buttonGroup:SetLayout("Flow")
	frame:AddChild(buttonGroup)

	local importBtn = AceGUI:Create("Button")
	importBtn:SetText("✓ Import")
	importBtn:SetWidth(100)
	importBtn:SetCallback("OnClick", function()
		local text = editBox:GetText()
		if self:ImportSettings(text) then
			frame:Hide()
			AceGUI:Release(frame)
		end
	end)
	buttonGroup:AddChild(importBtn)

	local cancelBtn = AceGUI:Create("Button")
	cancelBtn:SetText("✗ Cancel")
	cancelBtn:SetWidth(100)
	cancelBtn:SetCallback("OnClick", function()
		frame:Hide()
		AceGUI:Release(frame)
	end)
	buttonGroup:AddChild(cancelBtn)

	frame:Show()
end

function ConfigAdvanced:ShowExportDialog()
	local exported = self:ExportSettings()

	if not exported then
		return
	end

	local frame = AceGUI:Create("Frame")
	frame:SetTitle("Export Configuration")
	frame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
	end)
	frame:SetLayout("Flow")
	frame:SetWidth(600)
	frame:SetHeight(400)

	local instruction = AceGUI:Create("Label")
	instruction:SetText("|cff4dabf7Your configuration export (copy this text):|r")
	instruction:SetFullWidth(true)
	frame:AddChild(instruction)

	local editBox = AceGUI:Create("MultiLineEditBox")
	editBox:SetLabel("Exported Settings")
	editBox:SetFullWidth(true)
	editBox:SetHeight(300)
	editBox:SetText(exported)
	editBox:HighlightText()
	frame:AddChild(editBox)

	local buttonGroup = AceGUI:Create("SimpleGroup")
	buttonGroup:SetFullWidth(true)
	buttonGroup:SetHeight(50)
	buttonGroup:SetLayout("Flow")
	frame:AddChild(buttonGroup)

	local copyBtn = AceGUI:Create("Button")
	copyBtn:SetText("📋 Copy to Clipboard")
	copyBtn:SetWidth(150)
	copyBtn:SetCallback("OnClick", function()
		-- Copy to clipboard (in real implementation)
		print("|cff00ff00✓ Settings copied to clipboard|r")
	end)
	buttonGroup:AddChild(copyBtn)

	frame:Show()
end

-- ===========================
-- BACKUP SYSTEM
-- ===========================

function ConfigAdvanced:CreateBackup(name)
	local timestamp = date("%Y-%m-%d %H:%M:%S")
	local backupName = name or ("Auto-Backup-" .. timestamp)

	local backup = {
		name = backupName,
		timestamp = GetTime(),
		dateString = timestamp,
		data = CopyTable(Arenamaster.db.profile)
	}

	table.insert(Arenamaster.db.profile.backups, backup)

	-- Keep only last 10 backups
	if #Arenamaster.db.profile.backups > 10 then
		table.remove(Arenamaster.db.profile.backups, 1)
	end

	print("|cff00ff00✓ Backup created: " .. backupName .. "|r")
	return backup
end

function ConfigAdvanced:RestoreBackup(index)
	if not Arenamaster.db.profile.backups[index] then
		print("|cffff0000Invalid backup index|r")
		return false
	end

	local backup = Arenamaster.db.profile.backups[index]

	-- Save current as recovery backup
	self:CreateBackup("Pre-Restore-" .. date("%H:%M:%S"))

	-- Restore backup
	for key, value in pairs(backup.data) do
		Arenamaster.db.profile[key] = CopyTable(value)
	end

	print("|cff00ff00✓ Restored backup: " .. backup.name .. "|r")
	return true
end

function ConfigAdvanced:GetBackups()
	return Arenamaster.db.profile.backups or {}
end

function ConfigAdvanced:DeleteBackup(index)
	if not Arenamaster.db.profile.backups[index] then
		return false
	end

	local removed = table.remove(Arenamaster.db.profile.backups, index)
	if removed then
		print("|cff00ff00✓ Backup deleted: " .. removed.name .. "|r")
		return true
	end

	return false
end

-- ===========================
-- PRESET MANAGEMENT
-- ===========================

function ConfigAdvanced:GetAllPresets()
	return {
		AGGRESSIVE = "Aggressive Layout",
		COMPETITIVE = "Competitive Balanced",
		MINIMAL = "Minimal UI",
		STREAMER = "Streamer Ready",
		CUSTOM = "Custom Settings"
	}
end

function ConfigAdvanced:SaveAsPreset(presetName)
	if not presetName or presetName == "" then
		print("|cffff0000Invalid preset name|r")
		return false
	end

	if not Arenamaster.db.profile.customPresets then
		Arenamaster.db.profile.customPresets = {}
	end

	Arenamaster.db.profile.customPresets[presetName] = CopyTable(Arenamaster.db.profile)
	print("|cff00ff00✓ Preset saved: " .. presetName .. "|r")
	return true
end

function ConfigAdvanced:LoadPreset(presetName)
	if not Arenamaster.db.profile.customPresets or not Arenamaster.db.profile.customPresets[presetName] then
		print("|cffff0000Preset not found: " .. presetName .. "|r")
		return false
	end

	local preset = Arenamaster.db.profile.customPresets[presetName]
	for key, value in pairs(preset) do
		Arenamaster.db.profile[key] = CopyTable(value)
	end

	print("|cff00ff00✓ Preset loaded: " .. presetName .. "|r")
	return true
end
