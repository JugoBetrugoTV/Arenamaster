-- Arenamaster Core
-- Umfassendes PvP-Addon für WoW 12.0.5

local ADDON_NAME = "Arenamaster"
local ADDON_VERSION = "1.0.0"

-- Namespace erstellen
Arenamaster = {}
local AM = Arenamaster

-- Lokale Variablen
local frame
local isInitialized = false
local currentMatch = nil
local matchStartTime = 0

-- ===========================
-- INITIALISIERUNG
-- ===========================

function AM:Initialize()
    if isInitialized then return end

    print("|cff00ff00[Arenamaster]|r v" .. ADDON_VERSION .. " erfolgreich geladen!")

    -- Einstellungen laden
    self:LoadSettings()

    -- Config Manager initialisieren
    self.ConfigManager:Initialize()

    -- Stats initialisieren
    self:InitializeStats()

    -- Module initialisieren
    self.EnemyFrames:Initialize()
    self.AuraTracker:Initialize()
    self.OpponentTracker:Initialize()
    self.RatingTracker:Initialize()
    self.ThreatDetector:Initialize()
    self.CooldownPredictor:Initialize()
    self.CombatAnalytics:Initialize()
    self.SmartNotifications:Initialize()
    self.ArenaMap:Initialize()
    self.OpponentProfiler:Initialize()
    self.MatchPredictor:Initialize()
    self.SmartCallouts:Initialize()
    self.GoalTracker:Initialize()
    self.ConfigUI:Initialize()

    -- UI erstellen
    self:CreateUI()

    -- Events registrieren
    self:RegisterEvents()

    -- Gegner-Tracker starten
    self:StartOpponentTracking()

    -- Periodic updates für Threat Detection
    C_Timer.After(0.5, function()
        if currentMatch then
            AM.ThreatDetector:UpdateAllThreats()
        end
    end)

    isInitialized = true
    print("|cff00ff00[Arenamaster]|r v" .. ADDON_VERSION .. " Arena-Tracking aktiviert.")
    print("|cff00ffff/am|r - UI | |cff00ffff/am settings|r - Config | |cff00ffff/am help|r - Commands")
end

-- ===========================
-- SETTINGS-SYSTEM
-- ===========================

function AM:LoadSettings()
    if not ArenamasterDB then
        ArenamasterDB = {
            windowPos = { x = 100, y = 100 },
            visible = false,
            debugMode = false,
            trackOpponents = true,
            trackCooldowns = true,
            notifyMatches = true,
            rating = 0,
            tier = "Unranked"
        }
    end
end

function AM:SaveSettings()
    if frame then
        local scale = frame:GetScale()
        local x = frame:GetLeft() * scale
        local y = frame:GetTop() * scale
        ArenamasterDB.windowPos = { x = x, y = y }
        ArenamasterDB.visible = frame:IsVisible()
    end
end

-- ===========================
-- STATISTIK-SYSTEM
-- ===========================

function AM:InitializeStats()
    if not ArenamasterDB.stats then
        ArenamasterDB.stats = {
            totalMatches = 0,
            totalWins = 0,
            totalLosses = 0,
            streak = 0,
            bestStreak = 0,
            opponents = {},
            seasonStats = {}
        }
    end
end

function AM:RecordMatch(result, opponents, duration)
    local stats = ArenamasterDB.stats
    stats.totalMatches = stats.totalMatches + 1

    if result == "WIN" then
        stats.totalWins = stats.totalWins + 1
        stats.streak = stats.streak + 1
        if stats.streak > stats.bestStreak then
            stats.bestStreak = stats.streak
        end
    else
        stats.totalLosses = stats.totalLosses + 1
        stats.streak = 0
    end

    -- Gegner speichern
    if opponents then
        for _, opponent in ipairs(opponents) do
            if not stats.opponents[opponent] then
                stats.opponents[opponent] = { wins = 0, losses = 0 }
            end
            if result == "WIN" then
                stats.opponents[opponent].wins = stats.opponents[opponent].wins + 1
            else
                stats.opponents[opponent].losses = stats.opponents[opponent].losses + 1
            end
        end
    end
