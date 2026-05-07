---@class AceGUI-3.0
local AceGUI = LibStub:NewLibrary("AceGUI-3.0", 33)

if not AceGUI then return end

local widgets = {}
local layouts = {}
local frame_counter = 0

function AceGUI:Create(type)
	assert(widgets[type], "AceGUI-3.0: Unknown widget type: " .. tostring(type))
	frame_counter = frame_counter + 1
	local name = "AceGUI30Frame" .. frame_counter
	return widgets[type](name)
end

function AceGUI:RegisterWidget(type, widgetfunc)
	assert(type(type) == "string", "AceGUI-3.0: RegisterWidget - type must be a string")
	assert(type(widgetfunc) == "function", "AceGUI-3.0: RegisterWidget - widgetfunc must be a function")
	widgets[type] = widgetfunc
end

function AceGUI:RegisterLayout(type, layoutfunc)
	assert(type(type) == "string", "AceGUI-3.0: RegisterLayout - type must be a string")
	assert(type(layoutfunc) == "function", "AceGUI-3.0: RegisterLayout - layoutfunc must be a function")
	layouts[type] = layoutfunc
end

function AceGUI:GetLayout(type)
	return layouts[type]
end

-- Register basic widgets
AceGUI:RegisterWidget("Frame", function(name)
	return {
		frame = CreateFrame("Frame", name, UIParent),
		children = {},
		type = "Frame",
		AddChild = function(self, child)
			table.insert(self.children, child)
		end,
		RemoveChild = function(self, child)
			for i, v in ipairs(self.children) do
				if v == child then
					table.remove(self.children, i)
					break
				end
			end
		end,
		DoLayout = function(self) end,
		SetTitle = function(self, title)
			if self.frame.title then
				self.frame.title:SetText(title)
			end
		end,
		SetStatusText = function(self, text) end,
		Show = function(self)
			self.frame:Show()
		end,
		Hide = function(self)
			self.frame:Hide()
		end,
	}
end)

AceGUI:RegisterWidget("ScrollFrame", function(name)
	local frame = CreateFrame("ScrollFrame", name, UIParent, "UIPanelScrollFrameTemplate")
	return {
		frame = frame,
		content = CreateFrame("Frame"),
		type = "ScrollFrame",
		Show = function(self) self.frame:Show() end,
		Hide = function(self) self.frame:Hide() end,
		SetStatusText = function(self, text) end,
	}
end)

AceGUI:RegisterWidget("EditBox", function(name)
	local frame = CreateFrame("EditBox", name, UIParent, "InputBoxTemplate")
	return {
		frame = frame,
		type = "EditBox",
		SetText = function(self, text) self.frame:SetText(text) end,
		GetText = function(self) return self.frame:GetText() end,
		Show = function(self) self.frame:Show() end,
		Hide = function(self) self.frame:Hide() end,
	}
end)

AceGUI:RegisterWidget("Button", function(name)
	local frame = CreateFrame("Button", name, UIParent, "UIPanelButtonTemplate")
	return {
		frame = frame,
		type = "Button",
		SetText = function(self, text) self.frame:SetText(text) end,
		SetCallback = function(self, event, func)
			if event == "OnClick" then
				self.frame:SetScript("OnClick", func)
			end
		end,
		Show = function(self) self.frame:Show() end,
		Hide = function(self) self.frame:Hide() end,
	}
end)

AceGUI:RegisterWidget("Label", function(name)
	local frame = CreateFrame("Frame", name, UIParent)
	local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	return {
		frame = frame,
		text = text,
		type = "Label",
		SetText = function(self, text) self.text:SetText(text) end,
		Show = function(self) self.frame:Show() end,
		Hide = function(self) self.frame:Hide() end,
	}
end)

AceGUI:RegisterWidget("CheckBox", function(name)
	local frame = CreateFrame("CheckButton", name, UIParent, "UICheckButtonTemplate")
	return {
		frame = frame,
		type = "CheckBox",
		SetValue = function(self, value) self.frame:SetChecked(value) end,
		GetValue = function(self) return self.frame:GetChecked() end,
		SetCallback = function(self, event, func)
			if event == "OnValueChanged" then
				self.frame:SetScript("OnClick", func)
			end
		end,
		Show = function(self) self.frame:Show() end,
		Hide = function(self) self.frame:Hide() end,
	}
end)

AceGUI:RegisterWidget("Slider", function(name)
	local frame = CreateFrame("Slider", name, UIParent, "OptionsSliderTemplate")
	return {
		frame = frame,
		type = "Slider",
		SetValue = function(self, value) self.frame:SetValue(value) end,
		GetValue = function(self) return self.frame:GetValue() end,
		SetMinMaxValues = function(self, min, max) self.frame:SetMinMaxValues(min, max) end,
		SetCallback = function(self, event, func)
			if event == "OnValueChanged" then
				self.frame:SetScript("OnValueChanged", func)
			end
		end,
		Show = function(self) self.frame:Show() end,
		Hide = function(self) self.frame:Hide() end,
	}
end)

return AceGUI
