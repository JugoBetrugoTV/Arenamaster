---@class AceConfigCmd-3.0
local AceConfigCmd = LibStub:NewLibrary("AceConfigCmd-3.0", 6)

if not AceConfigCmd then return end

local AceConfig = LibStub:GetLibrary("AceConfig-3.0")
assert(AceConfig, "AceConfigCmd-3.0 requires AceConfig-3.0")

local function new(object)
	object = object or {}

	function object:HandleSlashCommand(addon, msg)
		local options = AceConfig:GetOptionsTable(addon)
		if not options then return end

		-- Parse command line arguments
		if msg and msg ~= "" then
			self:ExecuteCommand(options, msg)
		end
	end

	function object:ExecuteCommand(options, msg)
		-- Simple command handling
		local parts = {}
		for part in msg:gmatch("%S+") do
			table.insert(parts, part)
		end

		if #parts == 0 then return end

		local current = options
		for i, part in ipairs(parts) do
			if current.args and current.args[part] then
				current = current.args[part]
				if current.type == "execute" and current.func then
					current.func({})
					return
				end
			end
		end
	end

	return object
end

function AceConfigCmd:Embed(object)
	return new(object)
end

function AceConfigCmd:New(object)
	return new(object or {})
end

return AceConfigCmd
