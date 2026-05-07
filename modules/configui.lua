-- Arenamaster: Beautiful Config UI Module
-- Wunderschönes grafisches Konfigurationsfenster

local AM = Arenamaster
local ConfigUI = {}

-- Color Palette
local COLORS = {
    primary = {r = 0, g = 0.6, b = 1},        -- Cyan
    secondary = {r = 0.2, g = 0.8, b = 1},    -- Light Cyan
    accent = {r = 1, g = 0.5, b = 0},         -- Orange
    success = {r = 0, g = 1, b = 0},          -- Green
    danger = {r = 1, g = 0, b = 0},           -- Red
    text = {r = 1, g = 1, b = 1},             -- White
    textMuted = {r = 0.7, g = 0.7, b = 0.7},  -- Gray
    background = {r = 0.08, g = 0.08, b = 0.1}, -- Dark
    panel = {r = 0.12, g = 0.12, b = 0.15},   -- Darker
}

local configFrame = nil
local currentCategory = "FRAMES"
local currentPreset = nil

-- ===========================
-- INITIALIZATION
-- ===========================

function ConfigUI:Initialize()
    if not configFrame then
        self:CreateConfigWindow()
    end
end

-- ===========================
-- MAIN CONFIG WINDOW
-- ===========================

function ConfigUI:CreateConfigWindow()
    -- Main Frame
    configFrame = CreateFrame("Frame", "ArenamasterConfigFrame", UIParent, "BackdropTemplate")
    configFrame:SetSize(1000, 700)
    configFrame:SetPoint("CENTER", UIParent, "CENTER")
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    configFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    -- Modern Backdrop
    configFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    })
    configFrame:SetBackdropColor(COLORS.background.r, COLORS.background.g, COLORS.background.b, 0.95)
    configFrame:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.8)

    -- Header
    self:CreateHeader(configFrame)

    -- Left Sidebar (Presets + Categories)
    local sidebar = CreateFrame("Frame", nil, configFrame)
    sidebar:SetSize(180, 650)
    sidebar:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 5, -35)
    sidebar:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    sidebar:SetBackdropColor(COLORS.panel.r, COLORS.panel.g, COLORS.panel.b, 0.7)
    sidebar:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.3)

    self:CreatePresetsSection(sidebar)
    self:CreateCategoriesSection(sidebar)

    -- Main Content Area
    local content = CreateFrame("Frame", nil, configFrame)
    content:SetSize(800, 650)
    content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 5, 0)
    configFrame.contentFrame = content

    self:RefreshContent(content)

    -- Bottom Action Bar
    self:CreateActionBar(configFrame)

    -- Store reference
    AM.ConfigUI = self
    self.frame = configFrame
end

-- ===========================
-- HEADER
-- ===========================

function ConfigUI:CreateHeader(parent)
    local header = CreateFrame("Frame", nil, parent)
    header:SetSize(990, 30)
    header:SetPoint("TOP", parent, "TOP", 0, -2)
    header:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    header:SetBackdropColor(COLORS.primary.r * 0.2, COLORS.primary.g * 0.2, COLORS.primary.b * 0.2, 0.5)
    header:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.5)

    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", header, "LEFT", 10, 0)
    title:SetText("|cff00ffff⚙️ ARENAMASTER CONFIGURATION|r")
    title:SetTextColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b)

    -- Close Button
    local closeBtn = CreateFrame("Button", nil, parent)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, -8)
    closeBtn:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
    closeBtn:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight")
    closeBtn:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
    closeBtn:SetScript("OnClick", function()
        configFrame:Hide()
    end)
end

-- ===========================
-- PRESETS SECTION
-- ===========================

function ConfigUI:CreatePresetsSection(parent)
    local presetsTitle = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    presetsTitle:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    presetsTitle:SetText("|cff4dabf7PRESETS|r")

    local yOffset = -30

    local presets = AM.ConfigManager:GetPresets()
    for _, preset in ipairs(presets) do
        local btn = self:CreatePresetButton(parent, preset, yOffset)
        yOffset = yOffset - 50
    end

    presetsTitle:SetHeight(1)
end

function ConfigUI:CreatePresetButton(parent, preset, yOffset)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(160, 45)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)

    -- Backdrop
    btn:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    btn:SetBackdropColor(0.15, 0.15, 0.18, 0.6)
    btn:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.4)

    -- Text
    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("CENTER", btn, "CENTER")
    text:SetText(preset.name)
    text:SetTextColor(COLORS.text.r, COLORS.text.g, COLORS.text.b)

    -- Hover Effect
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(COLORS.primary.r * 0.3, COLORS.primary.g * 0.3, COLORS.primary.b * 0.3, 0.8)
        self:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.8)
    end)

    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.18, 0.6)
        self:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.4)
    end)

    -- Click Handler
    btn:SetScript("OnClick", function()
        local success = AM.ConfigManager:ApplyPreset(preset.key)
        if success then
            currentPreset = preset.key
            self:RefreshContent(configFrame.contentFrame)
            print("|cff00ff00✓|r Preset angewendet: " .. preset.name)
        end
    end)

    return btn
