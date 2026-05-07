---@class AceBucket-3.0
local AceBucket = LibStub:NewLibrary("AceBucket-3.0", 3)

if not AceBucket then return end

local buckets = {}
local bucket_mt = {__index = AceBucket}

local function new(object)
	return setmetatable({buckets = {}, object = object}, bucket_mt)
end

function AceBucket:Embed(object)
	return new(object)
end

function AceBucket:New(object)
	return new(object or {})
end

function AceBucket:RegisterBucketEvent(events, delay, callback)
	if type(events) == "string" then
		events = {events}
	end

	local bucket = {
		callback = callback,
		delay = delay,
		events = {},
		pending = false,
		object = self.object or self,
	}

	for _, event in ipairs(events) do
		bucket.events[event] = true
	end

	table.insert(self.buckets, bucket)
end

function AceBucket:UnregisterBucketEvent(event)
	for i = #self.buckets, 1, -1 do
		if self.buckets[i].events[event] then
			table.remove(self.buckets, i)
		end
	end
end

return AceBucket