end

function AM:GetWinrate()
    local stats = ArenamasterDB.stats
    if stats.totalMatches == 0 then return 0 end
    return math.floor((stats.totalWins / stats.totalMatches) * 100)
end

-- ===========================
-- UI ERSTELLEN
-- ===========================

function AM:CreateUI()
    -- Hauptfenster
    frame = CreateFrame("Frame", "ArenamasterMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(400, 300)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    
    -- Hintergrund und Border
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    frame:SetBackdropBorderColor(0, 0.8, 1, 0.8)
    
    -- Titelleiste
    local titlebar = CreateFrame("Frame", nil, frame)
    titlebar:SetSize(400, 30)
    titlebar:SetPoint("TOP", frame, "TOP", 0, 0)
    
    -- Titel-Text
    local title = titlebar:CreateFontString(nil, "OVERLAY")
    title:SetFontObject("GameFontNormalLarge")
    title:SetText("|cff00ffffArenamaster|r v" .. ADDON_VERSION)
    title:SetPoint("LEFT", titlebar, "LEFT", 10, 0)
    
    -- Close Button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() AM:ToggleUI() end)
    
    -- Content Area
    local content = CreateFrame("Frame", nil, frame)
    content:SetSize(380, 240)
    content:SetPoint("TOP", frame, "TOP", 0, -35)
    
    -- Tabs erstellen
    self:CreateTabs(content)
    
    -- Speichern
    self.mainFrame = frame
    self.contentFrame = content
    
    -- Verstecken (wird später per /am angezeigt)
    frame:Hide()
end

-- ===========================
-- TABS ERSTELLEN
-- ===========================

function AM:CreateTabs(parent)
    local tabs = {}
    local tabButtons = {}
    local tabHeight = 25
    
    -- Tab Daten
    local tabData = {
        { name = "Dashboard", id = "dashboard" },
        { name = "Statistiken", id = "stats" },
        { name = "Einstellungen", id = "settings" }
    }
    
    -- Tab Buttons erstellen
    for i, tab in ipairs(tabData) do
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(120, tabHeight)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", (i-1) * 125, 0)
        
        local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        btnText:SetText(tab.name)
        btnText:SetPoint("CENTER", btn, "CENTER")
        
        btn:SetNormalFontObject("GameFontNormal")
        btn:SetHighlightFontObject("GameFontHighlight")
        
        btn:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
        btn:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
        btn:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
        
        btn.tabId = tab.id
        btn:SetScript("OnClick", function(self) AM:SelectTab(self.tabId) end)
        
        table.insert(tabButtons, btn)
    end
    
    -- Tab Content Frames
    local tabContents = {}
    for _, tab in ipairs(tabData) do
        local content = CreateFrame("Frame", nil, parent)
        content:SetSize(380, 210)
        content:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -tabHeight)
        content:Hide()
        
        -- Beispiel Content
        local text = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -10)
        text:SetText("Tab: " .. tab.name)
        
        if tab.id == "dashboard" then
            self:CreateDashboardTab(content)
        elseif tab.id == "stats" then
            self:CreateStatsTab(content)
        elseif tab.id == "settings" then
            self:CreateSettingsTab(content)
        end
        
        tabContents[tab.id] = content
    end
    
    parent.tabs = tabContents
    parent.tabButtons = tabButtons
    
    -- Erstes Tab anzeigen
    tabContents.dashboard:Show()
    tabButtons[1]:SetButtonState("PUSHED", true)
end

-- ===========================
-- TAB INHALTE
-- ===========================

