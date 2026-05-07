---@class AceDB-3.0
local AceDB = LibStub:NewLibrary("AceDB-3.0", 3)

if not AceDB then return end

local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")
assert(CallbackHandler, "AceDB-3.0 requires CallbackHandler-1.0")

local function deepcopy(src, dest)
	for k, v in pairs(src) do
		if type(v) == "table" then
			if type(dest[k]) ~= "table" then
				dest[k] = {}
			end
			deepcopy(v, dest[k])
		else
			dest[k] = v
		end
	end
	return dest
end

function AceDB:New(tbl, defaults, ...)
	assert(type(tbl) == "table", "AceDB:New(tbl, defaults, ...): tbl must be a table")

	local db = {}
	if defaults then
		deepcopy(defaults, db)
	end

	CallbackHandler:New(db)

	function db:RegisterCallback(...)
		return CallbackHandler.RegisterCallback(self, ...)
	end

	function db:UnregisterCallback(...)
		return CallbackHandler.UnregisterCallback(self, ...)
	end

	return db
end

function AceDB:RegisterDefaults(db, namespace, defaults)
	if not db.profile then
		db.profile = {}
	end
	if defaults.profile then
		deepcopy(defaults.profile, db.profile)
	end
	if not db.global then
		db.global = {}
	end
	if defaults.global then
		deepcopy(defaults.global, db.global)
	end
end

return AceDB
