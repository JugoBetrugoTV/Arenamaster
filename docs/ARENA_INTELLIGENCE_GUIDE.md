# Arenamaster Arena Intelligence System - Complete Guide

## Overview

The Arena Intelligence System is a comprehensive real-time analytics and prediction engine for World of Warcraft PvP arenas. It provides advanced tracking of diminishing returns (DR), interrupt predictions, threat assessment, and combat statistics.

## System Architecture

### Core Modules

1. **arenaintelligence.lua** - Core engine
   - DR tracking system with 6 CC chains
   - Interrupt prediction engine with confidence scoring
   - Combat analytics for damage, healing, CC tracking
   - Advanced multi-factor threat algorithm

2. **arenaintelligence-ui.lua** - Visual display
   - DR indicators on enemy frames
   - Threat level bars with color coding
   - Interrupt prediction panels
   - Real-time analytics display

3. **arenaintelligence-summary.lua** - Intelligence reporting
   - Match statistics aggregation
   - Per-opponent intelligence summaries
   - Efficiency calculations
   - Formatted report generation

4. **arenaintelligence-commands.lua** - User interface
   - `/ai` command system with subcommands
   - DR status display
   - Threat assessment reporting
   - Interrupt predictions with confidence
   - Match statistics output

5. **arenaintelligence-config.lua** - Configuration management
   - 30+ configurable options
   - Real-time setting updates
   - Performance mode selection
   - Integration with AceConfigDialog

6. **arenaintelligence-performance.lua** - Optimization
   - Memory usage monitoring
   - Update rate tracking
   - Automatic optimization
   - Performance profiles (streamer, competitive, detail, lowend)

7. **opponent-spec-detection.lua** - Spec detection
   - WoW 12.0.5 API-compliant spec detection
   - Opponent spec caching
   - Fallback combat pattern analysis

## Features

### 1. Diminishing Returns (DR) Tracking

**Chains Tracked:**
- **Stun** (bash, asphyxiate, hammer_of_justice)
- **Silence** (interrupt, counterspell, kick)
- **Root** (frozen, snare, entangle)
- **Disorient** (polymorph, hex, ring_of_peace)
- **Fear** (horror, mortal_coil)
- **Slow** (chill, haste_slow)

**Reduction Progression:**
- 1st application: 100% (full effect)
- 2nd application: 75% effectiveness
- 3rd application: 50% effectiveness
- 4th application: 25% effectiveness
- 5th+ application: Immune

**Commands:**
```
/ai dr              - Show all opponent DR status
/ai dr arena1       - Show specific unit DR
```

### 2. Interrupt Prediction Engine

**Features:**
- Tracks interrupt cooldown patterns per opponent
- Learns from recent usage history (last 10 casts)
- Calculates confidence scoring based on pattern consistency
- Estimates time until availability

**Supported Abilities:**
- Kick (15s cooldown)
- Counterspell (24s cooldown)
- Pummel (6s cooldown)
- Spellsteal (10s cooldown)
- Silence (60s cooldown)
- Stun (8s cooldown)

**Confidence Calculation:**
- Based on consistency of usage intervals
- 0.5 = 50% confidence (no data)
- 1.0 = 100% confidence (very consistent pattern)

**Commands:**
```
/ai interrupt       - Show all opponent interrupt predictions
/ai int            - Shorthand
```

### 3. Threat Assessment

**Factors (Total = 100%):**
- **Health** (30%) - Opponent's current health percentage
- **Offensive CDs** (25%) - Active offensive cooldowns/buffs
- **Defensive CDs** (20%) - Whether defensive CDs are active
- **Class Damage Potential** (15%) - Inherent class damage scaling
- **Distance/Position** (10%) - Proximity to player

**Threat Levels:**
- 75%+ = Critical (bright red) - Top priority
- 50-75% = High (orange) - Significant threat
- 25-50% = Medium (yellow) - Monitor closely
- 0-25% = Low (green) - Lower priority

**Commands:**
```
/ai threat         - Show all opponent threat assessments
```

### 4. Combat Analytics

**Tracked Metrics:**
- Damage Dealt / DPS
- Damage Taken
- Healing Done / HPS
- Crowd Control Applications
- Crowd Control Received
- Interrupts Applied
- Dispels Applied
- Combat Efficiency (output vs. damage taken)

**Storage:**
- Up to 1000 combat events per match
- Timestamp precision
- Source, target, spell, damage tracking

**Commands:**
```
/ai stats          - Show current match stats
/ai stats opponents - Show all opponent intelligence
/ai stats report   - Generate comprehensive match report
```

### 5. Configuration Options

**DR Settings:**
- Enable/disable tracking
- Show indicators on frames
- Warning threshold (0-100%)
- Reset time (5-30 seconds)

**Threat Settings:**
- Enable/disable detection
- Show threat bars
- Update frequency (0.1-2.0 seconds)
- Individual factor weights

**Interrupt Settings:**
- Enable prediction engine
- Show predictions on frames
- Minimum confidence threshold
- Learning enabled/disabled
- Pattern history size

**Analytics Settings:**
- Enable/disable tracking
- Toggle damage/healing/CC/dispel tracking
- Maximum event storage
- Efficiency calculations

**Display Settings:**
- Show DR/threat/interrupts on frames
- Frame opacity control
- Analytics panel visibility
- Frame positioning

### 6. Performance Optimization

**Performance Modes:**
- **Lightweight**: Minimal CPU usage, DR only
- **Balanced**: Normal operation with all systems
- **Detailed**: Maximum detail, high CPU usage