function AM:CreateDashboardTab(parent)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    text:SetText("🎯 Dashboard")

    local yOffset = -35

    -- Rating und Tier
    local ratingText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ratingText:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    ratingText:SetText("Rating: |cff00ffff" .. (ArenamasterDB.rating or 0) .. "|r - " .. (ArenamasterDB.tier or "Unranked"))
    yOffset = yOffset - 20

    -- Current Match Status
    local matchStatus = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    matchStatus:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    if currentMatch then
        matchStatus:SetText("|cff00ff00⚔️ IN MATCH|r")
    else
        matchStatus:SetText("Status: |cff808080⏸ Wartend|r")
    end
    parent.matchStatus = matchStatus
    yOffset = yOffset - 20

    -- Streak Info
    local streakText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    streakText:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    local stats = ArenamasterDB.stats
    local streakColor = stats.streak > 0 and "|cff00ff00" or "|cffff0000"
    streakText:SetText("Streak: " .. streakColor .. stats.streak .. "|r (Best: " .. stats.bestStreak .. ")")
    parent.streakText = streakText
    yOffset = yOffset - 20

    -- Performance Bar
    local performanceBar = CreateFrame("StatusBar", nil, parent)
    performanceBar:SetSize(360, 15)
    performanceBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    performanceBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    performanceBar:SetStatusBarColor(0, 0.8, 1, 0.8)
    performanceBar:SetMinMaxValues(0, 100)
    performanceBar:SetValue(self:GetWinrate())
    performanceBar:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 1
    })
    performanceBar:SetBackdropColor(0.1, 0.1, 0.1, 0.5)

    local perfLabel = performanceBar:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    perfLabel:SetPoint("CENTER", performanceBar, "CENTER")
    perfLabel:SetText("Winrate: " .. self:GetWinrate() .. "%")
    parent.performanceBar = performanceBar
    yOffset = yOffset - 25

    -- THREAT DETECTION
    if currentMatch then
        local threatTitle = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        threatTitle:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
        threatTitle:SetText("⚠️ Threat Level")
        threatTitle:SetTextColor(1, 0, 0)
        yOffset = yOffset - 18

        local focusRec = self.ThreatDetector:GetFocusRecommendation()
        if focusRec then
            local focusText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            focusText:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, yOffset)
            local threatColor = self.ThreatDetector:GetThreatText(focusRec.score)
            focusText:SetText(threatColor .. " Focus: |cffff8000" .. focusRec.name .. "|r")
            yOffset = yOffset - 18
        end

        -- Next threats
        local threats = self.ThreatDetector:GetAllThreats()
        for i = 1, math.min(2, #threats) do
            local threat = threats[i]
            local threatText = parent:CreateFontString(nil, "OVERLAY", "GameFontSmall")
            threatText:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, yOffset)
            local threatColor = self.ThreatDetector:GetFrameColor(threat.unit)
            threatText:SetText(string.format("|cff%02x%02x%02x#%d: %.1f|r %s",
                threatColor.r * 255, threatColor.g * 255, threatColor.b * 255,
                threat.index, threat.threat, threat.name))
            yOffset = yOffset - 16
        end

        -- Cooldown Alerts
        yOffset = yOffset - 5
        local alertTitle = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        alertTitle:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
        alertTitle:SetText("⏱️ Cooldowns")
        alertTitle:SetTextColor(0, 1, 1)
        yOffset = yOffset - 18

        local alerts = self.CooldownPredictor:GetCriticalAlerts()
        for i = 1, math.min(2, #alerts) do
            local alert = alerts[i]
            local alertText = parent:CreateFontString(nil, "OVERLAY", "GameFontSmall")
            alertText:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, yOffset)
            alertText:SetText(string.format("|cffff0000%s|r ready in |cff00ff00%.1fs|r", alert.danger, alert.readyIn))
            yOffset = yOffset - 16
        end
    end
end

function AM:CreateStatsTab(parent)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    text:SetText("Statistiken")

    local stats = ArenamasterDB.stats

    local statTexts = {
        "Gesamt Matches: " .. stats.totalMatches,
        "Gewonnene Spiele: " .. stats.totalWins,
        "Verlorene Spiele: " .. stats.totalLosses,
        "Winrate: " .. self:GetWinrate() .. "%",
        "Best Streak: " .. stats.bestStreak
    }

    for i, stat in ipairs(statTexts) do
        local line = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        line:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -40 - (i-1) * 22)
        line:SetText(stat)
    end

    -- Gegner-Historie Title
    local historyTitle = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    historyTitle:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -140)
    historyTitle:SetText("Häufigste Gegner:")

    -- Top 5 Gegner anzeigen
    local opponents = stats.opponents
    local topOpponents = {}
    for name, record in pairs(opponents) do
        table.insert(topOpponents, { name = name, wins = record.wins, losses = record.losses })
    end
    table.sort(topOpponents, function(a, b) return (a.wins + a.losses) > (b.wins + b.losses) end)

    for i = 1, math.min(5, #topOpponents) do
        local opp = topOpponents[i]
        local line = parent:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        line:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, -165 - (i-1) * 18)
        local total = opp.wins + opp.losses
        local rate = total > 0 and math.floor((opp.wins / total) * 100) or 0
        line:SetText(opp.name .. " (W:" .. opp.wins .. " L:" .. opp.losses .. " / " .. rate .. "%)")
    end
