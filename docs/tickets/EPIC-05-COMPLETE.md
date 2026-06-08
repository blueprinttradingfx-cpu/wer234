# EPIC-05 - Roguelite Upgrades: Implementation Complete

**Status:** ✅ COMPLETE
**Priority:** Medium

## Description
Build software card upgrade system for run-based temporary buffs during combat.

## Implementation Overview

### System Architecture

```
Battle Flow:
  BattleManager (waves 20/40/60/80)
    ↓ upgrade_milestone_reached signal
  MainGameScene._on_upgrade_milestone_reached()
    ↓ pause battle, instantiate overlay
  SoftwareUpgradeOverlay (UI/selection)
    ↓ upgrade_selected signal
  MainGameScene._on_upgrade_selected()
    ↓ apply upgrade effect
  UpgradeEffectSystem (run-based effects)
    ↓ tick per wave, auto-deactivate when duration expires
```

### Core Components

#### 1. **UpgradeCardGenerator** (`systems/upgrade_card_generator.gd`)
- Loads upgrade card definitions from `data/upgrade_card_pool.json`
- Generates 3 random cards with weighted rarity:
  - **Common** (60%): attack_speed, damage_boost, shield_boost, etc.
  - **Rare** (30%): multi_shot, piercing, payload_expansion
  - **Legendary** (10%): overclock, tech_credit_boost
- Stage-based filtering: only shows relevant cards for current progression
- Non-repeating selection within a single draw

#### 2. **SoftwareUpgradeOverlay** (`scenes/overlays/software_upgrade_overlay.gd/tscn`)
- Control-based modal overlay (semi-transparent black background)
- Displays 3 normal upgrade cards + 1 ad-reward slot
- Card structure:
  - Title + emoji icon
  - Description text
  - SELECT or WATCH AD button
- Signals:
  - `upgrade_selected(upgrade_type: String, value: float)`
  - `re_roll_requested()`
- Free re-roll in dev mode (awaiting ad SDK integration)

**Scene Structure:**
```
SoftwareUpgradeOverlay (Control)
├── Background (ColorRect - semi-transparent)
└── Container (VBoxContainer)
    ├── TitleLabel
    ├── Spacer
    ├── CardsContainer (HBoxContainer)
    │   ├── Card1 (PanelContainer)
    │   ├── Card2 (PanelContainer)
    │   ├── Card3 (PanelContainer)
    │   └── AdCard (PanelContainer - gold tint)
    ├── Spacer
    └── ReRollButton
```

#### 3. **UpgradeEffectSystem** (`systems/upgrade_effect_system.gd`)
- Loads effect metadata from `data/upgrade_effects.json`
- Applies upgrade effects to active systems:
  - **Stat Modifiers:** attack_speed, damage_boost
  - **Temporary Buffs:** overclock (wave-based duration)
  - **Shield:** shield_boost, shield_points
  - **Weapons:** missile_cooldown, multi_shot, piercing, bullet_velocity
  - **Economy:** tech_credit_boost
- Wave-based duration tracking: automatically deactivates expired effects
- Context-aware: adjusts weapon system, mecha instance, battle manager as needed

#### 4. **BattleManager** (`systems/battle_manager.gd`)
- Milestone triggers at waves **20, 40, 60, 80**
- Emits `upgrade_milestone_reached(wave)` signal
- Provides `pause_battle()` / `resume_battle()` for overlay display
- Implements pause state transitions: ACTIVE ↔ PAUSED

#### 5. **MainGameScene** (`scenes/screens/main_gundam/main_gundam_scene.gd`)
- Listens for `BattleManager.upgrade_milestone_reached` signal
- Pauses battle, instantiates overlay, adds to scene tree
- Connects overlay signals: `upgrade_selected` → `_on_upgrade_selected`
- Applies effects via `UpgradeEffectSystem.apply_upgrade()`
- Tracks active effects, ticks them per wave via `_tick_upgrade_effects_for_wave()`
- Cleans up overlay when selection made or battle ends

### Data Files

#### `data/upgrade_card_pool.json`
```json
{
  "rarity_weights": { "common": 60, "rare": 30, "legendary": 10 },
  "cards": [
    {
      "id": "attack_speed",
      "type": "attack_speed",
      "title": "⚡ Attack Speed",
      "description": "+12% Attack Speed",
      "value": 0.12,
      "rarity": "common",
      "min_stage": 1,
      "weight": 1
    },
    // 9 more cards (damage_boost, shield_boost, missile_cooldown, multi_shot, 
    // piercing, payload_expansion, overclock, tech_credit_boost, bullet_velocity)
  ]
}
```

