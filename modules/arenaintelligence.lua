-- Arenamaster: Advanced Arena Intelligence System
-- Complete implementation of DR tracking, predictions, and real-time analytics

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local ArenaIntelligence = Arenamaster:NewModule("ArenaIntelligence", "AceEvent-3.0", "AceTimer-3.0")

-- ===========================
-- DIMINISHING RETURNS SYSTEM
-- ===========================

local DR_CHAINS = {
	stun = {
		effects = {"stun", "bash", "asphyxiate", "hammer_of_justice"},
		duration = 6000,  -- 6 seconds in milliseconds
		reset_time = 15,  -- seconds before reset
	},
	silence = {
		effects = {"silence", "interrupt", "counterspell", "kick"},
		duration = 4000,
		reset_time = 15,
	},
	root = {
		effects = {"root", "frozen", "snare", "entangle"},
		duration = 8000,
		reset_time = 15,
	},
	disorient = {
		effects = {"disorient", "polymorph", "hex", "ring_of_peace"},
		duration = 6000,
		reset_time = 15,
	},
	fear = {
		effects = {"fear", "horror", "mortal_coil"},
		duration = 6000,
		reset_time = 15,
	},
	slow = {
		effects = {"slow", "chill", "haste_slow"},
		duration = 8000,
		reset_time = 15,
	},
}

local drTracking = {
	-- arena1 = {chain = "stun", lastHit = 0, applications = 0, reduction = 0}
}

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaIntelligence:OnInitialize()
	drTracking = {}

	if not Arenamaster.db.profile.drTracking then
		Arenamaster.db.profile.drTracking = {}
	end

	if not Arenamaster.db.profile.arenaStats then
		Arenamaster.db.profile.arenaStats = {
			matchStartTime = 0,
			damageDealt = 0,
			damageTaken = 0,
			healingDone = 0,
			kills = 0,
			deaths = 0,
			ccsApplied = 0,
			ccsReceived = 0,
			interruptsApplied = 0,
			dispelsApplied = 0,
		}
	end
end

function ArenaIntelligence:OnEnable()
	self:RegisterEvent("ARENA_MATCH_START")
	self:RegisterEvent("ARENA_MATCH_END")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_AURA")

	self:ScheduleRepeatingTimer("UpdateDRStatus", 0.1)
end

-- ===========================
-- DIMINISHING RETURNS TRACKING
-- ===========================

function ArenaIntelligence:ApplyCCEffect(targetUnit, effectType, chainType)
	if not drTracking[targetUnit] then
		drTracking[targetUnit] = {}
	end

	local now = GetTime()

	if not drTracking[targetUnit][chainType] then
		drTracking[targetUnit][chainType] = {
			lastHit = now,
			applications = 0,
			reduction = 0,
			nextReset = now + 15,
		}
	end

	local chain = drTracking[targetUnit][chainType]

	-- Check if chain needs reset
	if now > chain.nextReset then
		chain.applications = 0
		chain.reduction = 0
	end

	-- Apply reduction
	chain.applications = chain.applications + 1
	chain.lastHit = now
	chain.nextReset = now + 15

	-- Calculate DR reduction (25%, 50%, 75%, immune)
	local reductions = {0.25, 0.50, 0.75, 1.0}  -- Immunity on 4th
	chain.reduction = reductions[math.min(chain.applications, 4)]

	Arenamaster.db.profile.drTracking[targetUnit] = chain

	if Arenamaster.db.profile.debugMode then
		local drPercent = chain.reduction * 100
		Arenamaster:PrintDebug(targetUnit .. " " .. chainType .. " DR: " .. drPercent .. "%")
	end

	return chain.reduction
end

function ArenaIntelligence:GetDRStatus(targetUnit, chainType)
	if not drTracking[targetUnit] or not drTracking[targetUnit][chainType] then
		return {
			applications = 0,
			reduction = 0,
			percent = 100,
			percentage = "100%",
			status = "Full",
		}
	end

	local chain = drTracking[targetUnit][chainType]
	local percentValue = math.floor((1 - chain.reduction) * 100)
	return {
		applications = chain.applications,
		reduction = chain.reduction,
		percent = percentValue,
		percentage = percentValue .. "%",
		status = chain.reduction == 1 and "Immune" or "Active",
	}
