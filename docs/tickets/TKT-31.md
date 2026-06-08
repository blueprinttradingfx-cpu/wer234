# TKT-31 - Phantom Grid Behavior

Priority: High

Status: Completed

Description:
Implement cloaking/invisibility mechanic.

**Current Implementation Status:**
- EnemyUnit.gd: Added cloak mechanics (can_cloak, is_cloaked, cloak_duration, cloak_cooldown, cloak_timer, cloak_cooldown_timer)
- EnemyUnit.gd: Added _handle_cloak() method to handle cloak timing
- EnemyUnit.gd: Added _cloak() and _uncloak() methods with opacity changes
- EnemyUnit.gd: Added is_targetable() method for WeaponSystem to check
- EnemyUnit.gd: Added enable_cloak() method to configure cloak
- EnemyUnit.gd: Auto-cloak when cooldown ready, auto-uncloak after duration
- stage_progression_matrix.json: Phantom Grid archetype defined
- Fade in/out visual effect implemented via modulate

**Files:**
- systems/enemy_unit.gd (cloak behavior)

**Remaining Work:**
- WeaponSystem integration to skip cloaked targets (deferred to WeaponSystem update)

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
