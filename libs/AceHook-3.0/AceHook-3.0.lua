---@class AceHook-3.0
local AceHook = LibStub:NewLibrary("AceHook-3.0", 9)

if not AceHook then return end

local function new(object)
	object = object or {}
	object.__hooks = {}

	function object:Hook(obj, method, func, secure)
		assert(type(obj) == "table", "Hook target must be a table")
		assert(type(method) == "string", "Method name must be a string")
		assert(type(func) == "function" or type(func) == "string", "Hook function must be callable")

		if type(func) == "string" then
			func = object[func]
		end

		local original = obj[method]
		local hook_name = obj[method]

		if secure then
			-- Secure hook - just wrap it
			obj[method] = function(...)
				original(...)
				return func(object, ...)
			end
		else
			-- Normal hook
			obj[method] = function(...)
				return func(object, ...)
			end
		end

		object.__hooks[method] = {
			target = obj,
			original = original,
			func = func,
		}
	end

	function object:SecureHook(obj, method, func)
		return object:Hook(obj, method, func, true)
	end

	function object:RawHook(obj, method, func)
		if type(func) == "string" then
			func = object[func]
		end

		local original = obj[method]
		object.__hooks[method] = {
			target = obj,
			original = original,
		}

		obj[method] = func
	end

	function object:Unhook(obj, method)
		local hook = object.__hooks[method]
		if hook and hook.target == obj then
			obj[method] = hook.original
			object.__hooks[method] = nil
		end
	end

	return object
end

function AceHook:Embed(object)
	return new(object)
end

function AceHook:New(object)
	return new(object or {})
end

return AceHook
