# Arenamaster Documentation - Patch 12.0.5

**Complete API Reference for Safe Addon Development**

This directory contains official World of Warcraft API documentation for Patch 12.0.5, specifically curated for the Arenamaster addon development.

---

## 📚 Documentation Files

### 1. **APPROVED_FUNCTIONS.md** ⭐ START HERE

The **primary reference** for addon development.

- ✅ Lists all SAFE and APPROVED functions
- ⚠️ Lists functions to use with caution
- ❌ Lists functions that are BANNED (deprecated/restricted)
- Checklist before implementing new features

**Use this to:** Know exactly what functions you can safely use

---

### 2. **API_REFERENCE_12.0.5.md**

Complete official API reference from Warcraft Wiki.

- Overview of 12.0.5 API structure
- PvP & Arena API functions (C_PvP namespace)
- Rating & progression functions
- Unit information queries
- Action bar & cooldown systems
- Events reference
- Global functions (Lua & WoW)
- Restricted/Tainted functions warning

**Use this to:** Look up detailed function documentation

---

### 3. **PVP_FUNCTIONS_GUIDE.md**

Specialized guide for PvP/Arena functions.

- C_PvP namespace (106 total functions)
- Safe arena functions with examples
- Opponent information retrieval
- Events (arena & PvP)
- Code examples for common tasks
- Best practices for PvP addons
- Functions to AVOID
- Testing guide

**Use this to:** Implement PvP-specific features

---

### 4. **PATCH_CHANGES.md**

What changed in Patch 12.0.0 → 12.0.5.

- "Addon Apocalypse" overview
- APIs removed (138 total)
- APIs added (437 total)
- New events (76 total)
- Taint system explanation
- New technologies (Secret Values)
- Migration guide from older patches
- Version timeline

**Use this to:** Understand why certain functions don't work anymore

---

## 🎯 Quick Reference

### For New Features

1. **Check APPROVED_FUNCTIONS.md first**
   - Is the function in the ✅ SAFE list?
   - Is it NOT in the ❌ DO NOT USE list?

2. **Read PVP_FUNCTIONS_GUIDE.md**
   - Get code examples
   - Understand when the function is available
   - Learn best practices

3. **Check API_REFERENCE_12.0.5.md**
   - Get detailed documentation
   - Understand return values
   - See related functions

### For Debugging

1. Check **PATCH_CHANGES.md** - Was this function removed?
2. Check **APPROVED_FUNCTIONS.md** - Is it banned?
3. Check **PVP_FUNCTIONS_GUIDE.md** - When can it be called?

---

## 🚨 Critical Rules

### ALWAYS CHECK BEFORE IMPLEMENTING

✅ **BEFORE** you write any code:
- [ ] Check if function is in APPROVED_FUNCTIONS.md ✅ list
- [ ] Check if function is NOT in ❌ DO NOT USE list
- [ ] Verify it's not deprecated (check PATCH_CHANGES.md)
- [ ] Read the code examples in PVP_FUNCTIONS_GUIDE.md

❌ **NEVER** do this:
- Add a function that's not in APPROVED_FUNCTIONS.md without research
- Use GetArenaOpponentSpec() - it returns nil
- Try to read enemy buffs/debuffs in combat
- Cast spells based on combat decisions
- Use removed functions from older patches

---

## 📋 Current Implementation Status

### ✅ Currently Using (Correct)

```lua
C_PvP.GetActiveMatchBracket()
C_PvP.GetActiveMatchDuration()
C_PvP.GetActiveMatchState()
C_PvP.GetActiveMatchWinner()
GetPersonalRatedInfo()
GetUnitName()
-- And more (see APPROVED_FUNCTIONS.md)
```

### ❌ Found an Issue?

If you find that a function we're using:
- Returns nil unexpectedly
- Is deprecated
- Doesn't exist in 12.0.5
- Is restricted or tainted

**→ Check these files in order:**
1. APPROVED_FUNCTIONS.md
2. PATCH_CHANGES.md
3. PVP_FUNCTIONS_GUIDE.md

---

## 🔄 Version Information

- **Patch**: 12.0.5
- **Release**: April 23, 2026
- **Documentation Updated**: May 7, 2026
- **API Status**: Current & Verified

---

## 📖 How to Use This Documentation

### Scenario 1: Adding a new feature
```
1. Think of what you want to implement
2. Open APPROVED_FUNCTIONS.md
3. Search for the function name
4. If ✅, proceed with PVP_FUNCTIONS_GUIDE.md
5. If ❌, find an alternative or ask
```

### Scenario 2: Function not working
```
1. Check APPROVED_FUNCTIONS.md - is it in ❌?
2. Check PATCH_CHANGES.md - was it removed?
3. Check PVP_FUNCTIONS_GUIDE.md - when can it be called?
4. Verify the function call syntax in API_REFERENCE_12.0.5.md
```

### Scenario 3: "Can I use this function?"
```
Answer: Only if it's in APPROVED_FUNCTIONS.md ✅ list
Otherwise: NO - find alternative or ask
```

---

## 🎓 Learning Resources

**If you want to understand deeper:**

1. **Taint System** → Read PATCH_CHANGES.md
2. **All Arena Functions** → Read PVP_FUNCTIONS_GUIDE.md
3. **Complete API** → Read API_REFERENCE_12.0.5.md
4. **Safe to Use** → Read APPROVED_FUNCTIONS.md

---

## 🔗 External Resources

- **Official WoW Addons Source**: https://github.com/Gethe/wow-ui-source
- **Community Wiki**: https://warcraft.wiki.gg
- **In-Game Help**: `/api` command in World of Warcraft

---

## 📝 Notes

- This documentation is specific to **Patch 12.0.5**
- When WoW updates to 12.1.0 or later, **VERIFY ALL FUNCTIONS AGAIN**
- Some functions may behave differently in different contexts (prep vs combat)
- Always test in-game before committing code

---

**Last Updated**: May 7, 2026  
**Patch**: 12.0.5  
**Status**: Ready for Development

---

## 📧 Maintenance

Before updating to a new patch:
1. Review PATCH_CHANGES.md
2. Update APPROVED_FUNCTIONS.md
3. Verify all functions in PVP_FUNCTIONS_GUIDE.md
4. Test every function in-game
5. Update version information

