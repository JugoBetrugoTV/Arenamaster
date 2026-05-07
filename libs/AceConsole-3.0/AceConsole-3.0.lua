---@class AceConsole-3.0
local AceConsole = LibStub:NewLibrary("AceConsole-3.0", 6)

if not AceConsole then return end

local function new(object)
	object = object or {}

	function object:Print(...)
		local msg = table.concat({...}, " ")
		print("|cff00ffff" .. (self.name or "Addon") .. "|r: " .. msg)
	end

	function object:RegisterChatCommand(command, method)
		if type(method) == "string" then
			method = object[method]
		end

		_G["SLASH_" .. command:upper()] = "/" .. command:lower()
		SlashCmdList[command:upper()] = function(msg)
			method(object, msg)
		end
	end

	function object:GetArgs(msg, numArgs, startpos)
		local args = {}
		local pos = startpos or 1

		for i = 1, numArgs or math.huge do
			local arg
			arg, pos = msg:match("(%S+)()", pos)
			if not arg then break end
			table.insert(args, arg)
		end

		return unpack(args)
	end

	return object
end

function AceConsole:Embed(object)
	return new(object)
end

function AceConsole:New(object)
	return new(object or {})
end

return AceConsole
