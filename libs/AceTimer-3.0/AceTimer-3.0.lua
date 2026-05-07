---@class AceTimer-3.0
local AceTimer = LibStub:NewLibrary("AceTimer-3.0", 4)

if not AceTimer then return end

local timers = {}
local timerFrame = CreateFrame("Frame")

function AceTimer:ScheduleTimer(callback, delay, ...)
	assert(type(callback) == "function", "AceTimer:ScheduleTimer: callback must be a function")
	assert(type(delay) == "number", "AceTimer:ScheduleTimer: delay must be a number")

	local timer = {
		callback = callback,
		delay = delay,
		args = {...},
		time = 0
	}

	table.insert(timers, timer)
	timerFrame:Show()

	return #timers
end

function AceTimer:CancelTimer(id)
	if timers[id] then
		timers[id] = nil
	end
end

function AceTimer:CancelAllTimers()
	timers = {}
	timerFrame:Hide()
end

timerFrame:SetScript("OnUpdate", function(self, elapsed)
	local activeTimers = false
	for i, timer in ipairs(timers) do
		if timer then
			timer.time = timer.time + elapsed
			if timer.time >= timer.delay then
				pcall(timer.callback, unpack(timer.args))
				timers[i] = nil
			else
				activeTimers = true
			end
		end
	end

	if not activeTimers then
		self:Hide()
	end
end)

timerFrame:Hide()

return AceTimer
