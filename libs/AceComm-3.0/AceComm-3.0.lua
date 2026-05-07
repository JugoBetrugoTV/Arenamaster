---@class AceComm-3.0
local AceComm = LibStub:NewLibrary("AceComm-3.0", 11)

if not AceComm then return end

local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

local comms = {}

function AceComm:RegisterComm(prefix, callback)
	if type(callback) == "string" then
		callback = self[callback]
	end

	comms[prefix] = {
		callback = callback,
		object = self,
	}
end

function AceComm:UnregisterComm(prefix)
	comms[prefix] = nil
end

function AceComm:SendCommMessage(prefix, text, distribution, target)
	-- Implementation for sending messages
	-- In real addon: would use C_ChatInfo.SendAddonMessage
	if not comms[prefix] then return end

	if distribution == "WHISPER" and target then
		-- Send whisper
	elseif distribution == "PARTY" then
		-- Send to party
	elseif distribution == "RAID" then
		-- Send to raid
	elseif distribution == "GUILD" then
		-- Send to guild
	end
end

function AceComm:IsCommRegistered(prefix)
	return comms[prefix] ~= nil
end

return AceComm