**Performance Profiles:**
- **Streamer**: Optimized for streaming (low CPU)
- **Competitive**: Balanced for PvP
- **Detail**: Maximum information for analysis
- **Lowend**: For lower-end machines

**Automatic Optimization:**
- Memory usage monitoring
- Event trimming when exceeding 50MB
- Update rate throttling
- Automatic mode switching

**Commands:**
```
/ai perf lightweight    - Switch to lightweight mode
/ai perf balanced       - Switch to balanced mode
/ai perf detailed       - Switch to detailed mode
```

## Usage Examples

### Basic Setup
1. Enter arena, system auto-initializes
2. Frames display DR, threat, and interrupt predictions in real-time
3. Use `/ai stats` to check current match statistics

### During Match
```
/ai dr                          - Check all opponent DR status
/ai threat                      - Assess current threat levels
/ai interrupt                   - Check interrupt availability
```

### After Match
```
/ai stats report                - View comprehensive match analysis
/ai stats opponents             - See opponent breakdowns
```

### Configuration
1. Open WoW Settings → Addons → Arenamaster → Arena Intelligence
2. Adjust DR thresholds, threat weights, display options
3. Select performance mode based on your system
4. All changes apply immediately

## API Reference

### Core Module (ArenaIntelligence)

```lua
-- DR Functions
ArenaIntelligence:ApplyCCEffect(targetUnit, effectType, chainType)
ArenaIntelligence:GetDRStatus(targetUnit, chainType)
ArenaIntelligence:UpdateDRStatus()

-- Interrupt Functions
ArenaIntelligence:RecordInterruptUsage(unit, spellName)
ArenaIntelligence:PredictInterruptAvailability(unit, spellName)

-- Analytics Functions
ArenaIntelligence:StartMatchAnalytics()
ArenaIntelligence:LogCombatEvent(eventType, source, target, spell, amount)
ArenaIntelligence:GetMatchStats()
ArenaIntelligence:GetDPS()
ArenaIntelligence:GetHPS()

-- Threat Functions
ArenaIntelligence:CalculateAdvancedThreat(unit)
```

### UI Module (ArenaIntelligenceUI)

```lua
ArenaIntelligenceUI:CreateDRIndicator(parent, unit)
ArenaIntelligenceUI:UpdateDRDisplay()
ArenaIntelligenceUI:CreateThreatIndicator(parent, unit)
ArenaIntelligenceUI:UpdateThreatDisplay()
ArenaIntelligenceUI:CreateInterruptPrediction(parent, unit)
ArenaIntelligenceUI:UpdateInterruptDisplay()
```

### Summary Module (ArenaIntelligenceSummary)

```lua
ArenaIntelligenceSummary:GetMatchIntelligenceSummary()
ArenaIntelligenceSummary:GetOpponentIntelligence(unit)
ArenaIntelligenceSummary:PrintMatchSummary()
ArenaIntelligenceSummary:PrintOpponentSummary(unit)
ArenaIntelligenceSummary:PrintAllOpponentsSummary()
```

## Performance Considerations

### Memory Usage
- Base: ~5MB
- Per 100 events: ~0.1MB
- Typical match (500 events): ~5.5MB

### CPU Impact
- DR tracking: Minimal
- Threat calculation: Low (0.5-1.0ms per update)
- Interrupt tracking: Minimal
- Analytics: Low-Medium (depends on event volume)

### Optimization Tips
1. Use lightweight mode for streaming
2. Disable analytics if not needed
3. Increase update frequencies if CPU available
4. Use appropriate performance profile

## Troubleshooting

**DR not updating?**
- Check if DR tracking is enabled in config
- Ensure opponent is in arena
- Try `/reload`

**Interrupts always showing as available?**
- Need to play multiple matches for learning
- Check confidence threshold in config
- Ensure interrupt tracking is enabled

**High memory usage?**
- Switch to lightweight performance mode
- Reduce event storage limit
- Disable analytics
- Restart match with `/reload`

**Threat scores seem wrong?**
- Check threat factor weights in config
- Ensure all factors sum to 100%
- Verify opponent health data is updating

## Advanced Configuration

### Custom Threat Weights

Edit `arenaintelligence-config.lua` or use commands to adjust:
```
Health Weight: 0-50%
Offensive Weight: 0-50%
Defensive Weight: 0-50%
Class Weight: 0-50%
Distance Weight: 0-50%
```

Weights should sum to 100% for normalized scores.

### Learning System

Interrupt learning requires:
- 3+ data points for confidence calculation
- Consistent interrupt usage patterns
- Learning enabled in config

## Debug Mode

Enable debug output:
1. `/am debug` (from main addon)
2. Or set `debugMode = true` in config
3. View detailed logs in chat

## File Structure

```
modules/
├── arenaintelligence.lua           (Core system)
├── arenaintelligence-ui.lua        (Visual display)
├── arenaintelligence-summary.lua   (Intelligence reports)
├── arenaintelligence-commands.lua  (User commands)
├── arenaintelligence-config.lua    (Configuration)
├── arenaintelligence-performance.lua (Optimization)
└── opponent-spec-detection.lua     (Spec detection)
```

## Updates & Changelog

### v1.0.0 - Arena Intelligence Launch
- Initial release with full system
- DR tracking for 6 CC chains
- Interrupt prediction with learning
- Multi-factor threat algorithm
- Real-time analytics
- Performance optimization
- Full AceConfig integration

## Support & Feedback

For issues or feature requests:
- Check debug output (`/am debug`)
- Review Arena Intelligence Guide
- Verify settings in AceConfig
- Test with lightweight mode first

## License

Part of Arenamaster addon for World of Warcraft 12.0.5 Retail.
