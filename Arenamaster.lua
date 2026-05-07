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

    -- Stats initialisieren
    self:InitializeStats()

    -- UI erstellen
    self:CreateUI()

    -- Events registrieren
    self:RegisterEvents()

    -- Gegner-Tracker starten
    self:StartOpponentTracking()

    isInitialized = true
    print("|cff00ff00[Arenamaster]|r Arena-Tracking aktiviert. Nutze |cff00ffff/am|r zum Öffnen.")
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
    text:SetText("Dashboard")

    -- Rating und Tier
    local ratingText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ratingText:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -40)
    ratingText:SetText("Rating: " .. (ArenamasterDB.rating or 0) .. " - " .. (ArenamasterDB.tier or "Unranked"))

    -- Current Match Status
    local matchStatus = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    matchStatus:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -65)
    if currentMatch then
        matchStatus:SetText("|cff00ff00IN MATCH|r - Gegner: " .. table.concat(currentMatch.opponents or {}, ", "))
    else
        matchStatus:SetText("Status: |cff808080Wartend|r")
    end
    parent.matchStatus = matchStatus

    -- Streak Info
    local streakText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    streakText:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -90)
    local stats = ArenamasterDB.stats
    local streakColor = stats.streak > 0 and "|cff00ff00" or "|cffff0000"
    streakText:SetText("Aktueller Streak: " .. streakColor .. stats.streak .. "|r")
    parent.streakText = streakText

    -- Performance Bar
    local performanceBar = CreateFrame("StatusBar", nil, parent)
    performanceBar:SetSize(360, 15)
    performanceBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -120)
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
    text:SetText("Einstellungen")

    local yOffset = -40

    -- Gegner-Tracking Toggle
    local trackToggle = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    trackToggle:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    trackToggle:SetChecked(ArenamasterDB.trackOpponents)
    trackToggle:SetScript("OnClick", function(self)
        ArenamasterDB.trackOpponents = self:GetChecked()
        print("|cff00ff00[Arenamaster]|r Gegner-Tracking: " .. (ArenamasterDB.trackOpponents and "AN" or "AUS"))
    end)
    local trackLabel = trackToggle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    trackLabel:SetText("Gegner-Tracking")
    trackLabel:SetPoint("LEFT", trackToggle, "RIGHT", 5, 0)

    yOffset = yOffset - 25

    -- Cooldown-Tracking Toggle
    local cooldownToggle = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cooldownToggle:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    cooldownToggle:SetChecked(ArenamasterDB.trackCooldowns)
    cooldownToggle:SetScript("OnClick", function(self)
        ArenamasterDB.trackCooldowns = self:GetChecked()
        print("|cff00ff00[Arenamaster]|r Cooldown-Tracking: " .. (ArenamasterDB.trackCooldowns and "AN" or "AUS"))
    end)
    local cooldownLabel = cooldownToggle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cooldownLabel:SetText("Cooldown-Tracking")
    cooldownLabel:SetPoint("LEFT", cooldownToggle, "RIGHT", 5, 0)

    yOffset = yOffset - 25

    -- Match Notifications Toggle
    local notifyToggle = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    notifyToggle:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    notifyToggle:SetChecked(ArenamasterDB.notifyMatches)
    notifyToggle:SetScript("OnClick", function(self)
        ArenamasterDB.notifyMatches = self:GetChecked()
        print("|cff00ff00[Arenamaster]|r Match-Benachrichtigungen: " .. (ArenamasterDB.notifyMatches and "AN" or "AUS"))
    end)
    local notifyLabel = notifyToggle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    notifyLabel:SetText("Match-Benachrichtigungen")
    notifyLabel:SetPoint("LEFT", notifyToggle, "RIGHT", 5, 0)

    yOffset = yOffset - 35

    -- Reset Stats Button
    local resetBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    resetBtn:SetSize(150, 25)
    resetBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    resetBtn:SetText("Statistiken zurücksetzen")
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("AM_RESET_STATS")
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
        duration = 0
    }

    -- Gegner auslesen
    for i = 1, 5 do
        local name = GetArenaOpponentSpec(i)
        if name then
            table.insert(currentMatch.opponents, name)
        end
    end

    if ArenamasterDB.notifyMatches then
        print("|cff00ff00[Arenamaster]|r Arena-Match beginnt! Gegner: " .. table.concat(currentMatch.opponents, ", "))
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

    for i = 1, 5 do
        local specId, specName = GetArenaOpponentSpec(i)
        if specName then
            currentMatch.opponents[i] = specName
        end
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
    if msg == "" or msg == "toggle" then
        Arenamaster:ToggleUI()
    elseif msg == "stats" then
        local stats = ArenamasterDB.stats
        print("|cff00ffff=== Arenamaster Statistiken ===|r")
        print("Gesamt Matches: " .. stats.totalMatches)
        print("Siege: |cff00ff00" .. stats.totalWins .. "|r | Niederlagen: |cffff0000" .. stats.totalLosses .. "|r")
        print("Winrate: " .. Arenamaster:GetWinrate() .. "%")
        print("Aktueller Streak: " .. stats.streak .. " (Best: " .. stats.bestStreak .. ")")
        print("Rating: " .. (ArenamasterDB.rating or 0) .. " - " .. (ArenamasterDB.tier or "Unranked"))
    elseif msg == "reset" then
        StaticPopup_Show("AM_RESET_STATS")
    elseif msg == "help" or msg == "?" then
        print("|cff00ffff=== Arenamaster Befehle ===|r")
        print("/am - UI öffnen/schließen")
        print("/am stats - Statistiken anzeigen")
        print("/am reset - Statistiken zurücksetzen")
        print("/am help - Diese Hilfe anzeigen")
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
