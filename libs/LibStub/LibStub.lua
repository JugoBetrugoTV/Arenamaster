-- LibStub: A simple versioning library made for addons
-- See https://www.wowpedia.org/LibStub

local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 4
local LibStub = _G[LIBSTUB_MAJOR]

if LibStub and LibStub.GetLibrary and LibStub:GetLibrary(LIBSTUB_MAJOR).minor >= LIBSTUB_MINOR then
	return
end

if not LibStub then
	LibStub = CreateFrame("Frame")
	LibStub:Hide()
	_G[LIBSTUB_MAJOR] = LibStub
end

local _G = _G
local tostring = _G.tostring
local type = _G.type
local next = _G.next
local pairs = _G.pairs
local select = _G.select

local libs = {}
LibStub.libs = libs

function LibStub:NewLibrary(major, minor)
	assert(type(major) == "string", "Bad argument #1 to `NewLibrary' (expected string, got " .. type(major) .. ")")
	if not minor then minor = 1 else
		assert(type(minor) == "number", "Bad argument #2 to `NewLibrary' (expected number, got " .. type(minor) .. ")")
	end

	local oldminor = self.minors[major]
	if oldminor and oldminor >= minor then return nil end

	libs[major] = {}
	self.minors[major] = minor

	return libs[major], minor
end

function LibStub:GetLibrary(major, silent)
	if not type(major) == "string" then
		error(("Bad argument #1 to `GetLibrary' (expected string, got %s)"):format(type(major)), 2)
	end
	if libs[major] then
		return libs[major]
	end
	if not silent then
		error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
	end
end

function LibStub:IterateLibraries()
	return next, libs
end

LibStub.minors = {}
LibStub.LIBSTUB_MAJOR = LIBSTUB_MAJOR
LibStub.LIBSTUB_MINOR = LIBSTUB_MINOR
