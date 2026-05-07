-- Arenamaster: Arena Intelligence Performance Monitor
-- Monitors and optimizes Arena Intelligence system performance

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ArenaIntelligencePerformance = Arenamaster:NewModule("ArenaIntelligencePerformance", "AceEvent-3.0", "AceTimer-3.0")

-- Performance metrics
local metrics = {
	drUpdates = 0,
	threatUpdates = 0,
	interruptUpdates = 0,
	eventsLogged = 0,
	lastUpdateTime = 0,
	averageUpdateTime = 0,
	peakMemoryUsage = 0,
}

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaIntelligencePerformance:OnInitialize()
	self:ResetMetrics()
end

function ArenaIntelligencePerformance:OnEnable()
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
	self:ScheduleRepeatingTimer("MonitorPerformance", 5.0)
end

-- ===========================
-- PERFORMANCE MONITORING
-- ===========================

function ArenaIntelligencePerformance:MonitorPerformance()
	-- Check memory usage
	local memoryUsage = self:GetMemoryUsage()
	if memoryUsage > metrics.peakMemoryUsage then
		metrics.peakMemoryUsage = memoryUsage
	end

	-- Optimize if needed
	if memoryUsage > 50 then  -- 50MB threshold
		self:OptimizeMemory()
	end

	-- Check update rates
	if Arenamaster.db.profile.debugMode then
		self:LogPerformanceMetrics()
	end
end

