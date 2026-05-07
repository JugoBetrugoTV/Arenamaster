-- Arenamaster: Rating Goals & Progression Tracker
-- Verfolgt Ziele und zeigt Fortschritt

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local GoalTracker = Arenamaster:NewModule("Goals", "AceEvent-3.0")

local GOAL_TYPES = {
	RATING_TARGET = "rating_target",
	WIN_STREAK = "win_streak",
	WINRATE_TARGET = "winrate_target",
	MATCHES_PLAYED = "matches_played",
}

local DEFAULT_GOALS = {
	{type = GOAL_TYPES.RATING_TARGET, name = "Reach 1600", target = 1600, reward = "Challenger"},
	{type = GOAL_TYPES.RATING_TARGET, name = "Reach 1800", target = 1800, reward = "Rival"},
	{type = GOAL_TYPES.RATING_TARGET, name = "Reach 2100", target = 2100, reward = "Duelist"},
	{type = GOAL_TYPES.WINRATE_TARGET, name = "50% Winrate", target = 50, reward = "Consistent"},
}

function GoalTracker:OnInitialize()
	if not Arenamaster.db.profile.goals then
		Arenamaster.db.profile.goals = {}
		for _, goal in ipairs(DEFAULT_GOALS) do
			table.insert(Arenamaster.db.profile.goals, goal)
		end
	end
end

function GoalTracker:OnEnable()
	self:RegisterEvent("ARENA_MATCH_END")
end

function GoalTracker:GetGoals()
	return Arenamaster.db.profile.goals or {}
end

function GoalTracker:GetProgress(goal)
	if goal.type == GOAL_TYPES.RATING_TARGET then
		local currentRating = Arenamaster.db.profile.currentRating or 0
		return math.floor((currentRating / goal.target) * 100)
	end

	return 0
end

function GoalTracker:CheckGoalCompletion()
	local currentRating = Arenamaster.db.profile.currentRating or 0

	for _, goal in ipairs(self:GetGoals()) do
		if goal.type == GOAL_TYPES.RATING_TARGET then
			if currentRating >= goal.target and not goal.completed then
				goal.completed = true
				Arenamaster:PrintDebug("Goal completed: " .. goal.name)
			end
		end
	end
end

function GoalTracker:ARENA_MATCH_END()
	self:CheckGoalCompletion()
end
