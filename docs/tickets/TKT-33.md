# TKT-33 - Heart Counter Loss System

Priority: High

Status: Completed

Description:
Implement defeat condition at 50 hearts.

**Current Implementation Status:**
- BattleManager.gd: Implemented heart counter system with current_hearts variable
- Implemented: hearts_changed signal for UI updates
- Implemented: register_enemy_reached_target() method for heart loss
- Implemented: Defeat condition at max_heart_limit (50)
- Implemented: Heart initialization in start_battle()
- stage_progression_matrix.json: global_settings.loss_heart_threshold = 50
- Missing: Heart counter UI in battle HUD (main_gundam_scene.tscn)
- Missing: Heart loss visual effect (deferred to polish)
- Missing: Enemy reaching target detection (deferred to enemy movement implementation)

**Files:**
- systems/battle_manager.gd (expanded heart system)

**Remaining Work:**
- Add heart counter UI to main_gundam_scene.tscn (deferred to UI integration)
- Implement enemy reaching target detection (deferred to enemy movement)
- Add heart loss visual effect (deferred to polish phase)

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