function ArenaIntelligencePerformance:GetMemoryUsage()
	-- Estimate memory usage from active tracking
	local ArenaIntelligence = Arenamaster:GetModule("ArenaIntelligence")
	if not ArenaIntelligence then
		return 0
	end

	local stats = ArenaIntelligence:GetMatchStats()
	local baseMemory = 5  -- Base overhead in MB

	-- Estimate from event count
	local eventMemory = (stats.events and #stats.events or 0) * 0.001  -- ~1KB per event

	return baseMemory + eventMemory
end

function ArenaIntelligencePerformance:OptimizeMemory()
	local ArenaIntelligence = Arenamaster:GetModule("ArenaIntelligence")
	if not ArenaIntelligence then return end

	-- Trim old events
	local stats = ArenaIntelligence:GetMatchStats()
	if stats.events and #stats.events > 500 then
		-- Keep only most recent 500 events
		for i = 1, #stats.events - 500 do
			table.remove(stats.events, 1)
		end
		Arenamaster:PrintDebug("Memory optimized - trimmed old combat events")
	end
end

function ArenaIntelligencePerformance:ResetMetrics()
	metrics = {
		drUpdates = 0,
		threatUpdates = 0,
		interruptUpdates = 0,
		eventsLogged = 0,
		lastUpdateTime = GetTime(),
		averageUpdateTime = 0,
		peakMemoryUsage = self:GetMemoryUsage(),
	}
end

-- ===========================
-- UPDATE TRACKING
-- ===========================

function ArenaIntelligencePerformance:RecordDRUpdate()
	metrics.drUpdates = metrics.drUpdates + 1
end

function ArenaIntelligencePerformance:RecordThreatUpdate()
	metrics.threatUpdates = metrics.threatUpdates + 1
end

function ArenaIntelligencePerformance:RecordInterruptUpdate()
	metrics.interruptUpdates = metrics.interruptUpdates + 1
end

function ArenaIntelligencePerformance:RecordEvent()
	metrics.eventsLogged = metrics.eventsLogged + 1
end

function ArenaIntelligencePerformance:GetUpdateRate()
	local timeSinceReset = GetTime() - metrics.lastUpdateTime
	if timeSinceReset <= 0 then return 0 end

	local totalUpdates = metrics.drUpdates + metrics.threatUpdates + metrics.interruptUpdates
	return totalUpdates / timeSinceReset
end

-- ===========================
-- OPTIMIZATION STRATEGIES
-- ===========================

function ArenaIntelligencePerformance:SetPerformanceMode(mode)
	-- mode: lightweight, balanced, detailed
	local ArenaIntelligenceConfig = Arenamaster:GetModule("ArenaIntelligenceConfig")
	if not ArenaIntelligenceConfig then return end

	if mode == "lightweight" then
		-- Disable expensive features
		Arenamaster.db.profile.arenaIntelligence.threat.enabled = false
		Arenamaster.db.profile.arenaIntelligence.analytics.enabled = false
		Arenamaster.db.profile.arenaIntelligence.interrupt.learning_enabled = false
	elseif mode == "balanced" then
		-- Enable all with moderate update rates
		Arenamaster.db.profile.arenaIntelligence.threat.update_frequency = 0.5
		Arenamaster.db.profile.arenaIntelligence.interrupt.update_frequency = 1.0
		Arenamaster.db.profile.arenaIntelligence.analytics.enabled = true
	elseif mode == "detailed" then
		-- Enable everything with high detail
		Arenamaster.db.profile.arenaIntelligence.threat.update_frequency = 0.2
		Arenamaster.db.profile.arenaIntelligence.interrupt.update_frequency = 0.5
		Arenamaster.db.profile.arenaIntelligence.analytics.enabled = true
		Arenamaster.db.profile.arenaIntelligence.interrupt.learning_enabled = true
	end
end

function ArenaIntelligencePerformance:AutoOptimizePerformance()
	-- Automatically switch to lightweight mode if performance is poor
	local memoryUsage = self:GetMemoryUsage()
	local updateRate = self:GetUpdateRate()

	if memoryUsage > 30 or updateRate > 1000 then
		self:SetPerformanceMode("lightweight")
		Arenamaster:PrintDebug("Switched to lightweight performance mode")
	elseif memoryUsage > 15 or updateRate > 500 then
		self:SetPerformanceMode("balanced")
		Arenamaster:PrintDebug("Switched to balanced performance mode")
	end
end

-- ===========================
-- LOGGING & REPORTING
-- ===========================

function ArenaIntelligencePerformance:LogPerformanceMetrics()
	print("|cff00aiff════════════════════════════════════════|r")
	print("|cff00aiff  ARENA INTELLIGENCE PERFORMANCE         |r")
	print("|cff00aiff════════════════════════════════════════|r")

	print("|cff4dabf7Update Rates:|r")
	print("  DR Updates: " .. metrics.drUpdates)
	print("  Threat Updates: " .. metrics.threatUpdates)
	print("  Interrupt Updates: " .. metrics.interruptUpdates)
	print("  Total Updates/sec: " .. string.format("%.1f", self:GetUpdateRate()))

	print("|cff4dabf7Combat Log:|r")
	print("  Events Logged: " .. metrics.eventsLogged)

	print("|cff4dabf7Memory:|r")
	print("  Current: " .. string.format("%.1f MB", self:GetMemoryUsage()))
	print("  Peak: " .. string.format("%.1f MB", metrics.peakMemoryUsage))

	local mode = Arenamaster.db.profile.arenaIntelligence.display.performance_mode or "balanced"
	print("|cff4dabf7Performance Mode:|r " .. mode)
end

function ArenaIntelligencePerformance:PrintPerformanceReport()
	self:LogPerformanceMetrics()

	print("")
	print("|cff4dabf7Recommendations:|r")

	local memoryUsage = self:GetMemoryUsage()
	if memoryUsage > 20 then
		print("  |cffff0000⚠ High memory usage|r - consider switching to lightweight mode")
	end

	local updateRate = self:GetUpdateRate()
	if updateRate > 500 then
		print("  |cffff0000⚠ High update frequency|r - may impact performance")
	end

	if memoryUsage < 10 and updateRate < 100 then
		print("  |cff00ff00✓ Excellent performance|r")
	end
end

-- ===========================
-- OPTIMIZATION PROFILES
-- ===========================

function ArenaIntelligencePerformance:ApplyProfile(profileName)
	local profiles = {
		streamer = function()
			-- Optimized for streaming with minimal CPU usage
			self:SetPerformanceMode("lightweight")
			Arenamaster.db.profile.arenaIntelligence.display.show_analytics_panel = false
		end,
		competitive = function()
			-- Balanced mode for competitive play
			self:SetPerformanceMode("balanced")
			Arenamaster.db.profile.arenaIntelligence.display.show_analytics_panel = true
		end,
		detail = function()
			-- Maximum detail for analysis
			self:SetPerformanceMode("detailed")
			Arenamaster.db.profile.arenaIntelligence.display.show_analytics_panel = true
		end,
		lowend = function()
			-- For lower-end machines
			Arenamaster.db.profile.arenaIntelligence.dr.enabled = true
			Arenamaster.db.profile.arenaIntelligence.threat.enabled = false
			Arenamaster.db.profile.arenaIntelligence.analytics.enabled = false
		end,
	}

	if profiles[profileName] then
		profiles[profileName]()
		print("|cff00ff00✓ Applied " .. profileName .. " performance profile|r")
	else
		print("|cffff0000Unknown profile: " .. profileName .. "|r")
	end
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function ArenaIntelligencePerformance:ARENA_MATCH_START()
	self:ResetMetrics()
	Arenamaster:PrintDebug("Arena Intelligence performance monitoring started")
end

function ArenaIntelligencePerformance:ARENA_MATCH_END()
	self:PrintPerformanceReport()
end

-- ===========================
-- PUBLIC API
-- ===========================

function ArenaIntelligencePerformance:GetMetrics()
	return {
		drUpdates = metrics.drUpdates,
		threatUpdates = metrics.threatUpdates,
		interruptUpdates = metrics.interruptUpdates,
		eventsLogged = metrics.eventsLogged,
		memoryUsage = self:GetMemoryUsage(),
		peakMemoryUsage = metrics.peakMemoryUsage,
		updateRate = self:GetUpdateRate(),
	}
end
