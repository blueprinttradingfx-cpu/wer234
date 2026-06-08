# TKT-15 - Upgrade Effects

Priority: Medium

Status: In Progress

Description:
Implement temporary run-based buffs and modifiers.

**Current Implementation Status:**
- Added effect definitions in `data/upgrade_effects.json`
- Added runtime effect application in `systems/upgrade_effect_system.gd`
- Centralized upgrade effect application in `main_gundam_scene.gd`
- Overclock effects are tracked per wave and expire after the configured duration

**Files to Create:**
- systems/upgrade_effect_system.gd
- data/upgrade_effects.json

**Remaining Work:**
- Define upgrade effect types (damage boost, speed boost, etc.)
- Create effect application system
- Track active run-based buffs
- Apply effects to WeaponSystem and MechaEntity
- Clear effects on run end

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
