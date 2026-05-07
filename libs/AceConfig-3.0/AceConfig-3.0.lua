---@class AceConfig-3.0
local AceConfig = LibStub:NewLibrary("AceConfig-3.0", 2)

if not AceConfig then return end

local function deep_copy(source, dest)
	for k, v in pairs(source) do
		if type(v) == "table" then
			if type(dest[k]) ~= "table" then
				dest[k] = {}
			end
			deep_copy(v, dest[k])
		else
			dest[k] = v
		end
	end
	return dest
end

local registered = {}

function AceConfig:RegisterOptionsTable(name, options, ...)
	assert(type(name) == "string", "AceConfig:RegisterOptionsTable - name must be a string")
	assert(type(options) == "table" or type(options) == "function", "AceConfig:RegisterOptionsTable - options must be a table or function")

	registered[name] = {
		options = options,
		args = {...}
	}
end

function AceConfig:GetOptionsTable(name)
	local reg = registered[name]
	if not reg then return nil end

	if type(reg.options) == "function" then
		return reg.options(unpack(reg.args))
	else
		return reg.options
	end
end

function AceConfig:ValidateOptionsTable(options)
	if type(options) ~= "table" then return false end
	if not options.name then return false end
	if not options.type then return false end
	return true
end

return AceConfig
