-- Arenamaster: Professional Design System Module
-- Custom icons, colors, fonts, themes, and UI styling

local Arenamaster = LibStub("AceAddon-3.0"):GetAddon("Arenamaster")
local Design = Arenamaster:NewModule("Design", "AceEvent-3.0")

-- ===========================
-- CUSTOM ICON LIBRARY
-- ===========================

local ICONS = {
	-- Classes
	WARRIOR = "⚔️",
	PALADIN = "🛡️",
	HUNTER = "🏹",
	ROGUE = "🗡️",
	PRIEST = "☩",
	SHAMAN = "⚡",
	DRUID = "🌿",
	WARLOCK = "👿",
	MONK = "☯️",
	DEMONHUNTER = "🔥",

	-- Features
	COOLDOWN = "⏱️",
	THREAT = "⚠️",
	PREDICTION = "🔮",
	ANALYTICS = "📊",
	NOTIFICATION = "📢",
	GOAL = "🎯",
	RATING = "⭐",
	PROFILE = "👤",
	SETTINGS = "⚙️",
	THEME = "🎨",

	-- Actions
	PLAY = "▶️",
	PAUSE = "⏸️",
	STOP = "⏹️",
	RESET = "↺",
	SAVE = "💾",
	LOAD = "📂",
	EXPORT = "📤",
	IMPORT = "📥",
	DELETE = "🗑️",
	COPY = "📋",

	-- Status
	ENABLED = "✓",
	DISABLED = "✗",
	WARNING = "⚠️",
	ERROR = "❌",
	SUCCESS = "✅",
	INFO = "ℹ️",

	-- Arena
	FRAME = "🎬",
	HEALTH = "❤️",
	MANA = "💎",
	CAST = "✨",
	TRINKET = "💠",
	BUFF = "⬆️",
	DEBUFF = "⬇️",
	CC = "🔒",
}

-- ===========================
-- COLOR PALETTES
-- ===========================

