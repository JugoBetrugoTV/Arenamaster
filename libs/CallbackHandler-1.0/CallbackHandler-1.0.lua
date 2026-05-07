---@class CallbackHandler
local CallbackHandler = LibStub:NewLibrary("CallbackHandler-1.0", 6)

if not CallbackHandler then return end

local meta = {__index = function(t,k) return t.parent[k] end}
local type = type
local pcall = pcall

local pairs = pairs
local next = next
local select = select
local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function Dispatch(handlers, ...)
	local index = 1
	while handlers[index] do
		xpcall(handlers[index], errorhandler, ...)
		index = index + 1
	end
end

function CallbackHandler:New(object, major, minor)
	assert(type(object) == "table", "CallbackHandler:New(object, major, minor): object must be a table")
	assert(type(major) == "string", "CallbackHandler:New(object, major, minor): major must be a string")

	minor = tonumber(minor) or 1
	assert(minor >= 1, "CallbackHandler:New(object, major, minor): minor must be >= 1")

	if not object.Fire then
		object.Fire = function(self, ...)
			return self:SendMessage(...)
		end
	end

	object.SendMessage = function(self, eventname, ...)
		if not self.callbacks then return end
		local handlers = self.callbacks.events[eventname]
		if handlers then
			Dispatch(handlers, eventname, ...)
		end
	end

	object.RegisterCallback = function(self, eventname, method, arg)
		if not self.callbacks then
			self.callbacks = {
				events = {},
				methods = {}
			}
		end
		if type(method) == "string" then
			method = self[method]
		end
		if not self.callbacks.methods[method] then
			self.callbacks.methods[method] = {}
		end
		table.insert(self.callbacks.methods[method], {event = eventname, arg = arg})
		if not self.callbacks.events[eventname] then
			self.callbacks.events[eventname] = {}
		end
		table.insert(self.callbacks.events[eventname], method)
	end

	object.UnregisterCallback = function(self, eventname, method)
		if not self.callbacks then return end
		if type(method) == "string" then
			method = self[method]
		end
		if not self.callbacks.methods[method] then return end
		for i, v in ipairs(self.callbacks.methods[method]) do
			if v.event == eventname then
				table.remove(self.callbacks.methods[method], i)
				break
			end
		end
		for i, v in ipairs(self.callbacks.events[eventname]) do
			if v == method then
				table.remove(self.callbacks.events[eventname], i)
				break
			end
		end
	end

	object.UnregisterAllCallbacks = function(self)
		if not self.callbacks then return end
		self.callbacks = nil
	end

	return object
end

return CallbackHandler
