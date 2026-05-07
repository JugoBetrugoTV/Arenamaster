# Changelog

All notable changes to Arenamaster are documented here.

## Format

- **Added** for new features
- **Changed** for changes to existing functionality
- **Fixed** for bug fixes
- **Removed** for removed features
- **Improved** for improvements to existing features

---

## [4.0.0] - 2026-05-07

### Added
- Beautiful graphical configuration UI with modern design
- 5 pre-configured presets (Aggressive, Competitive, Streamer, Minimal, Casual)
- Real-time search/filter functionality in config window
- Scrollable content area for large setting lists
- Opponent profiling with machine learning playstyle detection
- Match win probability prediction (5-95% range)
- Goal tracker with time-to-completion estimation
- Visual callouts system with priority coloring
- XML-based dependency system for module load order
- Comprehensive documentation and guides
- Module structure documentation with dependency graph
- Installation guide and troubleshooting guide
- License and open-source setup

### Changed
- Removed all command-based configuration system
- Simplified slash commands to focus on essentials
- Reorganized modules into 4-tier dependency system
- Improved startup messaging with visual formatting
- Enhanced config system with better validation

### Improved
- UI/UX of configuration system (now graphical)
- Module loading performance with tiered initialization
- Documentation completeness
- Code organization and structure

---

## [3.5.0] - 2026-04-15

### Added
- Smart notifications with intelligent filtering
- Priority-based alert system (CRITICAL, HIGH, MEDIUM, LOW)
- Notification throttling to prevent spam
- Arena minimap with player positioning
- Class-colored player indicators
- Combat analytics with efficiency scoring
- Match history tracking (last 100 matches)
- Event-based notification triggers

### Changed
- Improved notification system architecture
- Enhanced threat detection calculations

### Fixed
- Notification timing issues
- Map display in different arena sizes

---

## [3.0.0] - 2026-03-20

### Added
- Threat detection system with 8-factor scoring
- Intelligent focus recommendations
- Cooldown prediction with confidence scoring
- Next dangerous ability tracking
- Team defensive/offensive status analysis
- Opponent playstyle foundation
- Combat analytics module

### Changed
- Refactored aura tracking system
- Improved cooldown calculation accuracy

### Improved
- Threat detection responsiveness
- Cooldown prediction accuracy

---

## [2.0.0] - 2026-02-10

### Added
- Enemy frames with real-time updates
- Health/mana/cast bar display
- Trinket cooldown tracking
- Buff/debuff display system
- Configuration system with profiles
- Import/export functionality
- Aura tracking module
- Multiple frame layout options (vertical, horizontal, grid)
- Click-to-target functionality

### Changed
- Complete UI redesign
- Enhanced opponent frame system
- Improved configuration management

---

## [1.0.0] - 2026-01-01

### Added
- Initial addon release
- Core arena tracking functionality
- Opponent cache system
- Basic statistics tracking
- Match result recording
- Cooldown tracker (basic)
- Rating system with tier determination
- Enemy frame display (basic)
- Configuration system (basic)
- Slash command system

### Features
- Opponent encounter tracking
- Win/loss records
- Rating progression
- Basic threat detection
- Cooldown monitoring

---

## Version History Summary

| Version | Date | Features | Status |
|---------|------|----------|--------|
| 4.0.0 | 2026-05-07 | Beautiful Config UI, AI Intelligence | ✅ Current |
| 3.5.0 | 2026-04-15 | Smart Notifications, Minimap | ✅ Stable |
| 3.0.0 | 2026-03-20 | Threat Detection, Prediction | ✅ Stable |
| 2.0.0 | 2026-02-10 | Enemy Frames, Config System | ✅ Legacy |
| 1.0.0 | 2026-01-01 | Core Functionality | ✅ Legacy |

---

## Planned Features

### v4.1.0 (Upcoming)
- [ ] PvP hotkey assistant
- [ ] Recorded match replays
- [ ] Advanced statistics dashboard
- [ ] Discord integration
- [ ] Web statistics portal

### v4.2.0
- [ ] Streaming overlay support
- [ ] Custom callout creation
- [ ] More playstyle detection patterns
- [ ] Performance optimizations
- [ ] Extended logging system

### v5.0.0 (Future)
- [ ] Complete UI redesign
- [ ] Mobile companion app
- [ ] Team statistics tracking
- [ ] Advanced analytics engine
- [ ] Machine learning improvements

---

## Compatibility

### Supported WoW Versions
- ✅ 12.0.5 Retail
- ⏳ Future patches (planned support)
- ❌ Classic / TBC / Wrath (not supported)

### Known Issues

#### v4.0.0
- Config window may load off-screen on ultra-wide monitors (workaround: drag from edges)
- Search box doesn't clear automatically (manual clear needed)
- Preset switching doesn't animate smoothly

---

## Contributors

- **JugoBetrugoTV** - Main Developer
- Community Feedback - Feature suggestions and testing

---

## Notes

### Breaking Changes
- **v4.0.0:** All command-based config commands removed (GUI-only now)
- **v3.0.0:** Threat detection algorithm changed (scores not backwards compatible)

### Migration Guide
- **From v3.x to v4.0:** Config will auto-migrate, check presets for changes
- **From v2.x to v3.0:** Threat scores reset (rebuild profiles by playing)

---

**Latest Version:** 4.0.0
**Last Updated:** 2026-05-07

For detailed information on any version, see the respective documentation.
