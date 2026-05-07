-- Arenamaster: Minimap Icon Module
-- Adds a convenient minimap button to open the addon

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local MinimapIcon = Arenamaster:NewModule("MinimapIcon")

local icon_data = {
	id = "Arenamaster",
	title = "Arenamaster",
	notes = "PvP Arena Assistant - Click to open config",
	icon = "Interface\\Icons\\inv_misc_tournament_banner",
	OnClick = function(_, button)
		if button == "LeftButton" then
			local ConfigUI = Arenamaster:GetModule("ConfigUI")
			if ConfigUI then
				ConfigUI:ShowConfigWindow()
			else
				local dialog = Arenamaster:GetAceConfigDialog()
				if dialog then
					dialog:Open("Arenamaster")
				else
					print("|cff4dabf7Arenamaster|r - Use /am config to open settings")
				end
			end
		elseif button == "RightButton" then
			print("|cff4dabf7Arenamaster v2.0.0|r - PvP Arena Assistant")
			print("|cff00ff00Left-click:|r Open config")
			print("|cff00ff00Right-click:|r Show help")
		end
	end,
	OnMouseUp = function() end,
	OnMouseDown = function() end,
}

function MinimapIcon:OnInitialize()
	-- Verify icon data
	if not icon_data.id or not icon_data.OnClick then
		return
	end
end

function MinimapIcon:OnEnable()
	self:CreateMinimapIcon()
end

function MinimapIcon:CreateMinimapIcon()
	local button = _G["ArenamasterMinimapButton"]
	if button and button:IsVisible() then
		return
	end

	if button then
		button:Show()
		return
	end
	button:SetFrameLevel(8)
	button:SetSize(36, 36)
	button:SetFrameStrata("MEDIUM")

	local texture = button:CreateTexture()
	texture:SetTexture("Interface\\Icons\\inv_misc_tournament_banner")
	texture:SetAllPoints()
	button:SetNormalTexture(texture)

	button:SetPoint("CENTER", Minimap, "CENTER", 60, 60)

	button:SetScript("OnClick", function(self, btn)
		if btn == "LeftButton" then
			local ConfigUI = Arenamaster:GetModule("ConfigUI")
			if ConfigUI and ConfigUI.ShowConfigWindow then
				ConfigUI:ShowConfigWindow()
			else
				local dialog = Arenamaster:GetAceConfigDialog()
				if dialog then
					dialog:Open("Arenamaster")
				else
					print("|cff4dabf7Arenamaster|r - Use /am config to open settings")
				end
			end
		elseif btn == "RightButton" then
			print("|cff4dabf7Arenamaster v2.0.0|r - PvP Arena Assistant")
			print("|cffff7700Left-click:|r Open configuration")
			print("|cffff7700Right-click:|r Show this help")
			print("|cffff7700/am config:|r Open beautiful UI")
			print("|cffff7700/am stats:|r Show match statistics")
			print("|cffff7700/ai dr:|r Show DR status")
		end
	end)

	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine("|cff4dabf7Arenamaster|r", 0.1, 0.8, 1.0)
		GameTooltip:AddLine("Left-click: Open config", 1, 1, 1)
		GameTooltip:AddLine("Right-click: Show help", 1, 1, 1)
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	print("|cff4dabf7Arenamaster|r minimap icon created. Click to open config!")
end

function MinimapIcon:OnDisable()
	local button = _G["ArenamasterMinimapButton"]
	if button then
		button:Hide()
	end
end
