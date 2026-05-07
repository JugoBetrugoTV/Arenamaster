-- Arenamaster: Rating Tracking Module
-- Verfolgt PvP-Rating und Tier-Fortschritt

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local RatingTracker = Arenamaster:NewModule("Rating", "AceEvent-3.0")

-- Rating-Tiers
local RATING_TIERS = {
	{ name = "Unranked", min = 0, max = 1599, color = "ffcccccc" },
	{ name = "Challenger", min = 1600, max = 1799, color = "ff1eff00" },
	{ name = "Rival", min = 1800, max = 2099, color = "ff0070dd" },
	{ name = "Duelist", min = 2100, max = 2399, color = "ffa335ee" },
	{ name = "Gladiator", min = 2400, max = 10000, color = "ffff8000" },
}

-- ===========================
-- INITIALIZATION
-- ===========================

function RatingTracker:OnInitialize()
	if not Arenamaster.db.profile.ratingHistory then
		Arenamaster.db.profile.ratingHistory = {}
	end
end

function RatingTracker:OnEnable()
	self:RegisterEvent("ARENA_MATCH_END")
end

function RatingTracker:OnDisable()
	-- Cleanup
end

-- ===========================
-- RATING SYSTEM
-- ===========================

function RatingTracker:UpdateRating(rating)
	Arenamaster.db.profile.currentRating = rating
	local tier = self:GetTierName(rating)
	Arenamaster.db.profile.currentTier = tier

	-- Save to history
	table.insert(Arenamaster.db.profile.ratingHistory, {
		rating = rating,
		timestamp = GetTime(),
		date = date("%Y-%m-%d %H:%M:%S")
	})

	-- Keep only last 100 entries
	if #Arenamaster.db.profile.ratingHistory > 100 then
		table.remove(Arenamaster.db.profile.ratingHistory, 1)
	end

	return tier
end

function RatingTracker:GetTierName(rating)
	rating = rating or 0

	for _, tier in ipairs(RATING_TIERS) do
		if rating >= tier.min and rating <= tier.max then
			return tier.name
		end
	end

	return "Unranked"
end

function RatingTracker:GetTierInfo(tierName)
	for _, tier in ipairs(RATING_TIERS) do
		if tier.name == tierName then
			return tier
		end
	end
	return RATING_TIERS[1]
end

function RatingTracker:GetRatingColor(rating)
	rating = rating or 0

	for _, tier in ipairs(RATING_TIERS) do
		if rating >= tier.min and rating <= tier.max then
			return tier.color
		end
	end

	return "ffcccccc"
end

function RatingTracker:GetRatingProgress(rating)
	rating = rating or 0

	for _, tier in ipairs(RATING_TIERS) do
		if rating >= tier.min and rating <= tier.max then
			local progress = rating - tier.min
			local tierWidth = tier.max - tier.min
			return math.floor((progress / tierWidth) * 100)
		end
	end

	return 0
end

function RatingTracker:EstimateRatingChange(isWin)
	local baseRatingChange = 12
	if isWin then
		return baseRatingChange
	else
		return -baseRatingChange
	end
end

function RatingTracker:GetRatingHistory(limit)
	limit = limit or 10
	local history = Arenamaster.db.profile.ratingHistory or {}

	local result = {}
	local start = math.max(1, #history - limit + 1)

	for i = start, #history do
		table.insert(result, history[i])
	end

	return result
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function RatingTracker:ARENA_MATCH_END()
	Arenamaster:PrintDebug("Rating tracker locked for match end")
end
