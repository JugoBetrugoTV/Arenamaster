# Ace3 Getting Started - Official Documentation

## Overview

Ace3 is a modular framework for World of Warcraft addon development. Addons need not use every component—developers can pick and choose libraries relevant to their needs.

## Basic Addon File Setup

### .toc File Structure
The `.toc` file identifies the addon to WoW. It contains metadata headers (prefixed with `##`) and a list of files to load:

```
## Interface: 120005
## Title: My Addon's Title
## Notes: Some notes about this addon.
## Author: Your Name Here
## Version: 1.0
## SavedVariables: MyAddonDB
```

The lines which begin with `##` provide information about your addon itself to WoW including interface version and display name.

### embeds.xml
This XML file references embedded libraries, typically using LibStub and Ace3 libraries from a `Libs` subdirectory.

Example:
```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/">
  <Script file="libs/LibStub/LibStub.lua"/>
  <Script file="libs/AceAddon-3.0/AceAddon-3.0.lua"/>
  <Script file="libs/AceEvent-3.0/AceEvent-3.0.lua"/>
  <!-- ... more libs ... -->
</Ui>
```

### Core.lua
Contains the main addon code and logic implementation.

## Key Ace3 Libraries

### AceAddon-3.0
Creates an addon instance and manages lifecycle events:

- **OnInitialize()** - Called when addon first loads
- **OnEnable()** - Called when addon is enabled  
- **OnDisable()** - Called when addon is disabled

```lua
MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon")

function MyAddon:OnInitialize()
  -- Setup code
end

function MyAddon:OnEnable()
  -- Startup code
end
```

### AceConsole-3.0
Handles chat output and slash commands.

**Output method**: `MyAddon:Print("Hello, world!")`

**Slash commands**: Register via `RegisterChatCommand()` method

### AceConfig-3.0
Generates user interfaces for addon options automatically. Uses an options table defining settings and handlers for `get`/`set` operations.

Registration:
```lua
LibStub("AceConfig-3.0"):RegisterOptionsTable("MyAddonName", options, {"myslash"})
```

### AceDB-3.0
Persists addon data across sessions through SavedVariables. Requires `.toc` entry: `## SavedVariables: MyAddonDB`

Initialize in `OnInitialize()`:
```lua
self.db = LibStub("AceDB-3.0"):New("MyAddonDB")
```

**Available subtables**:
- **char** - Character-specific data
- **realm** - Realm-wide data
- **profile** - User-selectable profiles
- **global** - Shared across all characters

### AceEvent-3.0
Manages WoW client events and inter-addon messaging.

**Event subscription**:
```lua
MyAddon:RegisterEvent("EVENT_NAME", "OnEventName")
```

**Messages** (local addon communication):
```lua
MyAddon:SendMessage("MESSAGE_NAME", arg1, arg2)
```

### AceComm-3.0
Enables cross-client communication between players.

Methods:
- `SendCommMessage(prefix, text, distribution, target)`
- `RegisterComm(prefix)` to receive messages

Supports channels: PARTY, RAID, BATTLEGROUND, GUILD, WHISPER

### AceHook-3.0
Hooks WoW functions and frame scripts. Three hooking types:

- **Standard Hook** - Calls original function automatically
- **Raw Hook** - Manual control over original function calls
- **Secure Hook** - Executes after hooked function (for protected UI)

### AceLocale-3.0
Manages multi-language translations. Setup involves creating locale files with translation tables, then accessing them in main code.

### AceSerializer-3.0
Converts Lua data to serialized strings and back.

Methods:
- `Serialize()` - Convert to string
- `Deserialize()` - Recover original data

### AceGUI-3.0
Provides widget system for creating interfaces with frames, buttons, dropdowns, etc.

### AceTab-3.0
Implements tab functionality for tabbed interfaces.

### AceTimer-3.0
Schedule timed operations and delayed callbacks.

### AceBucket-3.0
Groups multiple events to prevent spam.

## Community Notes

- Full documentation: https://wowpedia.fandom.com/wiki/Ace3_for_Dummies
- Source code: https://github.com/WoWUIDev/Ace3
- Downloads: https://www.wowace.com/projects/ace3

---

Version: Official Documentation
Last Updated: 2026-05-07
