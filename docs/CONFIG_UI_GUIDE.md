# Arenamaster Config UI Guide

## 🎨 Opening the Configuration Window

Simply use the command:
```
/am config
```

Or alternatively:
```
/am settings
```

The beautiful configuration window will open with a modern, professional design.

---

## 🎯 UI Layout

### Left Sidebar
The left sidebar contains:

1. **Presets Section (Top)**
   - 🔥 **Aggressive** - Large frames, maximum visibility, all alerts enabled
   - ⚔️ **Competitive** - Balanced setup for ranked play
   - 🎥 **Streamer** - Optimized for stream visibility with large text
   - ⚪ **Minimal** - Ultra-clean UI, distraction-free
   - 🎮 **Casual** - Relaxed setup with optional notifications

   Click any preset to instantly apply all recommended settings.

2. **Search Box**
   - Type to search settings by name, description, or key
   - Real-time filtering
   - Shows matching settings in the main content area

3. **Categories**
   - 🎯 **FRAMES** - Enemy frame layout and display options
   - ⚡ **AURAS** - Cooldown and aura tracking settings
   - 📢 **NOTIFICATIONS** - Alert system configuration
   - 🎨 **UI** - Appearance and theme settings
   - 📊 **STATS** - Statistics tracking options

### Main Content Area
The main area displays:
- Category title
- Grouped settings organized by function
- Description for each setting
- Interactive controls:
  - ✅ **Checkboxes** - Toggle settings on/off
  - 📊 **Sliders** - Adjust numeric values with live preview
  - 🔘 **Buttons** - Choose from options

### Action Bar (Bottom)
- 🔄 **Reset** - Reset all settings to defaults (with confirmation)
- 📤 **Export** - Copy your config string to share with friends
- 💾 **Save** - Save current settings as a named profile

---

## ⚙️ Setting Categories

### 🎯 FRAMES (Enemy Frames)
**Layout Group:**
- Frame Layout: vertical, horizontal, or grid
- Frame Width: 150-350 pixels
- Frame Height: 60-150 pixels
- Frame Spacing: 0-20 pixels
- Frame Position X/Y: Fine-tune screen position

**Appearance Group:**
- Frame Opacity: 0.3-1.0 (transparency)

**Display Group:**
- Show Names: Display opponent names
- Show Health %: Display health numbers
- Show Mana Bar: Display resource bars
- Show Cast Bar: Display spell casting
- Show Trinket: Display trinket cooldown
- Show Buffs: Display beneficial auras
- Show Debuffs: Display CC effects

### ⚡ AURAS (Cooldown & Aura Tracking)
**Core:**
- Enable Tracking: Master switch

**Tracking:**
- Track Cooldowns: Monitor ability cooldowns
- Track Buffs: Monitor beneficial effects
- Track Debuffs: Monitor CC effects

**Display:**
- Show Countdown: Display time remaining

### 📢 NOTIFICATIONS (Alerts & Sounds)
**Events:**
- Match Start Notification
- Match End Notification

**Audio:**
- Sound Alerts: Play sounds for events

**Output:**
- Chat Announcements: Announce to chat
- Colored Messages: Use colors in chat

### 🎨 UI (Interface Theme)
**Interface:**
- Show Close Button: Display close button

**Theme:**
- UI Theme: Dark, Light, or Classic
- Font Size: 8-16 pixels

### 📊 STATS (Recording & History)
**Recording:**
- Track Games: Record match history
- Track Opponents: Store opponent data
- Track Rating: Monitor rating changes

---

## 🎨 Visual Features

### Color Coding
- **Cyan** - Primary interface color, active elements
- **Orange** - Active/selected elements
- **Green** - Success states
- **Red** - Danger/warnings
- **Gray** - Disabled/secondary text

### Hover Effects
All buttons and controls respond to mouse hover with visual feedback:
- Buttons brighten when hovered
- Enhanced border visibility
- Smooth color transitions

### Search Functionality
Type in the search box to instantly filter settings:
- Searches by setting name
- Searches by description
- Searches by internal key
- Shows "No results" if no matches found

---

## 💾 Profiles

### Saving a Profile
1. Click the **💾 Save** button
2. Type a name for your profile
3. Click "Save" to confirm

Profiles are saved locally and can be loaded anytime.

### Loading a Profile
Use chat command: `/am profile load <name>`
Or use the profile manager (future enhancement)

---

## 📤 Import/Export

### Export Your Config
1. Click the **📤 Export** button
2. An export string appears in chat
3. Copy the entire string
4. Share with friends or save for backup

### Import a Config
In chat, paste the import command:
```
/am import [paste_the_export_string_here]
```

This will load all settings from the exported config.

---

## 🎯 Quick Tips

1. **Preset First** - Start with a preset that matches your playstyle
2. **Fine-tune** - Use individual settings to customize further
3. **Save Often** - Save your config as a profile for backup
4. **Search** - Use search to quickly find specific settings
5. **Export Backup** - Periodically export your config as a backup

---

## 🆘 Common Settings

### For Large Monitors
Use the **Streamer** preset - it's optimized for visibility on larger screens.

### For Competitive Play
Use the **Competitive** preset - balanced settings for serious ranked play.

### For Stream Setup
Use the **Streamer** preset with maximum opacity (1.0) and large font size (13).

### For Laptop/Netbook
Use the **Minimal** preset to reduce screen clutter and improve FPS.

---

## Version
Config UI v1.0 - Arenamaster 4.0+

---

**Enjoy your perfectly configured Arenamaster addon! ⚔️**
