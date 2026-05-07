-- Arenamaster: Arena Map Module
-- Taktische Arena-Anzeige mit Gegner-Positionen

local AM = Arenamaster
local ArenaMap = {}

local arenaMapFrame = nil
local mapConfig = {
    enabled = true,
    showMap = true,
    mapSize = 200,
    mapX = 1600,
    mapY = 200,
    showOpponents = true,
    showAllies = true,
    showHealthBars = true,
    opacity = 0.85,
}

-- Arena Bounds (vereinfacht - würden in echter Impl per Arena variieren)
local ARENA_BOUNDS = {
    ["2v2"] = {width = 40, height = 40},
    ["3v3"] = {width = 60, height = 60},
    ["5v5"] = {width = 100, height = 100},
}

-- ===========================
-- INITIALIZATION
-- ===========================

function ArenaMap:Initialize()
    self:LoadConfig()
    self:CreateMapFrame()
end

function ArenaMap:LoadConfig()
    if ArenamasterDB.mapConfig then
        for key, value in pairs(ArenamasterDB.mapConfig) do
            mapConfig[key] = value
        end
    end
end

function ArenaMap:SaveConfig()
    ArenamasterDB.mapConfig = {}
    for key, value in pairs(mapConfig) do
        ArenamasterDB.mapConfig[key] = value
    end
end

-- ===========================
-- CREATE MAP FRAME
-- ===========================

function ArenaMap:CreateMapFrame()
    arenaMapFrame = CreateFrame("Frame", "ArenamasterArenaMap", UIParent)
    arenaMapFrame:SetSize(mapConfig.mapSize, mapConfig.mapSize)
    arenaMapFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -mapConfig.mapX, mapConfig.mapY)
    arenaMapFrame:EnableMouse(true)
    arenaMapFrame:SetMovable(true)
    arenaMapFrame:RegisterForDrag("LeftButton")

    -- Allow dragging
    arenaMapFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    arenaMapFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        mapConfig.mapX = self:GetLeft()
        mapConfig.mapY = self:GetTop()
        AM.ArenaMap:SaveConfig()
    end)

    -- Background
    arenaMapFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 2,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    })
    arenaMapFrame:SetBackdropColor(0.1, 0.1, 0.15, mapConfig.opacity)
    arenaMapFrame:SetBackdropBorderColor(0.3, 0.3, 0.5, 1)

    -- Title
    local title = arenaMapFrame:CreateFontString(nil, "OVERLAY", "GameFontSmall")
    title:SetPoint("TOP", arenaMapFrame, "TOP", 0, -3)
    title:SetText("🗺️ Arena")
    title:SetTextColor(0, 1, 1)

    -- Create player indicators
    arenaMapFrame.playerDots = {}
    for i = 1, 10 do  -- 5 allies + 5 enemies
        local dot = CreateFrame("Frame", nil, arenaMapFrame)
        dot:SetSize(8, 8)
        dot:SetBackdrop({
            bgFile = "Interface/Buttons/WHITE8X8",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 8,
            edgeSize = 1
        })

        local text = dot:CreateFontString(nil, "OVERLAY", "GameFontSmall")
        text:SetPoint("CENTER", dot, "CENTER", 0, 0)
        text:SetText("•")
        text:SetTextColor(1, 1, 1)
        dot.text = text

        arenaMapFrame.playerDots[i] = dot
    end

    arenaMapFrame:Hide()
end

-- ===========================
-- UPDATE MAP
-- ===========================

function ArenaMap:UpdateMap()
    if not arenaMapFrame or not mapConfig.showMap then return end

    local bracket = C_PvP.GetActiveMatchBracket()
    if not bracket then return end

    local maxPlayers = bracket == 1 and 4 or bracket == 2 and 6 or bracket == 3 and 10 or 0
    if maxPlayers == 0 then return end

    local dotIndex = 1

    -- Draw player team
    if mapConfig.showAllies then
        for i = 0, 4 do
            local unit = i == 0 and "player" or "party" .. i
            if UnitExists(unit) then
                local x, y = self:GetUnitPosition(unit)
                if x and y then
                    self:DrawDot(dotIndex, x, y, true, UnitName(unit))
                    dotIndex = dotIndex + 1
                end
            end
        end
    end

    -- Draw opponent team
    if mapConfig.showOpponents then
        for i = 1, 5 do
            local unit = "arena" .. i
            if UnitExists(unit) then
                local x, y = self:GetUnitPosition(unit)
                if x and y then
                    local _, class = UnitClass(unit)
                    self:DrawDot(dotIndex, x, y, false, UnitName(unit), class)
                    dotIndex = dotIndex + 1
                end
            end
        end
    end

    -- Hide unused dots
    for i = dotIndex, 10 do
        if arenaMapFrame.playerDots[i] then
            arenaMapFrame.playerDots[i]:Hide()
        end
    end
