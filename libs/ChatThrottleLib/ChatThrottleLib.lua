-- ChatThrottleLib - Simple rate limiting for chat messages
-- Minimal implementation for Arenamaster addon

local lib = {}
local throttle_data = {}

function lib:SendChatMessage(msg, chatType, language, channel, target, priority)
	priority = priority or 50
	SendChatMessage(msg, chatType, language, channel, target)
	return true
end

-- Return library singleton
_G.ChatThrottleLib = lib