end

-- ===========================
-- CATEGORIES SECTION
-- ===========================

function ConfigUI:CreateCategoriesSection(parent)
    local catTitle = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    catTitle:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -265)
    catTitle:SetText("|cff4dabf7KATEGORIEN|r")

    local yOffset = -285

    local categories = AM.ConfigManager:GetCategories()
    for _, category in ipairs(categories) do
        local btn = self:CreateCategoryButton(parent, category, yOffset)
        yOffset = yOffset - 40
    end
end

function ConfigUI:CreateCategoryButton(parent, category, yOffset)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(160, 35)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)

    -- Backdrop
    btn:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })

    local isActive = (category == currentCategory)
    if isActive then
        btn:SetBackdropColor(COLORS.primary.r * 0.3, COLORS.primary.g * 0.3, COLORS.primary.b * 0.3, 0.8)
        btn:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.8)
    else
        btn:SetBackdropColor(0.15, 0.15, 0.18, 0.6)
        btn:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.3)
    end

    -- Icon mapping for categories
    local categoryIcons = {
        FRAMES = "🎯",
        AURAS = "⚡",
        NOTIFICATIONS = "📢",
        UI = "🎨",
        STATS = "📊",
    }

    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("CENTER", btn, "CENTER")
    text:SetText((categoryIcons[category] or "•") .. " " .. category)
    text:SetTextColor(COLORS.text.r, COLORS.text.g, COLORS.text.b)

    -- Hover Effect
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(COLORS.primary.r * 0.3, COLORS.primary.g * 0.3, COLORS.primary.b * 0.3, 0.8)
        self:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.8)
    end)

    btn:SetScript("OnLeave", function(self)
        if category == currentCategory then
            self:SetBackdropColor(COLORS.primary.r * 0.3, COLORS.primary.g * 0.3, COLORS.primary.b * 0.3, 0.8)
            self:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.8)
        else
            self:SetBackdropColor(0.15, 0.15, 0.18, 0.6)
            self:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.3)
        end
    end)

    -- Click Handler
    btn:SetScript("OnClick", function()
        currentCategory = category
        self:RefreshContent(configFrame.contentFrame)
    end)

    return btn
end

-- ===========================
-- CONTENT AREA (SETTINGS)
-- ===========================

function ConfigUI:RefreshContent(contentFrame)
    -- Clear old content by creating new frame
    for child in contentFrame:EnumerateChildren() do
        child:Destroy()
    end

    contentFrame:Show()

    -- Category Title
    local title = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 15, -15)
    title:SetText(currentCategory)
    title:SetTextColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b)

    -- Settings
    local settings = AM.ConfigManager:GetSettings(currentCategory)
    local yOffset = -45

    local lastGroup = nil
    for _, setting in ipairs(settings) do
        -- Group Header
        if setting.group and setting.group ~= lastGroup then
            lastGroup = setting.group
            local groupTitle = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            groupTitle:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 15, yOffset)
            groupTitle:SetText("─ " .. setting.group .. " ─")
            groupTitle:SetTextColor(COLORS.secondary.r, COLORS.secondary.g, COLORS.secondary.b)
            yOffset = yOffset - 25
        end

        -- Setting Label & Description
        local label = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 25, yOffset)
        label:SetText((setting.icon or "•") .. " " .. setting.name)
        label:SetTextColor(COLORS.text.r, COLORS.text.g, COLORS.text.b)

        local desc = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        desc:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 45, yOffset - 16)
        desc:SetText(setting.description)
        desc:SetTextColor(COLORS.textMuted.r, COLORS.textMuted.g, COLORS.textMuted.b)
        desc:SetWidth(700)

        yOffset = yOffset - 40

        -- Setting Control
        if setting.type == "checkbox" then
            self:CreateCheckboxControl(contentFrame, setting, yOffset)
            yOffset = yOffset - 25
        elseif setting.type == "slider" then
            self:CreateSliderControl(contentFrame, setting, yOffset)
            yOffset = yOffset - 45
        elseif setting.type == "select" then
            self:CreateSelectControl(contentFrame, setting, yOffset)
            yOffset = yOffset - 40
        end

        yOffset = yOffset - 10
    end
end

-- ===========================
-- CONTROL CREATORS
-- ===========================

function ConfigUI:CreateCheckboxControl(parent, setting, yOffset)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", parent, "TOPLEFT", 30, yOffset)
    checkbox:SetChecked(AM.ConfigManager:Get(setting.key))
    checkbox:SetScript("OnClick", function(self)
        AM.ConfigManager:Set(setting.key, self:GetChecked())
    end)
end