end

function ArenaIntelligence:UpdateDRStatus()
	local now = GetTime()

	for unit, chains in pairs(drTracking) do
		for chainType, data in pairs(chains) do
			-- Reset if needed
			if now > data.nextReset then
				data.applications = 0
				data.reduction = 0
			end
		end
	end
end

-- ===========================
-- INTERRUPT PREDICTION ENGINE
-- ===========================

local interruptPatterns = {
	-- unit = {spellName = {lastUsed, cooldown, pattern}}
}

local INTERRUPT_COOLDOWNS = {
	["Kick"] = 15,
	["Counterspell"] = 24,
	["Pummel"] = 6,
	["Spellsteal"] = 10,
	["Interrupt"] = 15,
	["Silence"] = 60,
	["Stun"] = 8,
}

function ArenaIntelligence:RecordInterruptUsage(unit, spellName)
	if not interruptPatterns[unit] then
		interruptPatterns[unit] = {}
	end

	local cooldown = INTERRUPT_COOLDOWNS[spellName] or 15
	local now = GetTime()

	if not interruptPatterns[unit][spellName] then
		interruptPatterns[unit][spellName] = {
			lastUsed = now,
			cooldown = cooldown,
			pattern = {},
		}
	end

	local pattern = interruptPatterns[unit][spellName]
	pattern.lastUsed = now
	table.insert(pattern.pattern, now)

	-- Keep last 10 uses
	if #pattern.pattern > 10 then
		table.remove(pattern.pattern, 1)
	end
end

function ArenaIntelligence:PredictInterruptAvailability(unit, spellName)
	if not interruptPatterns[unit] or not interruptPatterns[unit][spellName] then
		return {
			available = true,
			confidence = 0.5,
			estimatedReady = GetTime(),
			cooldown = INTERRUPT_COOLDOWNS[spellName] or 15,
		}
	end

	local pattern = interruptPatterns[unit][spellName]
	local cooldown = pattern.cooldown
	local lastUsed = pattern.lastUsed
	local now = GetTime()
	local timeSinceUse = now - lastUsed

	local prediction = {
		available = timeSinceUse >= cooldown,
		cooldown = cooldown,
		timeSinceUse = timeSinceUse,
		estimatedReady = lastUsed + cooldown,
		remainingTime = math.max(0, cooldown - timeSinceUse),
	}

	-- Calculate confidence based on pattern consistency
	if #pattern.pattern >= 3 then
		local intervals = {}
		for i = 2, #pattern.pattern do
			table.insert(intervals, pattern.pattern[i] - pattern.pattern[i-1])
		end

		local avgInterval = 0
		for _, interval in ipairs(intervals) do
			avgInterval = avgInterval + interval
		end
		avgInterval = avgInterval / #intervals

		local variance = 0
		for _, interval in ipairs(intervals) do
			variance = variance + (interval - avgInterval) ^ 2
		end
		variance = variance / #intervals

		-- High consistency = high confidence
		local stddev = math.sqrt(variance)
		local consistency = avgInterval > 0 and (1 - math.min(1, stddev / avgInterval)) or 0.5
		prediction.confidence = math.max(0.5, consistency)
	else
		prediction.confidence = 0.5
	end

	return prediction
end

-- ===========================
-- COMBAT ANALYTICS ENGINE
-- ===========================

function ArenaIntelligence:StartMatchAnalytics()
	Arenamaster.db.profile.arenaStats = {
		matchStartTime = GetTime(),
		damageDealt = 0,
		damageTaken = 0,
		healingDone = 0,
		kills = 0,
		deaths = 0,
		ccsApplied = 0,
		ccsReceived = 0,
		interruptsApplied = 0,
		dispelsApplied = 0,
		events = {},
	}
end

