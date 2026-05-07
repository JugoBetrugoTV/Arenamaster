# 📦 Installation Guide

## Step-by-Step Installation

### 1. Download & Extract

**Option A: Manual Installation**
1. Download the addon files
2. Extract to: `World of Warcraft\_retail_\Interface\AddOns\Arenamaster\`
3. Folder structure should be:
   ```
   AddOns\
   └── Arenamaster\
       ├── Arenamaster.lua
       ├── Arenamaster.toc
       ├── modules\
       ├── docs\
       └── ...
   ```

**Option B: Clone from Repository**
```bash
cd World of Warcraft\_retail_\Interface\AddOns\
git clone https://github.com/JugoBetrugoTV/Arenamaster.git
```

### 2. Enable in World of Warcraft

1. Launch World of Warcraft
2. Click "AddOns" at login screen
3. Check "Arenamaster" in the addon list
4. Log in to your character

### 3. Verify Installation

1. In-game, type: `/am help`
2. Should show help menu
3. Type: `/am config`
4. Should open configuration window

---

## ✅ Installation Checklist

- [ ] Files extracted to correct folder
- [ ] Arenamaster.toc exists
- [ ] Arenamaster.lua exists
- [ ] modules/ folder exists with all .lua files
- [ ] Addon shows in addon list
- [ ] Addon is checked/enabled
- [ ] Game restarted after enabling
- [ ] `/am help` works in-game
- [ ] `/am config` opens config window

---

## 🆘 Troubleshooting

### Addon doesn't appear in list

**Solution:**
1. Check folder name is exactly "Arenamaster"
2. Check WoW version is 12.0.5 or higher
3. Copy folder path and verify it's in AddOns
4. Restart WoW completely (not just /reload)

```
Correct path: ...\Interface\AddOns\Arenamaster\
Wrong path: ...\Interface\AddOns\arenamaster\  (wrong case)
Wrong path: ...\Interface\Arenamaster\         (wrong folder)
```

### Addon loads but slash commands don't work

**Solution:**
1. Type: `/reload`
2. Wait for reload to complete
3. Try `/am help` again
4. Check character name (must log into same realm)

### Config UI won't open

**Solution:**
1. Verify addon is enabled
2. Type: `/am help`
3. If help works but config doesn't:
   - Try: `/reload`
   - Try: `/am config` again
4. If still fails, reinstall addon

### Performance issues / Lag spikes

**Solution:**
1. Use **Minimal** preset in config
2. Disable unnecessary notifications
3. Check if other addons conflict
4. Disable other PvP addons temporarily
5. Try on different character

---

## 📋 System Requirements

### Minimum
- **WoW Version:** 12.0.5 Retail
- **Interface:** 120005+
- **RAM:** 100 MB free
- **Disk Space:** 5 MB

### Recommended
- **WoW Version:** Latest 12.0.5 patch
- **RAM:** 500 MB+ free
- **FPS:** 60+ for best experience
- **Screen Resolution:** 1920x1080+

---

## 🎮 Arena Support

Works in:
- ✅ 2v2 Arena
- ✅ 3v3 Arena
- ✅ 5v5 Arena (RBG)
- ✅ Solo Shuffle

Not available in:
- ❌ Battlegrounds (rated or casual)
- ❌ World PvP
- ❌ Dungeons / Raids

---

## 🆔 Compatibility

### Compatible With
- ✅ WeakAuras
- ✅ DBM / BigWigs
- ✅ Most UI addons
- ✅ Gladius (may overlap)
- ✅ ArenaCore (may overlap)

### Known Conflicts
- ⚠️ Other arena addons (use presets to avoid overlap)
- ⚠️ Frame addons that modify arena frames

**Tip:** Use the **Minimal** preset if using other arena addons

---

## 🔧 Uninstall

To remove:
1. Go to: `World of Warcraft\_retail_\Interface\AddOns\`
2. Delete "Arenamaster" folder
3. Restart WoW
4. Verify folder is gone from addon list

---

## 📞 Support

Having issues?

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Verify WoW version (must be 12.0.5)
3. Try `/reload` in-game
4. Reinstall addon

---

**Installation Complete! Enjoy Arenamaster! ⚔️**

Last Updated: 2026-05-07