end

function AM:CreateSettingsTab(parent)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    text:SetText("⚙️ Einstellungen")

    local yOffset = -35

    -- Settings Categories
    local categories = self.ConfigManager:GetCategories()

    for catIndex, category in ipairs(categories) do
        -- Category Title
        local catTitle = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        catTitle:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
        catTitle:SetTextColor(0, 1, 1)
        catTitle:SetText("▸ " .. category)
        yOffset = yOffset - 18

        -- Get settings for this category
        local settings = self.ConfigManager:GetSettings(category)

        for _, setting in ipairs(settings) do
            if setting.type == "checkbox" then
                local toggle = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
                toggle:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
                toggle:SetChecked(self.ConfigManager:Get(setting.key))
                toggle:SetScript("OnClick", function(self)
                    AM.ConfigManager:Set(setting.key, self:GetChecked())
                    print("|cff00ff00[Arenamaster]|r " .. setting.name .. ": " .. (self:GetChecked() and "✓" or "✗"))
                end)

                local label = toggle:CreateFontString(nil, "OVERLAY", "GameFontSmall")
                label:SetText(setting.name)
                label:SetPoint("LEFT", toggle, "RIGHT", 5, 0)

                if setting.description then
                    local desc = parent:CreateFontString(nil, "OVERLAY", "GameFontSmall")
                    desc:SetText("|cff808080" .. setting.description .. "|r")
                    desc:SetPoint("LEFT", label, "RIGHT", 10, 0)
                end

                yOffset = yOffset - 18

            elseif setting.type == "slider" then
                local label = parent:CreateFontString(nil, "OVERLAY", "GameFontSmall")
                label:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
                label:SetText(setting.name .. ": " .. self.ConfigManager:Get(setting.key))
                yOffset = yOffset - 16

                local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
                slider:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
                slider:SetWidth(120)
                slider:SetMinMaxValues(setting.min, setting.max)
                slider:SetValue(self.ConfigManager:Get(setting.key))
                slider:SetValueStep(setting.step)
                slider:SetScript("OnValueChanged", function(self, value)
                    value = math.floor(value * 10) / 10
                    AM.ConfigManager:Set(setting.key, value)
                    label:SetText(setting.name .. ": " .. value)
                end)

                yOffset = yOffset - 20

            elseif setting.type == "select" then
                local label = parent:CreateFontString(nil, "OVERLAY", "GameFontSmall")
                label:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
                label:SetText(setting.name)
                yOffset = yOffset - 16

                for i, option in ipairs(setting.options) do
                    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
                    btn:SetSize(70, 20)
                    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20 + (i - 1) * 75, yOffset)
                    btn:SetText(option)

                    if self.ConfigManager:Get(setting.key) == option then
                        btn:SetButtonState("PUSHED", true)
                    end

                    btn:SetScript("OnClick", function()
                        AM.ConfigManager:Set(setting.key, option)
                        -- Update button states
                        for j = 1, #setting.options do
                            -- Re-check all buttons (simplified)
                        end
                    end)
                end

                yOffset = yOffset - 28
            end

            if yOffset < -180 then
                yOffset = -35  -- Reset for next column
                break
            end
        end
    end

    yOffset = yOffset - 20

    -- Action Buttons
    local buttonsY = yOffset

    -- Reset Button
    local resetBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    resetBtn:SetSize(90, 22)
    resetBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, buttonsY)
    resetBtn:SetText("Reset")
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("AM_RESET_STATS")
    end)

    -- Save Profile Button
    local saveBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    saveBtn:SetSize(90, 22)
    saveBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 105, buttonsY)
    saveBtn:SetText("Save Profile")
    saveBtn:SetScript("OnClick", function()
        -- Show input dialog
        print("|cff00ff00[Arenamaster]|r Profile gespeichert")
    end)

    -- Load Profile Button
    local loadBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    loadBtn:SetSize(90, 22)
    loadBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 200, buttonsY)
    loadBtn:SetText("Load Profile")
    loadBtn:SetScript("OnClick", function()
        print("|cff00ff00[Arenamaster]|r Verfügbare Profile: none")
    end)
