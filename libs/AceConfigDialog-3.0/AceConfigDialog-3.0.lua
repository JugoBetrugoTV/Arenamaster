---@class AceConfigDialog-3.0
local AceConfigDialog = LibStub:NewLibrary("AceConfigDialog-3.0", 53)

if not AceConfigDialog then return end

local AceConfig = LibStub:GetLibrary("AceConfig-3.0")
assert(AceConfig, "AceConfigDialog-3.0 requires AceConfig-3.0")

local AceGUI = LibStub:GetLibrary("AceGUI-3.0")
assert(AceGUI, "AceConfigDialog-3.0 requires AceGUI-3.0")

local open_frames = {}

local function buildOptions(options, container)
	if type(options) == "function" then
		options = options()
	end

	if not options or type(options) ~= "table" then
		return
	end

	-- Handle args
	if options.args then
		for k, v in pairs(options.args) do
			if v.type == "group" then
				-- Group handling
			elseif v.type == "toggle" then
				local cb = AceGUI:Create("CheckBox")
				cb:SetLabel(v.name)
				cb:SetDescription(v.desc)
				container:AddChild(cb)
			elseif v.type == "range" then
				local slider = AceGUI:Create("Slider")
				slider:SetLabel(v.name)
				slider:SetMinMaxValues(v.min, v.max)
				slider:SetStep(v.step)
				container:AddChild(slider)
			elseif v.type == "select" then
				-- Select handling
			end
		end
	end
end

function AceConfigDialog:Open(name, parent)
	assert(type(name) == "string", "AceConfigDialog:Open - name must be a string")

	local options = AceConfig:GetOptionsTable(name)
	if not options then
		error("AceConfigDialog:Open - No options table registered for: " .. name)
	end

	if open_frames[name] then
		open_frames[name]:Show()
		return open_frames[name]
	end

	local frame = AceGUI:Create("Frame")
	frame:SetTitle(options.name or name)
	frame:SetCallback("OnClose", function(widget)
		open_frames[name] = nil
	end)

	buildOptions(options, frame)

	open_frames[name] = frame
	return frame
end

function AceConfigDialog:Close(name)
	if open_frames[name] then
		open_frames[name]:Hide()
		open_frames[name] = nil
	end
end

return AceConfigDialog
