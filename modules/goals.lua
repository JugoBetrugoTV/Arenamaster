-- Arenamaster: Rating Goals & Progression Tracker
-- Verfolgt Ziele und zeigt Fortschritt

local AM = Arenamaster
local GoalTracker = {}

-- Goal Types
local GOAL_TYPES = {
    RATING_TARGET = "rating_target",
    WIN_STREAK = "win_streak",
    WINRATE_TARGET = "winrate_target",
    MATCHES_PLAYED = "matches_played",
    OPPONENT_RECORD = "opponent_record",
}

-- Default Goals
local DEFAULT_GOALS = {
    {type = GOAL_TYPES.RATING_TARGET, name = "Reach 1600", target = 1600, reward = "Challenger"},
    {type = GOAL_TYPES.RATING_TARGET, name = "Reach 1800", target = 1800, reward = "Rival"},
    {type = GOAL_TYPES.RATING_TARGET, name = "Reach 2100", target = 2100, reward = "Duelist"},
    {type = GOAL_TYPES.RATING_TARGET, name = "Reach 2400", target = 2400, reward = "Gladiator"},
    {type = GOAL_TYPES.WIN_STREAK, name = "5-Win Streak", target = 5, reward = "5x"},
    {type = GOAL_TYPES.WIN_STREAK, name = "10-Win Streak", target = 10, reward = "10x"},
    {type = GOAL_TYPES.WINRATE_TARGET, name = "60% Winrate", target = 60, reward = "Skilled"},
}

-- ===========================
-- INITIALIZATION
-- ===========================

function GoalTracker:Initialize()
    if not ArenamasterDB.goals then
        ArenamasterDB.goals = {}
        self:LoadDefaultGoals()
    end
end

function GoalTracker:LoadDefaultGoals()
    for _, goal in ipairs(DEFAULT_GOALS) do
        if not self:GoalExists(goal.name) then
            table.insert(ArenamasterDB.goals, {
                name = goal.name,
                type = goal.type,
                target = goal.target,
                reward = goal.reward,
                progress = 0,
                completed = false,
                completedAt = nil,
                createdAt = date("%Y-%m-%d %H:%M:%S"),
            })
        end
    end
end

-- ===========================
-- GOAL MANAGEMENT
-- ===========================

function GoalTracker:GoalExists(name)
    for _, goal in ipairs(ArenamasterDB.goals or {}) do
        if goal.name == name then
            return true
        end
    end
    return false
end

function GoalTracker:AddCustomGoal(name, type, target, reward)
    if self:GoalExists(name) then
        return false, "Goal already exists"
    end

    table.insert(ArenamasterDB.goals, {
        name = name,
        type = type,
        target = target,
        reward = reward,
        progress = 0,
        completed = false,
        completedAt = nil,
        createdAt = date("%Y-%m-%d %H:%M:%S"),
    })

    return true
end

function GoalTracker:UpdateGoalProgress()
    local stats = ArenamasterDB.stats or {}
    local rating = ArenamasterDB.rating or 0
    local winrate = AM:GetWinrate()

    for _, goal in ipairs(ArenamasterDB.goals or {}) do
        if not goal.completed then
            if goal.type == GOAL_TYPES.RATING_TARGET then
                goal.progress = rating
                if rating >= goal.target then
                    goal.completed = true
                    goal.completedAt = date("%Y-%m-%d %H:%M:%S")
                    self:OnGoalCompleted(goal)
                end
            elseif goal.type == GOAL_TYPES.WIN_STREAK then
                goal.progress = stats.streak or 0
                if goal.progress >= goal.target then
                    goal.completed = true
                    goal.completedAt = date("%Y-%m-%d %H:%M:%S")
                    self:OnGoalCompleted(goal)
                end
            elseif goal.type == GOAL_TYPES.WINRATE_TARGET then
                goal.progress = winrate
                if winrate >= goal.target then
                    goal.completed = true
                    goal.completedAt = date("%Y-%m-%d %H:%M:%S")
                    self:OnGoalCompleted(goal)
                end
            elseif goal.type == GOAL_TYPES.MATCHES_PLAYED then
                goal.progress = stats.totalMatches or 0
                if goal.progress >= goal.target then
                    goal.completed = true
                    goal.completedAt = date("%Y-%m-%d %H:%M:%S")
                    self:OnGoalCompleted(goal)
                end
            end
        end
    end
end

-- ===========================
-- PROGRESS CALCULATION
-- ===========================

function GoalTracker:GetGoalProgress(goal)
    if goal.type == GOAL_TYPES.RATING_TARGET then
        local percent = (goal.progress / goal.target) * 100
        return {
            current = goal.progress,
            target = goal.target,
            percent = math.min(100, percent),
            remaining = math.max(0, goal.target - goal.progress),
        }
    elseif goal.type == GOAL_TYPES.WIN_STREAK then
        return {
            current = goal.progress,
            target = goal.target,
            percent = (goal.progress / goal.target) * 100,
            remaining = math.max(0, goal.target - goal.progress),
        }
    elseif goal.type == GOAL_TYPES.WINRATE_TARGET then
        return {
            current = goal.progress,
            target = goal.target,
            percent = goal.progress,
            remaining = math.max(0, goal.target - goal.progress),
        }
    else
        return {current = goal.progress, target = goal.target, percent = 0}
    end
end

