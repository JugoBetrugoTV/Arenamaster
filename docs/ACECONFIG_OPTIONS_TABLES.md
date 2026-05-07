# AceConfig-3.0 Options Tables - Complete Reference

## Overview

AceConfig-3.0 provides a standardized format for representing addon configuration options. The system uses hierarchical table structures that can be displayed through various UI implementations (dialog, command-line, dropdown).

## Basic Structure

Every options table begins with a root group node containing an `args` subtable:

```lua
myOptionsTable = {
  type = "group",
  args = {
    enable = {
      name = "Enable",
      desc = "Enables / disables the addon",
      type = "toggle",
      set = function(info,val) MyAddon.enabled = val end,
      get = function(info) return MyAddon.enabled end
    }
  }
}
```

## Common Parameters (All Types)

- **name** (string|function) — Display label
- **desc** (string|function) — Description/tooltip text
- **type** (string) — Option type identifier
- **order** (number|function) — Display position (default: 100)
- **disabled** (boolean|function) — Grayed-out but visible
- **hidden** (boolean|function) — Completely hidden from UI
- **validate** (function|false) — Input validation returning error strings
- **confirm** (boolean|function) — Prompt before changing values
- **handler** (table) — Object for method-based callbacks
- **icon** (string|function) — Texture path for display
- **width** (string|number) — Size hint ("double", "half", "full", numeric multiplier)

## Option Types

### execute
Runs a function; typically displays as a button in GUIs.

```lua
{
  type = "execute",
  name = "Click Me",
  func = function(info) print("Clicked!") end,
}
```

Parameters:
- **func** (function|methodname) — Function to execute
- **image** (string|function) — Optional clickable image texture

### input
Text field with optional validation against a pattern.

```lua
{
  type = "input",
  name = "Server",
  get = function(info) return myAddon.server end,
  set = function(info, val) myAddon.server = val end,
  pattern = "^[%a%d]+$",
  multiline = false,
}
```

Parameters:
- **get/set** — Getter/setter functions
- **multiline** (boolean|integer) — Multi-line display support
- **pattern** (string) — Regex validation pattern
- **usage** (string) — Format help text

### toggle
Checkbox control.

```lua
{
  type = "toggle",
  name = "Enable Feature",
  get = function(info) return myAddon.enabled end,
  set = function(info, val) myAddon.enabled = val end,
  tristate = false,
}
```

Parameters:
- **get/set** — Getter/setter functions
- **tristate** (boolean) — Three-state support (false/true/nil)

### range
Numeric slider within min/max bounds.

```lua
{
  type = "range",
  name = "Volume",
  min = 0, max = 100, step = 1,
  get = function(info) return myAddon.volume end,
  set = function(info, val) myAddon.volume = val end,
  isPercent = true,
}
```

Parameters:
- **min, max** — Absolute value limits
- **softMin, softMax** — UI convenience limits (for slider display)
- **step** — Increment size
- **bigStep** — Larger step increment
- **get/set** — Getter/setter functions
- **isPercent** (boolean) — Display as percentage

### select
Single-choice dropdown or radio group.

```lua
{
  type = "select",
  name = "Theme",
  values = {dark = "Dark", light = "Light", auto = "Auto"},
  get = function(info) return myAddon.theme end,
  set = function(info, val) myAddon.theme = val end,
  style = "dropdown",
}
```

Parameters:
- **values** (table|function) — {key=displayText} pairs
- **sorting** (table|function) — Optional key ordering
- **get/set** — Getter/setter functions
- **style** — "dropdown" or "radio"

### multiselect
Multiple checkboxes from a values table.

```lua
{
  type = "multiselect",
  name = "Features",
  values = {
    feature1 = "Feature 1",
    feature2 = "Feature 2",
    feature3 = "Feature 3",
  },
  get = function(info, key) return myAddon.features[key] end,
  set = function(info, key, val) myAddon.features[key] = val end,
}
```

Parameters:
- **values** (table|function) — Available options
- **get** — Called per key with key name parameter
- **set** — Called with (keyname, state)
- **tristate** (boolean) — Three-state support

### color
Color picker dialog.

```lua
{
  type = "color",
  name = "Text Color",
  get = function(info) 
    return myAddon.r, myAddon.g, myAddon.b, myAddon.a 
  end,
  set = function(info, r, g, b, a) 
    myAddon.r, myAddon.g, myAddon.b, myAddon.a = r, g, b, a 
  end,
  hasAlpha = true,
}
```

Parameters:
- **get/set** — Returns/accepts (r,g,b,a) values
- **hasAlpha** (boolean) — Enable alpha channel

### keybinding
Hotkey assignment control.

```lua
{
  type = "keybinding",
  name = "Toggle Addon",
  get = function(info) return GetBindingKey("TOGGLEADDON") end,
  set = function(info, val) SetBinding(val, "TOGGLEADDON") end,
}
```

Parameters:
- **get/set** — Getter/setter functions

### header
Display heading/section divider.

```lua
{
  type = "header",
  name = "Display Options",
  order = 10,
}
```

Parameters:
- **name** — Heading text

### description
Static text block with optional image.

```lua
{
  type = "description",
  name = "Configure your addon settings below.",
  fontSize = "medium",
  image = "Interface/Icons/achievement_general",
}
```

Parameters:
- **name** — Text content
- **fontSize** — "large", "medium", "small"
- **image** — Texture path

### group
Container for nested options.

```lua
{
  type = "group",
  name = "Advanced",
  desc = "Advanced settings",
  args = {
    setting1 = { type = "toggle", ... },
    setting2 = { type = "range", ... },
  },
  childGroups = "tab",
}
```

Parameters:
- **args** (table) — Child options
- **plugins** (table) — Module-contributed options
- **childGroups** — "tree" (default), "tab", or "select"
- **inline** (boolean) — Display as bordered box

## Inheritance

These parameters cascade through nested tables unless explicitly overridden:
- set, get, func
- confirm, validate, disabled, hidden
- handler

To prevent inheritance, set parameter to `false`.

## Callback Info Table

All callbacks receive `(info, value)` where the info table contains:

```lua
function set_callback(info, value)
  print(info[0])        -- Slash command name or empty string
  print(info[#info])    -- Current leaf node name
  print(info[#info-1])  -- Parent node name
  print(info.handler)   -- Handler object for current option
  print(info.type)      -- Current option type
end
```

**Info table properties:**
- **info[0]** — Slash command name or empty string
- **info[n]** — Node names traversing from root to current option
- **info[#info]** — Current leaf node name
- **info[#info-1]** — Parent node name
- **info.options** — Root options table reference
- **info.handler** — Handler object for current option
- **info.type** — Current option type
- **info.option** — Current option definition
- **info.uiType, info.uiName** — UI implementation details

**Hint:** Use `info[#info]` for current key, `info[#info-1]` for parent.

## Registering Options

```lua
local AceConfig = LibStub("AceConfig-3.0")

AceConfig:RegisterOptionsTable("MyAddon", myOptionsTable)

-- With slash command
AceConfig:RegisterOptionsTable("MyAddon", myOptionsTable, {"/myaddon"})
```

## Custom AceGUI Controls

Dialog implementations support custom widgets via the **dialogControl** attribute:

```lua
{
  type = "input",
  name = "Custom Input",
  dialogControl = "MyCustomWidget",
}
```

Widgets must implement:
- `SetDisabled(disabled)`
- `SetValue(value)`
- Fire `OnEnter` and `OnLeave` events
- Fire `OnValueChanged` with value

---

Version: Official Documentation
Last Updated: 2026-05-07