local COLOR_THEMES = {
	-- Dark Theme (Default)
	Dark = {
		primary = {r = 0, g = 0.67, b = 1, hex = "00aeff"},          -- Bright Blue
		secondary = {r = 0.2, g = 0.8, b = 1, hex = "33ccff"},       -- Light Cyan
		accent = {r = 1, g = 0.5, b = 0, hex = "ff8000"},            -- Orange
		success = {r = 0, g = 1, b = 0, hex = "00ff00"},             -- Green
		warning = {r = 1, g = 1, b = 0, hex = "ffff00"},             -- Yellow
		danger = {r = 1, g = 0, b = 0, hex = "ff0000"},              -- Red
		info = {r = 0.3, g = 0.8, b = 1, hex = "4dabf7"},            -- Sky Blue
		text = {r = 1, g = 1, b = 1, hex = "ffffff"},                -- White
		textMuted = {r = 0.7, g = 0.7, b = 0.7, hex = "b3b3b3"},     -- Light Gray
		textDark = {r = 0.2, g = 0.2, b = 0.2, hex = "333333"},      -- Dark Gray
		bg = {r = 0.08, g = 0.08, b = 0.1, hex = "141416"},          -- Very Dark
		bgPanel = {r = 0.12, g = 0.12, b = 0.15, hex = "1f1f26"},    -- Dark Panel
		border = {r = 0.3, g = 0.3, b = 0.4, hex = "4d4d66"},        -- Border Gray
	},

	-- Light Theme
	Light = {
		primary = {r = 0, g = 0.4, b = 0.8, hex = "0066cc"},
		secondary = {r = 0.2, g = 0.6, b = 1, hex = "3399ff"},
		accent = {r = 1, g = 0.6, b = 0, hex = "ff9900"},
		success = {r = 0, g = 0.7, b = 0, hex = "00b300"},
		warning = {r = 1, g = 0.8, b = 0, hex = "ffcc00"},
		danger = {r = 0.8, g = 0, b = 0, hex = "cc0000"},
		info = {r = 0, g = 0.6, b = 0.9, hex = "0099ff"},
		text = {r = 0.1, g = 0.1, b = 0.1, hex = "1a1a1a"},
		textMuted = {r = 0.5, g = 0.5, b = 0.5, hex = "808080"},
		textDark = {r = 0.9, g = 0.9, b = 0.9, hex = "e6e6e6"},
		bg = {r = 0.95, g = 0.95, b = 0.95, hex = "f2f2f2"},
		bgPanel = {r = 0.9, g = 0.9, b = 0.9, hex = "e6e6e6"},
		border = {r = 0.7, g = 0.7, b = 0.7, hex = "b3b3b3"},
	},

	-- Ocean Theme
	Ocean = {
		primary = {r = 0, g = 0.8, b = 1, hex = "00ccff"},
		secondary = {r = 0.3, g = 0.9, b = 1, hex = "4de6ff"},
		accent = {r = 1, g = 0.4, b = 0.2, hex = "ff6633"},
		success = {r = 0.2, g = 1, b = 0.6, hex = "33ff99"},
		warning = {r = 1, g = 0.9, b = 0.2, hex = "ffe633"},
		danger = {r = 1, g = 0.3, b = 0.3, hex = "ff4d4d"},
		info = {r = 0.4, g = 0.9, b = 1, hex = "66e6ff"},
		text = {r = 1, g = 1, b = 1, hex = "ffffff"},
		textMuted = {r = 0.8, g = 0.8, b = 0.8, hex = "cccccc"},
		bg = {r = 0.05, g = 0.15, b = 0.25, hex = "0d2640"},
		bgPanel = {r = 0.1, g = 0.2, b = 0.3, hex = "194d7f"},
		border = {r = 0.2, g = 0.5, b = 0.7, hex = "3380b3"},
	},

	-- Forest Theme
	Forest = {
		primary = {r = 0.2, g = 0.8, b = 0.3, hex = "33cc4d"},
		secondary = {r = 0.4, g = 0.9, b = 0.5, hex = "66ff80"},
		accent = {r = 1, g = 0.6, b = 0.2, hex = "ff9933"},
		success = {r = 0.2, g = 1, b = 0.2, hex = "33ff33"},
		warning = {r = 1, g = 0.9, b = 0.2, hex = "ffe633"},
		danger = {r = 1, g = 0.2, b = 0.2, hex = "ff3333"},
		info = {r = 0.5, g = 0.9, b = 0.6, hex = "80e6b3"},
		text = {r = 1, g = 1, b = 1, hex = "ffffff"},
		textMuted = {r = 0.8, g = 0.8, b = 0.8, hex = "cccccc"},
		bg = {r = 0.05, g = 0.1, b = 0.05, hex = "0d1a0d"},
		bgPanel = {r = 0.1, g = 0.2, b = 0.1, hex = "1f331f"},
		border = {r = 0.3, g = 0.6, b = 0.3, hex = "4d9933"},
	},

	-- Fire Theme
	Fire = {
		primary = {r = 1, g = 0.5, b = 0, hex = "ff8000"},
		secondary = {r = 1, g = 0.6, b = 0.2, hex = "ff9933"},
		accent = {r = 0.2, g = 1, b = 1, hex = "33ffff"},
		success = {r = 1, g = 0.8, b = 0, hex = "ffcc00"},
		warning = {r = 1, g = 0.4, b = 0, hex = "ff6600"},
		danger = {r = 1, g = 0, b = 0, hex = "ff0000"},
		info = {r = 1, g = 0.7, b = 0.3, hex = "ffb34d"},
		text = {r = 1, g = 1, b = 1, hex = "ffffff"},
		textMuted = {r = 0.9, g = 0.9, b = 0.8, hex = "e6e6cc"},
		bg = {r = 0.2, g = 0.08, b = 0.05, hex = "331a0d"},
		bgPanel = {r = 0.3, g = 0.12, b = 0.08, hex = "4d1f14"},
		border = {r = 1, g = 0.4, b = 0, hex = "ff6600"},
	},
}

-- ===========================
-- FONT STYLES
-- ===========================

local FONT_STYLES = {
	-- Header fonts
	HEADING_LARGE = {family = "Interface\\AddOns\\Arenamaster\\Media\\Fonts\\Morpheus.ttf", size = 20, flags = "outline"},
	HEADING_MEDIUM = {family = "Interface\\AddOns\\Arenamaster\\Media\\Fonts\\Morpheus.ttf", size = 16, flags = "outline"},
	HEADING_SMALL = {family = "Interface\\AddOns\\Arenamaster\\Media\\Fonts\\Morpheus.ttf", size = 14, flags = "outline"},

	-- Body fonts
	BODY_LARGE = {family = "Interface\\AddOns\\Arenamaster\\Media\\Fonts\\Arimo.ttf", size = 13, flags = ""},
	BODY_NORMAL = {family = "Interface\\AddOns\\Arenamaster\\Media\\Fonts\\Arimo.ttf", size = 11, flags = ""},
	BODY_SMALL = {family = "Interface\\AddOns\\Arenamaster\\Media\\Fonts\\Arimo.ttf", size = 9, flags = ""},

	-- Monospace (for stats)
	MONOSPACE = {family = "Interface\\AddOns\\Arenamaster\\Media\\Fonts\\Inconsolata.ttf", size = 10, flags = ""},
}

-- ===========================
-- BORDER STYLES
-- ===========================

