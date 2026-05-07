---@class AceConfigRegistry-3.0
local AceConfigRegistry = LibStub:NewLibrary("AceConfigRegistry-3.0", 1)

if not AceConfigRegistry then return end

local registry = {}

function AceConfigRegistry:RegisterOptionsTable(app, options, defaults)
	if not registry[app] then
		registry[app] = {}
	end

	registry[app].options = options
	registry[app].defaults = defaults
end

function AceConfigRegistry:GetOptionsTable(app)
	if not registry[app] then return nil end
	return registry[app].options
end

function AceConfigRegistry:GetDefaults(app)
	if not registry[app] then return nil end
	return registry[app].defaults
end

function AceConfigRegistry:ValidateOptionsTable(options)
	if type(options) ~= "table" then return false end
	if not options.type then return false end
	return true
end

function AceConfigRegistry:NotifyChange(app)
	-- Notify that options have changed
end

return AceConfigRegistry
