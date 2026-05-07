# Complete API Index - Arenamaster

## 📚 Documentation Files

### Ace3 Framework
1. **[ACE3_GETTING_STARTED.md](ACE3_GETTING_STARTED.md)**
   - Basic Ace3 concepts
   - .toc file structure
   - Core libraries overview
   - Addon lifecycle

2. **[ACECONFIG_OPTIONS_TABLES.md](ACECONFIG_OPTIONS_TABLES.md)**
   - AceConfig-3.0 complete reference
   - All option types with examples
   - Callback info table
   - Registration methods

3. **[ACE3_FRAMEWORK.md](ACE3_FRAMEWORK.md)**
   - All 9 Ace3 libraries
   - Usage examples
   - Best practices
   - Widget types

4. **[ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md)** ⭐ **START HERE**
   - Ace3 + WoW APIs integration
   - Common patterns
   - Real-world examples
   - Best practices

### WoW API Reference
1. **[API_REFERENCE_12.0.5.md](API_REFERENCE_12.0.5.md)**
   - Official WoW 12.0.5 APIs
   - C_PvP namespace (106 functions)
   - Event documentation
   - Safe function reference

2. **[PVP_FUNCTIONS_GUIDE.md](PVP_FUNCTIONS_GUIDE.md)**
   - PvP-specific functions
   - Arena APIs
   - Rating system
   - Code examples

3. **[APPROVED_FUNCTIONS.md](APPROVED_FUNCTIONS.md)**
   - Safe vs restricted functions
   - API compliance checklist
   - Taint system info

### Project Documentation
1. **[MODULE_STRUCTURE.md](MODULE_STRUCTURE.md)**
   - 4-tier module system
   - Dependencies
   - Initialization order

2. **[CONFIG_UI_GUIDE.md](CONFIG_UI_GUIDE.md)**
   - Configuration window guide
   - Presets
   - Settings categories

---

## 🎯 Quick Navigation

### By Task

**Setting Up Module**
1. Read [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md) - Pattern 1
2. Reference [ACE3_FRAMEWORK.md](ACE3_FRAMEWORK.md) - Libraries section
3. Check [MODULE_STRUCTURE.md](MODULE_STRUCTURE.md) - Tier system

**Creating Config UI**
1. Start with [ACECONFIG_OPTIONS_TABLES.md](ACECONFIG_OPTIONS_TABLES.md)
2. Review [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md) - Pattern 2
3. Use [CONFIG_UI_GUIDE.md](CONFIG_UI_GUIDE.md) for UI details

**Using WoW APIs in Code**
1. Check [API_REFERENCE_12.0.5.md](API_REFERENCE_12.0.5.md) for function list
2. See [PVP_FUNCTIONS_GUIDE.md](PVP_FUNCTIONS_GUIDE.md) for PvP-specific
3. Verify in [APPROVED_FUNCTIONS.md](APPROVED_FUNCTIONS.md) for safety

**Event Handling**
1. [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md) - AceEvent pattern
2. [ACE3_GETTING_STARTED.md](ACE3_GETTING_STARTED.md) - AceEvent section
3. [API_REFERENCE_12.0.5.md](API_REFERENCE_12.0.5.md) - Event list

**Timer Operations**
1. [ACE3_FRAMEWORK.md](ACE3_FRAMEWORK.md) - AceTimer section
2. [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md) - Pattern 3

**SavedVariables/Database**
1. [ACECONFIG_OPTIONS_TABLES.md](ACECONFIG_OPTIONS_TABLES.md) - Data persistence
2. [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md) - AceDB pattern

---

## 🔍 Library Reference

### Ace3 Libraries
- **LibStub** → [ACE3_FRAMEWORK.md](ACE3_FRAMEWORK.md#libstub)
- **AceAddon-3.0** → [ACE3_GETTING_STARTED.md](ACE3_GETTING_STARTED.md#aceaddon-30)
- **AceEvent-3.0** → [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md#aceevent-30--wow-events)
- **AceDB-3.0** → [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md#acedb-30--savedvariables)
- **AceConfig-3.0** → [ACECONFIG_OPTIONS_TABLES.md](ACECONFIG_OPTIONS_TABLES.md)
- **AceGUI-3.0** → [ACE3_FRAMEWORK.md](ACE3_FRAMEWORK.md#acegui-30)
- **AceTimer-3.0** → [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md#acetimer-30--wow-onupdate)
- **AceComm-3.0** → [ACE3_GETTING_STARTED.md](ACE3_GETTING_STARTED.md#acecomm-30)
- **AceHook-3.0** → [ACE3_GETTING_STARTED.md](ACE3_GETTING_STARTED.md#acehook-30)

### WoW API Namespaces
- **C_PvP** → [API_REFERENCE_12.0.5.md](API_REFERENCE_12.0.5.md#c_pvp)
- **Events** → [API_REFERENCE_12.0.5.md](API_REFERENCE_12.0.5.md#events)
- **PvP Functions** → [PVP_FUNCTIONS_GUIDE.md](PVP_FUNCTIONS_GUIDE.md)

---

## 📖 Code Examples

### Example 1: Basic Addon with Ace3
See [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md#basic-addon-structure)

### Example 2: Event Handling
See [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md#aceevent-30--wow-events)

### Example 3: Options Configuration
See [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md#aceconfig-30--wow-c_-apis)

### Example 4: Real-time Updates
See [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md#pattern-3-real-time-data-display)

---

## ✅ Verification Checklist

Before coding:
- [ ] Read [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md)
- [ ] Check API in [API_REFERENCE_12.0.5.md](API_REFERENCE_12.0.5.md)
- [ ] Verify safety in [APPROVED_FUNCTIONS.md](APPROVED_FUNCTIONS.md)
- [ ] Review examples in [PVP_FUNCTIONS_GUIDE.md](PVP_FUNCTIONS_GUIDE.md)

---

## 🚀 Getting Started

### Quickstart (5 minutes)
1. Read [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md) - Basic structure section
2. Copy the example code
3. Start modifying for your needs

### Full Learning (30 minutes)
1. [ACE3_GETTING_STARTED.md](ACE3_GETTING_STARTED.md)
2. [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md) - All sections
3. [ACECONFIG_OPTIONS_TABLES.md](ACECONFIG_OPTIONS_TABLES.md) - Option types
4. [API_REFERENCE_12.0.5.md](API_REFERENCE_12.0.5.md) - As reference

---

## 📞 Support

- **Ace3 Official** → https://github.com/WoWUIDev/Ace3
- **WoW API** → https://wowpedia.fandom.com/
- **Examples** → See [ACE3_WOW_API_COMBINED.md](ACE3_WOW_API_COMBINED.md)

---

**Last Updated:** 2026-05-07
**Arenamaster Version:** 4.0.0
