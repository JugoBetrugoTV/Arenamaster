-- Arenamaster: Smart Notifications Module
-- Intelligente Benachrichtigungen und Alerts

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local SmartNotifications = Arenamaster:NewModule("Notifications", "AceEvent-3.0", "AceTimer-3.0")

local notificationQueue = {}
local lastNotificationTime = 0
local NOTIFICATION_COOLDOWN = 2

function SmartNotifications:OnInitialize()
	notificationQueue = {}
end

function SmartNotifications:OnEnable()
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
	self:RegisterEvent("UNIT_AURA")
end

function SmartNotifications:SendNotification(title, message, priority)
	priority = priority or "normal"
	local currentTime = GetTime()

	if currentTime - lastNotificationTime < NOTIFICATION_COOLDOWN then
		return false
	end

	table.insert(notificationQueue, {
		title = title,
		message = message,
		priority = priority,
		timestamp = currentTime
	})

	lastNotificationTime = currentTime
	return true
end

function SmartNotifications:ARENA_MATCH_START()
	self:SendNotification("Arena", "Match started!", "high")
end

function SmartNotifications:ARENA_MATCH_END()
	self:SendNotification("Arena", "Match ended!", "high")
end

function SmartNotifications:UNIT_AURA(event, unit)
	-- Handle aura notifications
end
