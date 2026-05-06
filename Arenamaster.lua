-- Arenamaster Core
-- Hauptdatei für das Addon

local ADDON_NAME = "Arenamaster"
local ADDON_VERSION = "1.0.0"

-- Namespace erstellen
Arenamaster = {}
local AM = Arenamaster

-- Lokale Variablen
local frame
local isInitialized = false

-- ===========================
-- INITIALISIERUNG
-- ===========================

function AM:Initialize()
    if isInitialized then return end
    
    print("|cff00ff00[Arenamaster]|r v" .. ADDON_VERSION .. " erfolgreich geladen!")
    
    -- Einstellungen laden
    self:LoadSettings()
    
    -- UI erstellen
    self:CreateUI()
    
    -- Events registrieren
    self:RegisterEvents()
    
    isInitialized = true
    print("|cff00ff00[Arenamaster]|r UI erstellt. Nutze |cff00ffffm /am|r zum Öffnen.")
end

-- ===========================
-- SETTINGS-SYSTEM
-- ===========================

function AM:LoadSettings()
    if not ArenamasterDB then
        ArenamasterDB = {
            windowPos = { x = 100, y = 100 },
            visible = false,
            debugMode = false
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
    
    local info = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    info:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -40)
    info:SetText("Arena-Status: Bereit")
    
    local statusBar = CreateFrame("StatusBar", nil, parent)
    statusBar:SetSize(360, 20)
    statusBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -70)
    statusBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    statusBar:SetStatusBarColor(0, 0.8, 1, 0.8)
    statusBar:SetMinMaxValues(0, 100)
    statusBar:SetValue(75)
end

function AM:CreateStatsTab(parent)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    text:SetText("Statistiken")
    
    local stats = {
        "Gewonnene Spiele: 42",
        "Verlorene Spiele: 15",
        "Winrate: 73.7%"
    }
    
    for i, stat in ipairs(stats) do
        local line = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        line:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -40 - (i-1) * 25)
        line:SetText(stat)
    end
end

function AM:CreateSettingsTab(parent)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    text:SetText("Einstellungen")
    
    -- Debug Mode Toggle
    local debugToggle = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    debugToggle:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -40)
    local debugLabel = debugToggle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    debugLabel:SetText("Debug-Modus aktivieren")
    debugLabel:SetPoint("LEFT", debugToggle, "RIGHT", 5, 0)
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
    eventFrame:RegisterEvent("ARENA_MATCH_BEGIN")
    eventFrame:RegisterEvent("ARENA_MATCH_END")
    eventFrame:RegisterEvent("PLAYER_LOGIN")
    
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        AM:OnEvent(event, ...)
    end)
end

function AM:OnEvent(event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "Arenamaster" then
            self:Initialize()
        end
    elseif event == "ARENA_MATCH_BEGIN" then
        print("|cff00ff00[Arenamaster]|r Arena-Match beginnt!")
    elseif event == "ARENA_MATCH_END" then
        print("|cff00ff00[Arenamaster]|r Arena-Match endet!")
    end
end

-- ===========================
-- SLASH COMMANDS
-- ===========================

SLASH_ARENAMASTER1 = "/arenamaster"
SLASH_ARENAMASTER2 = "/am"

SlashCmdList["ARENAMASTER"] = function(msg)
    if msg == "toggle" or msg == "" then
        Arenamaster:ToggleUI()
    elseif msg == "reset" then
        Arenamaster:SaveSettings()
        ReloadUI()
    else
        print("|cff00ff00[Arenamaster]|r Befehle:")
        print("  /am toggle - UI öffnen/schließen")
        print("  /am reset - Einstellungen zurücksetzen")
    end
end
