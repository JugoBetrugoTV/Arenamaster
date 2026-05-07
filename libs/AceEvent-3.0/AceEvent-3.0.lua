---@class AceEvent-3.0
local AceEvent = LibStub:NewLibrary("AceEvent-3.0", 5)

if not AceEvent then return end

local function new(object)
	local events = {}
	object.events = events

	function object:RegisterEvent(eventname, method)
		if type(method) == "string" then
			method = self[method]
		end
		if not events[eventname] then
			events[eventname] = {}
		end
		events[eventname][method] = true
	end

	function object:UnregisterEvent(eventname, method)
		if not events[eventname] then return end
		if type(method) == "string" then
			method = self[method]
		end
		events[eventname][method] = nil
	end

	function object:UnregisterAllEvents()
		events = {}
		self.events = events
	end

	function object:IsEventRegistered(eventname, method)
		if not events[eventname] then return false end
		if type(method) == "string" then
			method = self[method]
		end
		return events[eventname][method] or false
	end

	return object
end

function AceEvent:Embed(object)
	return new(object)
end

function AceEvent:New(object)
	return new(object or {})
end

return AceEvent
