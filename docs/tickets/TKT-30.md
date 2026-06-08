# TKT-30 - Swarm Carrier Behavior

Priority: High

Status: Completed

Description:
Implement carrier spawn payload system.

**Current Implementation Status:**
- EnemyUnit.gd: Added carrier mechanics (is_carrier, payload_capacity, payload_spawned, spawn_interval, spawn_timer, payload_hp_multiplier)
- EnemyUnit.gd: Added _handle_carrier_spawn() method to handle spawn timing
- EnemyUnit.gd: Added _spawn_payload_enemy() method to spawn smaller enemies
- EnemyUnit.gd: Added enable_carrier() method to configure carrier
- EnemyUnit.gd: Payload enemies have configurable HP multiplier
- EnemyUnit.gd: Spawns at configurable intervals up to capacity limit
- stage_progression_matrix.json: Swarm Carrier archetype defined
- Spawn visual effect deferred to polish phase

**Files:**
- systems/enemy_unit.gd (carrier behavior)

**Remaining Work:**
- Spawn visual effect (deferred to polish phase)

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