end

-- ===========================
-- TAB WECHSEL
-- ===========================

function AM:SelectTab(tabId)
    local content = self.contentFrame
    
    for id, tab in pairs(content.tabs) do
        if id == tabId then
            tab:Show()
        else
            tab:Hide()
        end
    end
    
    for i, btn in ipairs(content.tabButtons) do
        if btn.tabId == tabId then
            btn:SetButtonState("PUSHED", true)
        else
            btn:SetButtonState("NORMAL", false)
        end
    end
end

-- ===========================
-- UI TOGGLE
-- ===========================

function AM:ToggleUI()
    if frame then
        if frame:IsVisible() then
            frame:Hide()
            ArenamasterDB.visible = false
        else
            frame:Show()
            ArenamasterDB.visible = true
        end
    end
end

-- ===========================
-- EVENT HANDLING
-- ===========================

function AM:RegisterEvents()
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("ARENA_PREP_OPPONENT_UPDATE")
    eventFrame:RegisterEvent("ARENA_MATCH_BEGIN")
    eventFrame:RegisterEvent("ARENA_MATCH_END")
    eventFrame:RegisterEvent("PLAYER_LOGIN")
    eventFrame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
    eventFrame:RegisterEvent("PLAYER_PVP_DEATHS_CHANGED")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

    eventFrame:SetScript("OnEvent", function(self, event, ...)
        AM:OnEvent(event, ...)
    end)

    self.eventFrame = eventFrame
end

function AM:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "Arenamaster" then
            self:Initialize()
        end
    elseif event == "ARENA_PREP_OPPONENT_UPDATE" then
        self:UpdateOpponentInfo()
    elseif event == "ARENA_MATCH_BEGIN" then
        self:OnMatchBegin()
    elseif event == "ARENA_MATCH_END" then
        self:OnMatchEnd(...)
    elseif event == "PLAYER_LOGIN" then
        self:UpdatePlayerRating()
    end
end

function AM:OnMatchBegin()
    matchStartTime = GetTime()
    currentMatch = {
        startTime = matchStartTime,
        opponents = {},
        myTeam = {},
        duration = 0,
        waitingForSpecs = true
    }

    -- Gegner-Namen sammeln (Specs werden später via Event geladen)
    for i = 1, 5 do
        local name = GetUnitName("arena" .. i)
        if name then
            table.insert(currentMatch.opponents, name)
        end
    end

    if ArenamasterDB.notifyMatches then
        print("|cff00ff00[Arenamaster]|r Arena-Match beginnt! Gegner werden geladen...")
    end

    self:UpdateUI()
end

function AM:OnMatchEnd(result)
    if not currentMatch then return end

    local duration = GetTime() - matchStartTime
    currentMatch.duration = duration

    -- Match-Ergebnis bestimmen
    local matchWon = (result == 1)
    if matchWon then
        print("|cff00ff00[Arenamaster]|r MATCH GEWONNEN! Dauer: " .. math.floor(duration) .. "s")
        self:RecordMatch("WIN", currentMatch.opponents, duration)
    else
        print("|cffff0000[Arenamaster]|r Match verloren. Dauer: " .. math.floor(duration) .. "s")
        self:RecordMatch("LOSS", currentMatch.opponents, duration)
    end

    self:UpdateUI()
    currentMatch = nil
end