function ConfigUI:CreateSliderControl(parent, setting, yOffset)
    local currentValue = AM.ConfigManager:Get(setting.key)

    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", 30, yOffset)
    slider:SetWidth(300)
    slider:SetMinMaxValues(setting.min, setting.max)
    slider:SetValue(currentValue)
    slider:SetValueStep(setting.step or 1)

    local valueText = parent:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    valueText:SetPoint("TOPLEFT", slider, "TOPRIGHT", 10, 5)
    valueText:SetText(string.format("%.2f", currentValue))
    valueText:SetTextColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b)

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 100) / 100
        AM.ConfigManager:Set(setting.key, value)
        valueText:SetText(string.format("%.2f", value))
    end)
end

function ConfigUI:CreateSelectControl(parent, setting, yOffset)
    local currentValue = AM.ConfigManager:Get(setting.key)
    local xOffset = 30

    for i, option in ipairs(setting.options) do
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(80, 22)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
        btn:SetText(option)

        -- Styling
        btn:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 1,
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        })

        local isSelected = (currentValue == option)
        if isSelected then
            btn:SetBackdropColor(COLORS.accent.r * 0.4, COLORS.accent.g * 0.4, COLORS.accent.b * 0.4, 0.7)
            btn:SetBackdropBorderColor(COLORS.accent.r, COLORS.accent.g, COLORS.accent.b, 0.8)
        else
            btn:SetBackdropColor(0.1, 0.1, 0.12, 0.5)
            btn:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.3)
        end

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        text:SetPoint("CENTER", btn, "CENTER")
        text:SetText(option)

        btn:SetScript("OnClick", function()
            AM.ConfigManager:Set(setting.key, option)
            self:RefreshContent(parent)
        end)

        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(COLORS.primary.r * 0.3, COLORS.primary.g * 0.3, COLORS.primary.b * 0.3, 0.8)
        end)

        btn:SetScript("OnLeave", function(self)
            if option == currentValue then
                self:SetBackdropColor(COLORS.accent.r * 0.4, COLORS.accent.g * 0.4, COLORS.accent.b * 0.4, 0.7)
            else
                self:SetBackdropColor(0.1, 0.1, 0.12, 0.5)
            end
        end)

        xOffset = xOffset + 90
    end
end

-- ===========================
-- ACTION BAR
-- ===========================

function ConfigUI:CreateActionBar(parent)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetSize(990, 40)
    bar:SetPoint("BOTTOM", parent, "BOTTOM", 0, 2)
    bar:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    bar:SetBackdropColor(COLORS.panel.r, COLORS.panel.g, COLORS.panel.b, 0.5)
    bar:SetBackdropBorderColor(COLORS.primary.r, COLORS.primary.g, COLORS.primary.b, 0.3)

    -- Reset Button
    local resetBtn = self:CreateActionButton(bar, "🔄 Reset", 10)
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("AM_RESET_CONFIG")
    end)

    -- Export Button
    local exportBtn = self:CreateActionButton(bar, "📤 Export", 110)
    exportBtn:SetScript("OnClick", function()
        local export = AM.ConfigManager:ExportConfig()
        print("|cff00ffff━━━ EXPORT STRING ━━━|r")
        print(export)
        print("|cffcccccc(Use: /am import <string>)|r")
    end)

    -- Save Profile Button
    local saveBtn = self:CreateActionButton(bar, "💾 Save", 210)
    saveBtn:SetScript("OnClick", function()
        -- Show input dialog
        local dialog = StaticPopup_Show("AM_SAVE_PROFILE")
        if dialog then
            dialog.editBox:SetFocus()
        end
    end)

    -- Status Text
    local status = bar:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    status:SetPoint("RIGHT", bar, "RIGHT", -15, 0)
    status:SetText("|cff00ff00✓ Ready|r")
end

function ConfigUI:CreateActionButton(parent, text, xOffset)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(90, 28)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, -6)
    btn:SetText(text)
    return btn
end

-- ===========================
-- TOGGLE FUNCTION
-- ===========================

function ConfigUI:ToggleWindow()
    if not configFrame then
        self:CreateConfigWindow()
    end

    if configFrame:IsVisible() then
        configFrame:Hide()
    else
        configFrame:Show()
    end
end

function ConfigUI:ShowWindow()
    if not configFrame then
        self:CreateConfigWindow()
    end
    configFrame:Show()
end

function ConfigUI:HideWindow()
    if configFrame then
        configFrame:Hide()
    end
end

-- Setup Dialogs
StaticPopupDialogs["AM_RESET_CONFIG"] = {
    text = "Alle Einstellungen zurücksetzen?",
    button1 = "Ja",
    button2 = "Nein",
    OnAccept = function()
        AM.ConfigManager:ResetToDefaults()
        print("|cff00ff00✓ Einstellungen zurückgesetzt|r")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["AM_SAVE_PROFILE"] = {
    text = "Profilename:",
    button1 = "Speichern",
    button2 = "Abbrechen",
    hasEditBox = true,
    editBoxWidth = 200,
    OnAccept = function(self)
        local name = self.editBox:GetText()
        if name ~= "" then
            AM.ConfigManager:SaveProfile(name)
            print("|cff00ff00✓ Profil gespeichert: " .. name .. "|r")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

-- Export
AM.ConfigUI = ConfigUI

return ConfigUI
