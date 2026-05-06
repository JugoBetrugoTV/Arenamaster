-- Arenamaster
-- PvP Addon für World of Warcraft Patch 12.0.5

local ADDON_NAME = "Arenamaster"
local ADDON_VERSION = "1.0.0"

-- Frame für das Addon erstellen
local ArenamasterFrame = CreateFrame("Frame")

-- Addon beim Laden initialisieren
ArenamasterFrame:RegisterEvent("ADDON_LOADED")
ArenamasterFrame:SetScript("OnEvent", function(self, event, addOnName)
    if addOnName == ADDON_NAME then
        Arenamaster_OnLoad()
    end
end)

-- Initialisierungsfunktion
function Arenamaster_OnLoad()
    print("|cff00ff00" .. ADDON_NAME .. "|r v" .. ADDON_VERSION .. " geladen!")
    
    -- Datenbank initialisieren
    if not ArenamasterDB then
        ArenamasterDB = {}
    end
    
    -- Weitere Initialisierung hier
end

-- Debugging: Addon-Befehl hinzufügen
SLASH_ARENAMASTER1 = "/arenamaster"
SLASH_ARENAMASTER2 = "/am"
SlashCmdList["ARENAMASTER"] = function(msg)
    print("Arenamaster: " .. msg)
end