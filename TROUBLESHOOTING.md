# 🐛 Troubleshooting Guide

## Common Issues & Solutions

### Issue: Addon won't load

**Symptoms:** Addon doesn't appear in addon list

**Solutions:**
1. **Check folder location:**
   - Correct: `Interface\AddOns\Arenamaster\`
   - Verify capitalization
   - Move folder if in wrong location

2. **Check WoW version:**
   - Open WoW, go to Options
   - Should show version 12.0.5 or higher
   - If older, update WoW

3. **Check file integrity:**
   - Verify `Arenamaster.toc` exists
   - Verify `Arenamaster.lua` exists
   - Check `modules\` folder has files
   - If missing files, reinstall addon

4. **Restart WoW:**
   - Close WoW completely (not just exit to menu)
   - Wait 10 seconds
   - Reopen WoW
   - Enable addon again

---

### Issue: Slash commands don't work

**Symptoms:** `/am help` returns "unknown command"

**Solutions:**
1. **Try reload:**
   ```
   /reload
   ```
   Wait for reload to complete, then try again

2. **Check addon is enabled:**
   - Exit to main menu
   - Click AddOns
   - Verify Arenamaster is checked

3. **Relog:**
   - Exit to character select
   - Log back in
   - Try `/am help` again

4. **Reinstall:**
   - Delete Arenamaster folder
   - Re-download and extract
   - Enable and restart WoW

---

### Issue: Config window won't open

**Symptoms:** `/am config` doesn't open window

**Solutions:**
1. **Verify addon loaded:**
   ```
   /am help
   ```
   Should show help text

2. **Try reload:**
   ```
   /reload
   ```
   Then try `/am config` again

3. **Check if window exists:**
   - Look for frame at center of screen
   - May be off-screen, try `/am config` and look carefully
   - Try dragging from screen edges

4. **Reset positions:**
   - Delete SavedVariables:
     - Go to: `WTF\Account\ACCOUNT_NAME\SavedVariables\`
     - Delete: `Arenamaster.lua`
   - Reload WoW
   - Try `/am config` again

---

### Issue: Settings not saving

**Symptoms:** Changes revert after reload/logout

**Solutions:**
1. **Check SavedVariables folder:**
   ```
   WTF\Account\ACCOUNT_NAME\SavedVariables\Arenamaster.lua
   ```
   Should exist and have content

2. **Check folder permissions:**
   - Folder must be writable
   - Check Windows permissions
   - Run WoW as administrator if needed

3. **Reset SavedVariables:**
   - Delete `Arenamaster.lua` in SavedVariables
   - Reload WoW
   - Reconfigure addon
   - Log out to save

4. **Verify save:**
   - Change a setting
   - Type: `/console reloadui`
   - Check if setting is still there

---

### Issue: Performance lag / FPS drops

**Symptoms:** Game slows down in arena matches

**Solutions:**
1. **Use Minimal preset:**
   - Open `/am config`
   - Click "Minimal" preset
   - This reduces UI complexity

2. **Disable notifications:**
   - Go to Notifications category
   - Uncheck: "Sound Alerts"
   - Uncheck: "Chat Announcements"

3. **Disable enemy frames:**
   - Go to Frames category
   - Uncheck: "Show Cast Bar"
   - Uncheck: "Show Buffs" or "Show Debuffs"

4. **Check other addons:**
   - Disable other addons one by one
   - See if performance improves
   - May have addon conflict

5. **Update graphics:**
   - Update video card drivers
   - Lower WoW graphics settings
   - Check disk space (should have 10GB+ free)

---

### Issue: Enemy frames not showing

**Symptoms:** Don't see opponent health bars

**Solutions:**
1. **Check frames are enabled:**
   - `/am config` → Frames category
   - Check: "Show Names" is enabled
   - Check: "Show Health Bar" is enabled

2. **Check position:**
   - May be off-screen
   - Go to Frames → Position X/Y
   - Set to defaults: X=100, Y=200
   - Close and reopen config

3. **Check layout:**
   - Frames → Frame Layout
   - Try different option (vertical/horizontal/grid)

4. **Reload UI:**
   ```
   /console reloadui
   ```

---

### Issue: Wrong opponent information

**Symptoms:** Names or specs showing incorrectly

**Solutions:**
1. **Wait for load:**
   - Opponent data loads during arena prep
   - Wait 5 seconds in arena lobby
   - Data should populate

2. **Check cache:**
   - Delete SavedVariables\Arenamaster.lua
   - Reload WoW
   - Cache will rebuild during matches

3. **Verify opponent specs:**
   - Data comes from WoW API
   - Sometimes delayed
   - Specs load during match

---

### Issue: Threat detection not working

**Symptoms:** Focus target not showing or incorrect

**Solutions:**
1. **Check threat detection:**
   - Verify you're in arena match
   - Wait 2-3 seconds for data to load
   - Threat calculation should start

2. **Check ThreatDetector module:**
   ```
   /am threat
   ```
   Should show threat analysis

3. **Reload if needed:**
   ```
   /reload
   ```

---

### Issue: Goals not progressing

**Symptoms:** Goal progress stuck at 0

**Solutions:**
1. **Check if tracking enabled:**
   - Stats → Track Games: must be enabled
   - Stats → Track Rating: must be enabled

2. **Play matches:**
   - Progress updates after arena matches
   - Must finish match (win or loss)
   - Progress saves to SavedVariables

3. **Verify savings:**
   - Check SavedVariables folder exists
   - Try `/reload` to refresh

---

## Advanced Troubleshooting

### Enable Debug Mode

To see detailed error messages:
```lua
-- In WoW chat, type:
/script ArenamasterDB.debugMode = true
/reload
```

Then check error logs:
- Open WoW folder
- Find `Logs\` folder
- Check latest log file for errors

### Check Saved Variables

To verify settings are saving:
1. Go to: `WTF\Account\ACCOUNT_NAME\SavedVariables\`
2. Open: `Arenamaster.lua` with text editor
3. Should contain your configuration

Example content:
```lua
ArenamasterDB = {
    config = {
        frameWidth = 220,
        frameHeight = 85,
        -- ... more settings
    }
}
```

### Reset Everything

Complete reset to factory defaults:
1. Delete folder: `WTF\Account\ACCOUNT_NAME\SavedVariables\Arenamaster.lua`
2. Delete addon: `Interface\AddOns\Arenamaster\`
3. Reinstall addon
4. Restart WoW
5. Reconfigure from scratch

---

## Still Having Issues?

If none of these solutions work:

1. **Verify requirements:**
   - WoW version is 12.0.5+
   - Operating system is Windows/Mac/Linux
   - Folder location is correct

2. **Check documentation:**
   - Read [INSTALLATION.md](INSTALLATION.md)
   - Read [README.md](README.md)
   - Check [CONFIG_UI_GUIDE.md](docs/CONFIG_UI_GUIDE.md)

3. **Collect information:**
   - WoW version
   - Addon version (check `/am help`)
   - Steps to reproduce issue
   - Screenshots if helpful

---

**Version:** 4.0.0
**Last Updated:** 2026-05-07