function AM:UpdateOpponentInfo()
    if not currentMatch then return end

    -- Opponent specs werden via ARENA_PREP_OPPONENT_SPECIALIZATIONS event geladen
    -- Diese Funktion aktualisiert die UI wenn neue Gegner-Infos verfügbar sind
    currentMatch.waitingForSpecs = false

    if ArenamasterDB.notifyMatches and #currentMatch.opponents > 0 then
        print("|cff00ff00[Arenamaster]|r Gegner: " .. table.concat(currentMatch.opponents, ", "))
    end

    self:UpdateUI()
end

function AM:StartOpponentTracking()
    if not ArenamasterDB.trackOpponents then return end
    print("|cff00ff00[Arenamaster]|r Gegner-Tracking aktiviert")
end

function AM:UpdatePlayerRating()
    -- Persönliches Rating auslesen
    local _, rating = GetPersonalRatedInfo(1)
    if rating then
        ArenamasterDB.rating = rating
        if rating >= 2400 then
            ArenamasterDB.tier = "Gladiator"
        elseif rating >= 2100 then
            ArenamasterDB.tier = "Duelist"
        elseif rating >= 1800 then
            ArenamasterDB.tier = "Rival"
        elseif rating >= 1600 then
            ArenamasterDB.tier = "Challenger"
        else
            ArenamasterDB.tier = "Unranked"
        end
    end
end

function AM:UpdateUI()
    if not self.mainFrame or not self.mainFrame:IsVisible() then return end

    if self.contentFrame.matchStatus then
        local matchStatus = self.contentFrame.matchStatus
        if currentMatch then
            matchStatus:SetText("|cff00ff00IN MATCH|r - Gegner: " .. table.concat(currentMatch.opponents or {}, ", "))
        else
            matchStatus:SetText("Status: |cff808080Wartend|r")
        end
    end

    if self.contentFrame.streakText then
        local stats = ArenamasterDB.stats
        local streakColor = stats.streak > 0 and "|cff00ff00" or "|cffff0000"
        self.contentFrame.streakText:SetText("Aktueller Streak: " .. streakColor .. stats.streak .. "|r")
    end

    if self.contentFrame.performanceBar then
        self.contentFrame.performanceBar:SetValue(self:GetWinrate())
        self.contentFrame.performanceBar:GetChildren():SetText("Winrate: " .. self:GetWinrate() .. "%")
    end
end

-- ===========================
-- SLASH COMMANDS
-- ===========================

SLASH_ARENAMASTER1 = "/arenamaster"
SLASH_ARENAMASTER2 = "/am"

