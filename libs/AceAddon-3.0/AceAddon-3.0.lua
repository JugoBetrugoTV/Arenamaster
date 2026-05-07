---@class AceAddon
local AceAddon, oldminor = LibStub:NewLibrary("AceAddon-3.0", 12)

if not AceAddon then return end

local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")
assert(CallbackHandler, "AceAddon-3.0 requires CallbackHandler-1.0")

local addons = {}
local AceAddonMeta = {__index = AceAddon}
local function IsClass(obj) return type(obj) == "table" and obj.super and obj.Add end

function AceAddon:NewAddon(name, ...)
	assert(type(name) == "string", "AceAddon:NewAddon(name, ...): name must be a string")

	local addon = setmetatable({}, AceAddonMeta)
	addon.name = name
	addon.modules = {}
	addon.events = {}

	CallbackHandler:New(addon, name)

	addons[name] = addon
	_G[name] = addon

	return addon, ...
end

function AceAddon:GetAddon(name)
	return addons[name]
end

function AceAddon:RegisterEvent(eventname, method)
	if type(method) == "string" then
		method = self[method]
	end
	if not self.events then
		self.events = {}
	end
	if not self.events[eventname] then
		if not self.frame then
			self.frame = CreateFrame("Frame")
		end
		self.frame:RegisterEvent(eventname)
		self.frame:SetScript("OnEvent", function(frame, event, ...)
			local addon = addons[self.name]
			if addon and addon.events[event] then
				for _, handler in ipairs(addon.events[event]) do
					handler(addon, ...)
				end
			end
		end)
	end
	if not self.events[eventname] then
		self.events[eventname] = {}
	end
	table.insert(self.events[eventname], method)
end

function AceAddon:UnregisterEvent(eventname, method)
	if not self.events or not self.events[eventname] then return end
	if type(method) == "string" then
		method = self[method]
	end
	for i, v in ipairs(self.events[eventname]) do
		if v == method then
			table.remove(self.events[eventname], i)
			break
		end
	end
end

function AceAddon:UnregisterAllEvents()
	if not self.events then return end
	if self.frame then
		self.frame:UnregisterAllEvents()
	end
	self.events = {}
end

local function IsCallable(obj)
	return (type(obj) == "function") or (type(obj) == "table" and obj.__call)
end

function AceAddon:NewModule(name, proto, ...)
	local module = setmetatable(proto or {}, {__index = self})
	module.name = name
	self.modules[name] = module

	CallbackHandler:New(module, name)

	return module, ...
end

function AceAddon:GetModule(name)
	return self.modules[name]
end

return AceAddon