function GoalTracker:EstimateTimeToGoal(goal)
    local stats = ArenamasterDB.stats or {}
    local progress = self:GetGoalProgress(goal)

    if progress.remaining == 0 then
        return {matches = 0, hours = 0, estimate = "Complete!"}
    end

    -- Estimate based on recent performance
    local recentWR = AM.MatchPredictor:GetRecentWinRate(20) / 100
    local matchesPerHour = 10  -- Rough estimate

    local estimatedMatches = 0
    if goal.type == GOAL_TYPES.RATING_TARGET then
        estimatedMatches = math.ceil(progress.remaining / 12)  -- ~12 rating per win
    elseif goal.type == GOAL_TYPES.WIN_STREAK then
        estimatedMatches = progress.remaining
    else
        estimatedMatches = progress.remaining
    end

    local estimatedHours = estimatedMatches / matchesPerHour
    local estimatedDays = estimatedHours / 24

    return {
        matches = estimatedMatches,
        hours = estimatedHours,
        days = estimatedDays,
        estimate = string.format("~%.1f hours (%d matches)", estimatedHours, estimatedMatches)
    }
end

-- ===========================
-- GOAL COMPLETION
-- ===========================

function GoalTracker:OnGoalCompleted(goal)
    print("|cff00ff00[Arenamaster]|r 🎉 GOAL ACHIEVED: " .. goal.name .. "!")
    print("|cff00ff00Reward: " .. goal.reward .. "|r")

    -- Play success sound
    PlaySoundFile("Sound\\Interface\\UI\\TalentScreenOpen.ogg", "Master")

    -- Trigger notification
    if AM.SmartNotifications then
        AM.SmartNotifications:Notify("🎉 GOAL", goal.name .. " achieved!", "HIGH")
    end
end

-- ===========================
-- QUERIES & REPORTING
-- ===========================

function GoalTracker:GetAllGoals()
    return ArenamasterDB.goals or {}
end

function GoalTracker:GetActiveGoals()
    local active = {}
    for _, goal in ipairs(ArenamasterDB.goals or {}) do
        if not goal.completed then
            table.insert(active, goal)
        end
    end
    return active
end

function GoalTracker:GetCompletedGoals()
    local completed = {}
    for _, goal in ipairs(ArenamasterDB.goals or {}) do
        if goal.completed then
            table.insert(completed, goal)
        end
    end
    return completed
end

function GoalTracker:GetNextMilestone()
    local activeGoals = self:GetActiveGoals()

    if #activeGoals == 0 then
        return nil
    end

    -- Find goal closest to completion
    local closest = activeGoals[1]
    local closestPercent = self:GetGoalProgress(closest).percent

    for i = 2, #activeGoals do
        local goal = activeGoals[i]
        local percent = self:GetGoalProgress(goal).percent

        if percent > closestPercent then
            closest = goal
            closestPercent = percent
        end
    end

    return {
        goal = closest,
        progress = self:GetGoalProgress(closest),
        estimate = self:EstimateTimeToGoal(closest),
    }
end

-- ===========================
-- PRINTING & DEBUG
-- ===========================

function GoalTracker:PrintGoals()
    self:UpdateGoalProgress()

    local active = self:GetActiveGoals()
    local completed = self:GetCompletedGoals()

    print("|cff00ffff╔═══════════════════════════════════╗|r")
    print("|cff00ffff║       YOUR GOALS & PROGRESS       ║|r")
    print("|cff00ffff╠═══════════════════════════════════╣|r")

    if #active > 0 then
        print("|cff00ff00ACTIVE GOALS|r")
        for i, goal in ipairs(active) do
            local progress = self:GetGoalProgress(goal)
            local bar = self:CreateProgressBar(progress.percent, 30)
            print(string.format("#%d: %s %s %.0f%%",
                i, goal.name, bar, progress.percent))
            print(string.format("   Progress: %d / %d",
                progress.current, progress.target))
        end
    end

    if #completed > 0 then
        print("|cff00ffff|cffccccccCOMPLETED GOALS|r")
        for i, goal in ipairs(completed) do
            print("✓ " .. goal.name .. " (" .. goal.completedAt .. ")")
        end
    end

    print("|cff00ffff╚═══════════════════════════════════╝|r")
end

function GoalTracker:PrintNextMilestone()
    local milestone = self:GetNextMilestone()

    if not milestone then
        print("|cffff0000No active goals|r")
        return
    end

    local goal = milestone.goal
    local progress = milestone.progress
    local estimate = milestone.estimate

    print("|cff00ffff═══════════════════════════════════|r")
    print("|cff00ff00NEXT MILESTONE|r")
    print("|cff00ffff═══════════════════════════════════|r")
    print("Goal: " .. goal.name)
    print("Progress: " .. progress.current .. " / " .. goal.target)
    print("Remaining: " .. progress.remaining)
    print("Estimate: " .. estimate.estimate)
    print("|cff00ffff═══════════════════════════════════|r")
end

function GoalTracker:CreateProgressBar(percent, width)
    width = width or 20
    local filled = math.floor((percent / 100) * width)
    local empty = width - filled

    local bar = ""
    for i = 1, filled do bar = bar .. "█" end
    for i = 1, empty do bar = bar .. "░" end

    return "[" .. bar .. "]"
end

-- Export
AM.GoalTracker = GoalTracker

return GoalTracker