local BORDER_STYLES = {
	Rounded = {
		edgeFile = "Interface\\Buttons\\WHITE8X8",
		edgeSize = 1,
		insets = {left = 2, right = 2, top = 2, bottom = 2},
	},
	Sharp = {
		edgeFile = "Interface\\Buttons\\WHITE8X8",
		edgeSize = 2,
		insets = {left = 2, right = 2, top = 2, bottom = 2},
	},
	Glow = {
		edgeFile = "Interface\\Buttons\\WHITE8X8",
		edgeSize = 3,
		insets = {left = 3, right = 3, top = 3, bottom = 3},
	},
	None = {
		edgeFile = nil,
		edgeSize = 0,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	},
}

-- ===========================
-- INITIALIZATION
-- ===========================

function Design:OnInitialize()
	-- Design system initialized
end

function Design:OnEnable()
	-- Design enabled
end

-- ===========================
-- PUBLIC API
-- ===========================

function Design:GetIcon(iconName)
	return ICONS[iconName] or "?"
end

function Design:GetIconEmoji(feature)
	-- Common feature icons
	local featureIcons = {
		frames = ICONS.FRAME,
		cooldowns = ICONS.COOLDOWN,
		threat = ICONS.THREAT,
		prediction = ICONS.PREDICTION,
		analytics = ICONS.ANALYTICS,
		notifications = ICONS.NOTIFICATION,
		goals = ICONS.GOAL,
		rating = ICONS.RATING,
		aura = ICONS.BUFF,
		cc = ICONS.CC,
	}
	return featureIcons[feature] or ICONS.SETTINGS
end

function Design:GetTheme(themeName)
	return COLOR_THEMES[themeName or "Dark"] or COLOR_THEMES.Dark
end

function Design:GetThemeColor(themeName, colorName)
	local theme = self:GetTheme(themeName)
	return theme[colorName]
end

function Design:GetColorCode(themeName, colorName)
	local color = self:GetThemeColor(themeName, colorName)
	if color then
		return "|cff" .. color.hex
	end
	return "|cffffffff"
end

function Design:GetThemeNames()
	local themes = {}
	for name in pairs(COLOR_THEMES) do
		table.insert(themes, name)
	end
	table.sort(themes)
	return themes
end

function Design:GetFontStyle(styleName)
	return FONT_STYLES[styleName]
end

function Design:GetBorderStyle(styleName)
	return BORDER_STYLES[styleName or "Rounded"]
end

-- ===========================
-- STYLING HELPERS
-- ===========================

function Design:ColorText(text, themeName, colorName)
	local code = self:GetColorCode(themeName, colorName)
	return code .. text .. "|r"
end

function Design:FormatHeader(text, themeName)
	local code = self:GetColorCode(themeName, "primary")
	return code .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ " .. text .. " ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━|r"
end

function Design:FormatSection(text, icon, themeName)
	themeName = themeName or "Dark"
	icon = icon or ICONS.SETTINGS
	local code = self:GetColorCode(themeName, "primary")
	return code .. icon .. " " .. text .. "|r"
end

function Design:FormatStatus(status, themeName)
	themeName = themeName or "Dark"
	if status then
		return self:GetColorCode(themeName, "success") .. ICONS.ENABLED .. " " .. status .. "|r"
	else
		return self:GetColorCode(themeName, "danger") .. ICONS.DISABLED .. " Disabled|r"
	end
end

-- ===========================
-- FRAME STYLING
-- ===========================

function Design:SetFrameStyle(frame, themeName, borderStyle)
	themeName = themeName or "Dark"
	borderStyle = borderStyle or "Rounded"

	local theme = self:GetTheme(themeName)
	local border = self:GetBorderStyle(borderStyle)

	if not frame.SetBackdrop then return end

	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = border.edgeFile,
		edgeSize = border.edgeSize,
		insets = border.insets,
	})

	frame:SetBackdropColor(theme.bgPanel.r, theme.bgPanel.g, theme.bgPanel.b, 0.9)
	frame:SetBackdropBorderColor(theme.border.r, theme.border.g, theme.border.b, 1)
end

function Design:SetButtonStyle(button, themeName)
	themeName = themeName or "Dark"
	local theme = self:GetTheme(themeName)

	if button.SetNormalFontObject then
		button:SetNormalFontObject(GameFontNormalLarge)
	end

	if button.SetHighlightFontObject then
		button:SetHighlightFontObject(GameFontHighlightLarge)
	end
end

-- ===========================
-- UTILITY
-- ===========================

function Design:DebugTheme(themeName)
	themeName = themeName or "Dark"
	local theme = self:GetTheme(themeName)

	print(self:FormatHeader("Theme: " .. themeName, themeName))
	for colorName, color in pairs(theme) do
		local formatted = self:ColorText("■ " .. colorName, themeName, colorName)
		print(formatted .. " (" .. color.hex .. ")")
	end
end