function ArenaIntelligence:LogCombatEvent(eventType, source, target, spell, amount)
	if not Arenamaster.db.profile.arenaStats.events then
		Arenamaster.db.profile.arenaStats.events = {}
	end

	local event = {
		type = eventType,
		source = source,
		target = target,
		spell = spell,
		amount = amount or 0,
		timestamp = GetTime() - (Arenamaster.db.profile.arenaStats.matchStartTime or 0),
	}

	table.insert(Arenamaster.db.profile.arenaStats.events, event)

	-- Update stats
	if eventType == "damage" then
		if source == "player" then
			Arenamaster.db.profile.arenaStats.damageDealt = (Arenamaster.db.profile.arenaStats.damageDealt or 0) + amount
		elseif target == "player" then
			Arenamaster.db.profile.arenaStats.damageTaken = (Arenamaster.db.profile.arenaStats.damageTaken or 0) + amount
		end
	elseif eventType == "heal" then
		if source == "player" then
			Arenamaster.db.profile.arenaStats.healingDone = (Arenamaster.db.profile.arenaStats.healingDone or 0) + amount
		end
	elseif eventType == "cc" then
		if source == "player" then
			Arenamaster.db.profile.arenaStats.ccsApplied = (Arenamaster.db.profile.arenaStats.ccsApplied or 0) + 1
		elseif target == "player" then
			Arenamaster.db.profile.arenaStats.ccsReceived = (Arenamaster.db.profile.arenaStats.ccsReceived or 0) + 1
		end
	end

	-- Keep only last 1000 events
	if #Arenamaster.db.profile.arenaStats.events > 1000 then
		table.remove(Arenamaster.db.profile.arenaStats.events, 1)
	end
end

function ArenaIntelligence:GetMatchStats()
	return CopyTable(Arenamaster.db.profile.arenaStats or {})
end

function ArenaIntelligence:GetDPS()
	local stats = Arenamaster.db.profile.arenaStats
	if not stats or not stats.matchStartTime then
		return 0
	end

	local duration = GetTime() - stats.matchStartTime
	if duration <= 0 then
		return 0
	end

	return math.floor((stats.damageDealt or 0) / duration)
end

function ArenaIntelligence:GetHPS()
	local stats = Arenamaster.db.profile.arenaStats
	if not stats or not stats.matchStartTime then
		return 0
	end

	local duration = GetTime() - stats.matchStartTime
	if duration <= 0 then
		return 0
	end

	return math.floor((stats.healingDone or 0) / duration)
end

-- ===========================
-- ADVANCED THREAT ALGORITHM
-- ===========================

function ArenaIntelligence:CalculateAdvancedThreat(unit)
	-- Multi-factor threat scoring
	local score = 0
	local factors = {}

	-- Factor 1: Health (30%)
	local health = UnitHealth(unit)
	local maxHealth = UnitHealthMax(unit)
	local healthPercent = maxHealth > 0 and (health / maxHealth) * 100 or 0
	local healthScore = healthPercent * 0.3
	factors.health = healthScore

	-- Factor 2: Offensive Cooldowns (25%)
	local offensiveScore = 0
	if self:HasAuraByType(unit, "offensive") then
		offensiveScore = 25
	end
	factors.offensive = offensiveScore

	-- Factor 3: Defensive Cooldowns (20%)
	local defensiveScore = 0
	if self:HasAuraByType(unit, "defensive") then
		defensiveScore = 0  -- Lower threat if defensive
	else
		defensiveScore = 20
	end
	factors.defensive = defensiveScore

	-- Factor 4: Class Damage Potential (15%)
	local classScore = self:GetClassDamageScore(unit)
	factors.classScore = classScore

	-- Factor 5: Distance/Position (10%)
	local distanceScore = 0
	if self:IsTargetNearby(unit) then
		distanceScore = 10
	end
	factors.distance = distanceScore

	-- Calculate total
	score = healthScore + offensiveScore + defensiveScore + classScore + distanceScore

	return {
		score = math.floor(score),
		maxScore = 100,
		percentage = math.min(math.floor(score), 100),
		factors = factors,
	}
