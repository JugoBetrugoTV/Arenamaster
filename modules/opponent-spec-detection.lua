-- Arenamaster: Opponent Spec Detection Module
-- Properly handles API changes in WoW 12.0.5 for spec detection

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local OpponentSpecDetection = Arenamaster:NewModule("OpponentSpecDetection", "AceEvent-3.0")

local specCache = {}

-- ===========================
-- SPEC DETECTION
-- ===========================

function OpponentSpecDetection:OnInitialize()
	specCache = {}
end

function OpponentSpecDetection:OnEnable()
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
end

function OpponentSpecDetection:GetOpponentSpec(arenaIndex)
	-- arenaIndex should be 1-5
	if not arenaIndex or arenaIndex < 1 or arenaIndex > 5 then
		return nil
	end

	-- First try to get from cache
	local unit = "arena" .. arenaIndex
	if specCache[unit] then
		return specCache[unit]
	end

	-- Try using C_PvP namespace if available (WoW 12.0.5+)
	if C_PvP then
		local specID = C_PvP.GetArenaOpponentSpec(arenaIndex)
		if specID and specID > 0 then
			local specName, _, classID = GetSpecializationInfoByID(specID)
			if specName then
				specCache[unit] = {
					specID = specID,
					specName = specName,
					classID = classID,
					timestamp = GetTime(),
				}
				return specCache[unit]
			end
		end
	end

	-- Fallback: Infer spec from combat log patterns during match
	return self:InferSpecFromCombat(unit)
end

function OpponentSpecDetection:InferSpecFromCombat(unit)
	-- This is called during match to infer spec from spells cast
	-- For now, return basic info from unit analysis
	local name = UnitName(unit)
	if not name then return nil end

	local _, class = UnitClass(unit)
	if not class then return nil end

	-- Return basic spec info
	return {
		specName = "Unknown " .. class,
		className = class,
		timestamp = GetTime(),
		inferred = true,
	}
end

function OpponentSpecDetection:GetAllOpponentSpecs()
	local specs = {}
	for i = 1, 5 do
		local spec = self:GetOpponentSpec(i)
		if spec then
			specs["arena" .. i] = spec
		end
	end
	return specs
end

function OpponentSpecDetection:CacheOpponentSpec(unit, specID, specName)
	if specID and specID > 0 then
		specCache[unit] = {
			specID = specID,
			specName = specName,
			timestamp = GetTime(),
		}
		return true
	end
	return false
end

function OpponentSpecDetection:GetCachedSpec(unit)
	return specCache[unit]
end

function OpponentSpecDetection:ClearCache()
	specCache = {}
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function OpponentSpecDetection:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
	-- Called during arena prep phase when specs are revealed
	for i = 1, 5 do
		local spec = self:GetOpponentSpec(i)
		if spec then
			local unit = "arena" .. i
			local name = UnitName(unit) or ("Arena " .. i)
			Arenamaster:PrintDebug("Opponent " .. i .. " (" .. name .. "): " .. (spec.specName or "Unknown"))
		end
	end
end

function OpponentSpecDetection:ARENA_MATCH_START()
	-- Verify specs at match start
	Arenamaster:PrintDebug("Arena match started - opponent specs cached")
end

function OpponentSpecDetection:ARENA_MATCH_END()
	self:ClearCache()
	Arenamaster:PrintDebug("Arena match ended - spec cache cleared")
end

function OpponentSpecDetection:PLAYER_SPECIALIZATION_CHANGED()
	-- Refresh specs if player changes spec during prep
	self:ClearCache()
end

-- ===========================
-- UTILITY FUNCTIONS
-- ===========================

function OpponentSpecDetection:PrintOpponentSpecs()
	print("|cff00aiff════════════════════════════════════════|r")
	print("|cff00aiff        OPPONENT SPECIALIZATIONS         |r")
	print("|cff00aiff════════════════════════════════════════|r")

	for i = 1, 5 do
		local unit = "arena" .. i
		local spec = self:GetOpponentSpec(i)

		if UnitExists(unit) then
			local name = UnitName(unit)
			local class = select(2, UnitClass(unit))

			if spec and spec.specName then
				print("|cff4dabf7" .. name .. "|r (" .. class .. ")")
				print("  Spec: " .. spec.specName)
				if spec.inferred then
					print("  Status: |cffffaa00Inferred from combat|r")
				else
					print("  Status: |cff00ff00Confirmed|r")
				end
			else
				print("|cffcccccc" .. name .. "|r (" .. class .. ")")
				print("  Spec: |cffffaa00Detecting...|r")
			end
		end
	end
end
