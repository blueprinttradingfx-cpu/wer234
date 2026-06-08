# TKT-28 - Re-routing Logic Behavior

Priority: High

Status: Completed

Description:
Implement dynamic path changing for enemies.

**Current Implementation Status:**
- EnemyUnit.gd: Added re-routing mechanics (can_re_route, re_route_interval, re_route_timer)
- EnemyUnit.gd: Added _handle_re_routing() method to handle timer
- EnemyUnit.gd: Added _change_target_position() method to randomize target
- EnemyUnit.gd: Added enable_re_routing() method to configure re-routing
- EnemyUnit.gd: Re-routing changes target position at configurable intervals
- stage_progression_matrix.json: Re-routing Logic archetype defined
- Path visualization deferred to polish phase

**Files:**
- systems/enemy_unit.gd (re-routing behavior)

**Remaining Work:**
- Path visualization (deferred to polish phase)

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