end

function ArenaIntelligence:HasAuraByType(unit, auraType)
	-- Check for specific offensive/defensive aura types
	if auraType == "offensive" then
		-- Check for offensive buffs/cooldowns
		local offensiveAuras = {
			"Bloodlust", "Haste", "Heroism", "Time Warp",
			"Power Infusion", "Combustion", "Avatar",
			"Enrage", "Avenging Wrath", "Incarnation",
			"Berserk", "Primal Wrath", "Lust"
		}
		for _, auraName in ipairs(offensiveAuras) do
			if UnitAura(unit, auraName) then
				return true
			end
		end
		return false
	elseif auraType == "defensive" then
		-- Check for defensive buffs/cooldowns
		local defensiveAuras = {
			"Barrier", "Shield", "Divine Shield", "Protection",
			"Defensive Stance", "Ironbark", "Iceblock",
			"Darkness", "Reflection", "Guardian Spirit",
			"Power Word: Shield", "Unbreakable", "Fortified"
		}
		for _, auraName in ipairs(defensiveAuras) do
			if UnitAura(unit, auraName) then
				return true
			end
		end
		return false
	end
	return false
end

function ArenaIntelligence:GetClassDamageScore(unit)
	-- Damage potential by class
	local classScores = {
		WARRIOR = 25,
		ROGUE = 25,
		SHAMAN = 20,
		DRUID = 20,
		WARLOCK = 20,
		MAGE = 15,
		PRIEST = 10,
		PALADIN = 15,
		DEATHKNIGHT = 25,
		DEMON_HUNTER = 25,
		MONK = 20,
		EVOKER = 20,
	}

	if not UnitExists(unit) then return 15 end
	local _, class = UnitClass(unit)
	return classScores[class] or 15
end

function ArenaIntelligence:IsTargetNearby(unit)
	-- Check if within arena relevant distance (40 yards for melee relevance)
	if not UnitExists(unit) then return false end

	local distance = UnitDistance(unit)
	if not distance then return false end

	-- Convert yards to distance check (40 yards is typical arena engagement range)
	return distance <= 40
end

-- ===========================
-- EVENT HANDLERS
-- ===========================

function ArenaIntelligence:ARENA_MATCH_START()
	self:StartMatchAnalytics()
	drTracking = {}
	interruptPatterns = {}
	Arenamaster:PrintDebug("Arena Intelligence started - tracking enabled")
end

function ArenaIntelligence:ARENA_MATCH_END()
	Arenamaster:PrintDebug("Arena Intelligence - match ended")
end

function ArenaIntelligence:UNIT_SPELLCAST_SUCCEEDED(event, unit, castGUID, spellID)
	-- Track interrupt usage
	if self:IsInterruptSpell(spellID) then
		local spellName = GetSpellInfo(spellID)
		self:RecordInterruptUsage(unit, spellName)
		self:LogCombatEvent("interrupt", unit, "target", spellName)
	end
end

function ArenaIntelligence:UNIT_AURA(event, unit)
	-- Track CC applications in real-time
	if not string.find(unit, "^arena%d$") then return end

	-- Check all current auras on the unit
	local index = 1
	while true do
		local auraName, icon, count, debuffType, duration, expirationTime, caster = UnitAura(unit, index)

		if not auraName then break end

		-- Check if this aura is in our DR chains
		for chainType, chainData in pairs(DR_CHAINS) do
			for _, effect in ipairs(chainData.effects) do
				if string.lower(auraName):find(string.lower(effect)) or effect == string.lower(auraName) then
					-- This is a CC effect, track it
					local casterName = caster and UnitName(caster) or "Unknown"
					self:ApplyCCEffect(unit, auraName, chainType)

					-- Debug output if enabled
					if Arenamaster.db.profile.debugMode then
						Arenamaster:PrintDebug(unit .. " hit by " .. chainType .. ": " .. auraName .. " from " .. casterName)
					end
					break
				end
			end
		end

		index = index + 1
	end
end

