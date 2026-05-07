---@class AceLocale-3.0
local AceLocale = LibStub:NewLibrary("AceLocale-3.0", 5)

if not AceLocale then return end

local locales = {}

function AceLocale:NewLocale(addon, locale, isDefault, silent)
	if not locales[addon] then
		locales[addon] = {}
	end

	if not locale then
		locale = GetLocale()
	end

	if not locales[addon][locale] then
		locales[addon][locale] = {}
	end

	return locales[addon][locale]
end

function AceLocale:GetLocale(addon, locale)
	if not locale then
		locale = GetLocale()
	end

	if not locales[addon] then
		return nil
	end

	-- Try requested locale
	if locales[addon][locale] then
		return locales[addon][locale]
	end

	-- Fall back to enUS
	if locales[addon]["enUS"] then
		return locales[addon]["enUS"]
	end

	return nil
end

return AceLocale