SlashCmdList["ARENAMASTER"] = function(msg)
    msg = msg:lower()
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word)
    end

    if msg == "" or args[1] == "toggle" then
        Arenamaster:ToggleUI()
    elseif args[1] == "settings" or args[1] == "config" then
        Arenamaster:ToggleUI()
        -- Switch to settings tab
        if Arenamaster.contentFrame and Arenamaster.contentFrame.tabButtons then
            Arenamaster:SelectTab("settings")
        end
    elseif args[1] == "stats" then
        local stats = ArenamasterDB.stats
        print("|cff00ffff=== Arenamaster Statistiken ===|r")
        print("Gesamt Matches: " .. stats.totalMatches)
        print("Siege: |cff00ff00" .. stats.totalWins .. "|r | Niederlagen: |cffff0000" .. stats.totalLosses .. "|r")
        print("Winrate: " .. Arenamaster:GetWinrate() .. "%")
        print("Aktueller Streak: " .. stats.streak .. " (Best: " .. stats.bestStreak .. ")")
        print("Rating: " .. (ArenamasterDB.rating or 0) .. " - " .. (ArenamasterDB.tier or "Unranked"))
    elseif args[1] == "reset" then
        StaticPopup_Show("AM_RESET_STATS")
    elseif args[1] == "frames" then
        if args[2] == "toggle" then
            Arenamaster.EnemyFrames:ToggleFrames()
            print("|cff00ff00[Arenamaster]|r Enemy Frames: " .. (Arenamaster.ConfigManager:Get("enabled") and "✓" or "✗"))
        else
            print("|cff00ffff=== Enemy Frames ===|r")
            print("/am frames toggle - Einschalten/Ausschalten")
        end
    elseif args[1] == "config" then
        if args[2] then
            local key = args[2]
            local value = args[3]
            if value then
                Arenamaster.ConfigManager:Set(key, value)
                print("|cff00ff00[Arenamaster]|r " .. key .. " = " .. value)
            else
                print("|cffff0000[Arenamaster]|r Wert erforderlich")
            end
        else
            print("|cff00ffff=== Config ===|r")
            print("/am config <key> <value> - Einstellung ändern")
        end
    elseif args[1] == "threat" then
        if Arenamaster.ThreatDetector then
            Arenamaster.ThreatDetector:PrintThreatAnalysis()
        end
    elseif args[1] == "cooldowns" then
        if Arenamaster.CooldownPredictor then
            Arenamaster.CooldownPredictor:PrintCooldownAnalysis()
        end
    elseif args[1] == "match" then
        if Arenamaster.CombatAnalytics then
            Arenamaster.CombatAnalytics:PrintMatchSummary()
        end
    elseif args[1] == "predict" then
        if Arenamaster.MatchPredictor then
            Arenamaster.MatchPredictor:PrintMatchAnalysis()
        end
    elseif args[1] == "profiles" then
        if Arenamaster.OpponentProfiler then
            Arenamaster.OpponentProfiler:PrintAllProfiles()
        end
    elseif args[1] == "profile" and args[2] then
        if Arenamaster.OpponentProfiler then
            Arenamaster.OpponentProfiler:PrintProfile(args[2])
        end
    elseif args[1] == "goals" then
        if Arenamaster.GoalTracker then
            Arenamaster.GoalTracker:PrintGoals()
        end
    elseif args[1] == "next" then
        if Arenamaster.GoalTracker then
            Arenamaster.GoalTracker:PrintNextMilestone()
        end
    elseif args[1] == "config" or args[1] == "settings" then
        Arenamaster.ConfigUI:ToggleWindow()
    elseif args[1] == "help" or args[1] == "?" then
        print("|cff00ffff╔════════════════════════════════════════╗|r")
        print("|cff00ffff║  Arenamaster v" .. ADDON_VERSION .. "               ║|r")
        print("|cff00ffff╠════════════════════════════════════════╣|r")
        print("|cff00ff00  HAUPT-BEFEHLE|r")
        print("    /am - Öffne Main Dashboard")
        print("    /am config - Öffne Konfiguration")
        print("")
        print("|cff00ff00  COMBAT INTELLIGENCE|r")
        print("    /am threat - Threat-Analyse")
        print("    /am cooldowns - Cooldown-Status")
        print("    /am match - Match-Zusammenfassung")
        print("    /am predict - Win-Wahrscheinlichkeit")
        print("")
        print("|cff00ff00  GEGNER & ZIELE|r")
        print("    /am profiles - Top Gegner")
        print("    /am profile <name> - Gegner-Profil")
        print("    /am goals - Alle Ziele")
        print("    /am next - Nächster Meilenstein")
        print("")
        print("|cff00ff00  STATISTIKEN|r")
        print("    /am stats - Zeige Statistiken")
        print("|cff00ffff╚════════════════════════════════════════╝|r")
    else
        print("|cffff0000[Arenamaster]|r Unbekannter Befehl: " .. msg)
        print("Nutze |cff00ffff/am help|r für Hilfe")
    end
end

-- Dialogs registrieren
StaticPopupDialogs["AM_RESET_STATS"] = {
    text = "Möchtest du wirklich alle Statistiken zurücksetzen?",
    button1 = "Ja",
    button2 = "Nein",
    OnAccept = function()
        ArenamasterDB.stats = {
            totalMatches = 0,
            totalWins = 0,
            totalLosses = 0,
            streak = 0,
            bestStreak = 0,
            opponents = {},
            seasonStats = {}
        }
        print("|cff00ff00[Arenamaster]|r Statistiken zurückgesetzt!")
        Arenamaster:UpdateUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}