function ArenaIntelligence:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
	-- Parse combat log for detailed damage, healing, and CC events
	local args = {...}

	-- Track damage events
	if eventType == "SPELL_DAMAGE" or eventType == "SWING_DAMAGE" or eventType == "RANGE_DAMAGE" then
		local spellID, spellName, spellSchool = args[1], args[2], args[3]
		local amount = args[4]

		if string.find(srcGUID, "Player") and string.find(dstGUID, "Creature") == nil then
			self:LogCombatEvent("damage", srcName, dstName, spellName or "Attack", amount)
		end
	end

	-- Track healing events
	if eventType == "SPELL_HEAL" then
		local spellID, spellName, spellSchool = args[1], args[2], args[3]
		local amount, overheal = args[4], args[5]

		if string.find(srcGUID, "Player") then
			self:LogCombatEvent("heal", srcName, dstName, spellName, amount)
		end
	end

	-- Track interrupt events
	if eventType == "SPELL_INTERRUPT" then
		local spellID, spellName = args[1], args[2]
		local extraSpellID, extraSpellName = args[3], args[4]

		if string.find(srcGUID, "Player") then
			self:RecordInterruptUsage(srcName, spellName)
			self:LogCombatEvent("interrupt", srcName, dstName, spellName)
		end
	end

	-- Track crowd control applications
	if eventType == "SPELL_AURA_APPLIED" then
		local spellID, spellName, spellSchool = args[1], args[2], args[3]
		local auraType = args[4]

		-- Check if this is a CC aura
		for chainType, chainData in pairs(DR_CHAINS) do
			for _, effect in ipairs(chainData.effects) do
				if effect == string.lower(spellName or "") then
					if string.find(srcGUID, "Player") then
						self:ApplyCCEffect(dstName, spellName, chainType)
						self:LogCombatEvent("cc", srcName, dstName, spellName)
					end
				end
			end
		end
	end

	-- Track dispels
	if eventType == "SPELL_DISPEL" or eventType == "SPELL_STOLEN" then
		local spellID, spellName = args[1], args[2]

		if string.find(srcGUID, "Player") then
			self:LogCombatEvent("dispel", srcName, dstName, spellName)
		end
	end

	-- Track deaths
	if eventType == "UNIT_DIED" then
		if string.find(srcGUID, "Player") then
			self:LogCombatEvent("death", srcName, "", "Death")
		end
	end
end

-- ===========================
-- UTILITY FUNCTIONS
-- ===========================

function ArenaIntelligence:IsInterruptSpell(spellID)
	-- Check if spell is an interrupt
	local interruptSpells = {
		1766,    -- Kick
		2139,    -- Counterspell
		6552,    -- Pummel
		32379,   -- Shadow Word: Death
	}

	for _, id in ipairs(interruptSpells) do
		if spellID == id then
			return true
		end
	end

	return false
end

function ArenaIntelligence:PrintArenaStats()
	local stats = self:GetMatchStats()

	print("|cff00aiff╔════════════════════════════════════════╗|r")
	print("|cff00aiff║      ARENA INTELLIGENCE REPORT        ║|r")
	print("|cff00aiff╚════════════════════════════════════════╝|r")

	print("|cff4dabf7Damage Stats:|r")
	print("  Damage Dealt: " .. (stats.damageDealt or 0))
	print("  Damage Taken: " .. (stats.damageTaken or 0))
	print("  DPS: " .. self:GetDPS())

	print("|cff4dabf7Healing Stats:|r")
	print("  Healing Done: " .. (stats.healingDone or 0))
	print("  HPS: " .. self:GetHPS())

	print("|cff4dabf7CC Stats:|r")
	print("  CCs Applied: " .. (stats.ccsApplied or 0))
	print("  CCs Received: " .. (stats.ccsReceived or 0))

	print("|cff4dabf7DR Status:|r")
	for unit, chains in pairs(drTracking) do
		for chain, data in pairs(chains) do
			local percent = math.floor((1 - data.reduction) * 100)
			print("  " .. unit .. " " .. chain .. ": " .. percent .. "%")
		end
	end
end
