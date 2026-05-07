---@class AceSerializer-3.0
local AceSerializer = LibStub:NewLibrary("AceSerializer-3.0", 4)

if not AceSerializer then return end

function AceSerializer:Serialize(...)
	local t = {...}
	local parts = {}

	local function serialize_value(v)
		if type(v) == "nil" then
			return "n"
		elseif type(v) == "boolean" then
			return v and "t" or "f"
		elseif type(v) == "number" then
			return "N" .. v
		elseif type(v) == "string" then
			return "S" .. #v .. ":" .. v
		elseif type(v) == "table" then
			local result = "T"
			for k, val in pairs(v) do
				result = result .. serialize_value(k) .. serialize_value(val)
			end
			result = result .. "E"
			return result
		else
			return "n"
		end
	end

	for _, v in ipairs(t) do
		table.insert(parts, serialize_value(v))
	end

	return table.concat(parts, "^")
end

function AceSerializer:Deserialize(str)
	local pos = 1
	local function read_char()
		local c = str:sub(pos, pos)
		pos = pos + 1
		return c
	end

	local function deserialize_value()
		local t = read_char()

		if t == "n" then
			return nil
		elseif t == "t" then
			return true
		elseif t == "f" then
			return false
		elseif t == "N" then
			local numstr = ""
			while pos <= #str do
				local c = str:sub(pos, pos)
				if c:match("[0-9.-]") then
					numstr = numstr .. c
					pos = pos + 1
				else
					break
				end
			end
			return tonumber(numstr)
		elseif t == "S" then
			local lenstr = ""
			while read_char() ~= ":" do
				lenstr = lenstr .. str:sub(pos - 1, pos - 1)
			end
			local len = tonumber(lenstr)
			local s = str:sub(pos, pos + len - 1)
			pos = pos + len
			return s
		elseif t == "T" then
			local tbl = {}
			while pos <= #str do
				if str:sub(pos, pos) == "E" then
					pos = pos + 1
					break
				end
				local k = deserialize_value()
				local v = deserialize_value()
				if k ~= nil then
					tbl[k] = v
				end
			end
			return tbl
		end

		return nil
	end

	local results = {}
	local parts = {str:match("([^^]+)")}
	for _, part in ipairs(parts) do
		pos = 1
		str = part
		table.insert(results, deserialize_value())
	end

	return unpack(results)
end

return AceSerializer