#### `data/upgrade_effects.json`
```json
{
  "effects": {
    "attack_speed": {
      "description": "Increase weapon fire rate for the current run.",
      "multiplier": 1.0,
      "duration_waves": 0  // Permanent for run
    },
    "overclock": {
      "description": "Temporarily boost damage and attack speed.",
      "multiplier": 1.0,
      "duration_waves": 5  // Expires after 5 waves
    },
    // 8 more effects...
  }
}
```

## User Flow

1. **Battle Starts** → Player fights enemies
2. **Wave 20 Reached** → BattleManager pauses, shows upgrade overlay
3. **Player Sees 3 Cards** → Can select one or watch ad for 4th card (overclock)
4. **Player Selects** → Effect applies immediately (or next frame)
5. **Battle Resumes** → Effect active for run (or duration_waves)
6. **Wave 40/60/80** → Repeat at each milestone
7. **Effect Expires** → Auto-removed (for overclock, etc.)

## TKT-14 & TKT-15 Acceptance Criteria

✅ **TKT-14 - Upgrade Selection UI**
- Show upgrade choices every 20 waves
- 3 random cards + 1 ad reward slot
- Card display with title, description, rarity
- Re-roll button (ad-based in production)
- Works in dev mode with free re-roll

✅ **TKT-15 - Upgrade Effects**
- Apply temporary run-based buffs
- Auto-deactivate after wave duration expires
- Support 10 effect types
- Modify weapon stats, shield, missiles, economy
- Wave-counting system for effect lifecycle

## Testing

### Unit Tests
- `test/unit/test_upgrade_card_generator.gd` - card generation and filtering
- `test/unit/test_upgrade_effect_system.gd` - effect definitions loading
- `test/unit/test_epic_05_roguelite_upgrades.gd` - integration verification

### Manual Testing
Run the game and:
1. Start a battle (Stage 1+)
2. Progress to wave 20
3. Verify overlay appears with 3 cards
4. Select a card → verify effect applies (check cooldown, damage, etc.)
5. Continue to wave 40, 60, 80
6. Test effect expiration (wave-based effects disappear after duration)

## Known Limitations

- **Ad SDK Integration:** Currently free re-roll in dev mode (awaiting real ad SDK)
- **Overclock Deactivation:** Effect multiplier properly reverted on wave expiration
- **Visual Feedback:** No on-screen visual indicators for active effects (future enhancement)
- **Effect Stacking:** Multiple same effects stack multiplicatively (intended for roguelites)

## Future Enhancements

- Visual effect indicators for active buffs
- Upgrade history/log during run
- Synergy bonuses for related upgrades
- Persistent run stats (total damage, kills, etc.)
- Effect combination multipliers

## Files Modified/Created

✅ `systems/upgrade_card_generator.gd` - Card generation
✅ `systems/upgrade_effect_system.gd` - Effect lifecycle
✅ `scenes/overlays/software_upgrade_overlay.gd` - UI logic
✅ `scenes/overlays/software_upgrade_overlay.tscn` - UI scene
✅ `data/upgrade_card_pool.json` - Card definitions
✅ `data/upgrade_effects.json` - Effect metadata
✅ `systems/battle_manager.gd` - Milestone triggers (updated)
✅ `scenes/screens/main_gundam/main_gundam_scene.gd` - Overlay integration (updated)
✅ `test/unit/test_epic_05_roguelite_upgrades.gd` - Integration tests

## Verification Checklist

- ✅ Card pool loads correctly (10 cards)
- ✅ Random selection without repeats (3 cards per selection)
- ✅ Stage filtering works (advanced cards locked until later stages)
- ✅ Effect definitions load (10 effect types)
- ✅ Overlay displays 4 cards with correct data
- ✅ Selection emits signal to main scene
- ✅ Effects apply based on weapon_system, mecha_instance, battle_manager context
- ✅ Wave-based effects auto-deactivate
- ✅ Battle pause/resume around overlay
- ✅ Overlay cleanup prevents memory leaks
- ✅ Re-roll functionality works

## Status Summary

**EPIC-05 Implementation: 100% Complete**

All features implemented and integrated:
- Card generation ✅
- Overlay UI ✅
- Effect system ✅
- Battle integration ✅
- Data persistence ✅
- Testing ✅

Ready for production integration with ad SDK.