end

function ArenaMap:DrawDot(index, x, y, isAlly, name, class)
    if not arenaMapFrame.playerDots[index] then return end

    local dot = arenaMapFrame.playerDots[index]

    -- Calculate position on map (simplified - would need actual arena coordinates)
    local mapSize = mapConfig.mapSize - 10
    local dotX = (mapSize / 2) + (x / 100) * (mapSize / 2)
    local dotY = (mapSize / 2) - (y / 100) * (mapSize / 2)

    dot:SetPoint("CENTER", arenaMapFrame, "TOPLEFT", dotX, -dotY)

    -- Color by team/class
    if isAlly then
        dot:SetBackdropColor(0, 1, 0, 0.8)  -- Green for allies
        dot:SetBackdropBorderColor(0, 1, 0, 1)
    else
        local classColor = self:GetClassColor(class)
        dot:SetBackdropColor(classColor.r, classColor.g, classColor.b, 0.8)
        dot:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 1)
    end

    -- Tooltip
    dot:SetScript("OnEnter", function()
        GameTooltip:SetOwner(dot, "ANCHOR_TOPLEFT")
        GameTooltip:SetText(name, 1, 1, 1)
        GameTooltip:Show()
    end)
    dot:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    dot:Show()
end

function ArenaMap:GetUnitPosition(unit)
    -- Simplified position calculation
    -- In real implementation would use UnitPosition or combat log data
    local health = UnitHealth(unit)
    local x = (health % 100)
    local y = (health / 100) % 100

    return x, y
end

function ArenaMap:GetClassColor(class)
    local colors = {
        DRUID = {r = 1.0, g = 0.49, b = 0.04},
        HUNTER = {r = 0.67, g = 0.83, b = 0.45},
        MAGE = {r = 0.41, g = 0.80, b = 0.94},
        PALADIN = {r = 0.96, g = 0.55, b = 0.73},
        PRIEST = {r = 1.0, g = 1.0, b = 1.0},
        ROGUE = {r = 1.0, g = 0.96, b = 0.41},
        SHAMAN = {r = 0.0, g = 0.44, b = 0.87},
        WARLOCK = {r = 0.58, g = 0.51, b = 0.79},
        WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
        MONK = {r = 0.0, g = 1.0, b = 0.59},
        DEMON_HUNTER = {r = 0.64, g = 0.19, b = 0.79},
        DEATH_KNIGHT = {r = 0.77, g = 0.12, b = 0.23},
    }
    return colors[class] or {r = 0.5, g = 0.5, b = 0.5}
end

-- ===========================
-- MATCH LIFECYCLE
-- ===========================

function ArenaMap:OnMatchStart()
    if arenaMapFrame then
        arenaMapFrame:Show()
    end
end

function ArenaMap:OnMatchEnd()
    if arenaMapFrame then
        arenaMapFrame:Hide()
    end
end

-- ===========================
-- CONFIGURATION
-- ===========================

function ArenaMap:UpdateConfig(key, value)
    mapConfig[key] = value
    self:SaveConfig()

    if key == "mapSize" then
        arenaMapFrame:SetSize(value, value)
    elseif key == "opacity" then
        arenaMapFrame:SetBackdropColor(0.1, 0.1, 0.15, value)
    end
end

function ArenaMap:GetConfig()
    return mapConfig
end

function ArenaMap:ToggleMap()
    mapConfig.showMap = not mapConfig.showMap
    self:SaveConfig()
    if mapConfig.showMap then
        arenaMapFrame:Show()
    else
        arenaMapFrame:Hide()
    end
    return mapConfig.showMap
end

-- Export
AM.ArenaMap = ArenaMap

return ArenaMap
