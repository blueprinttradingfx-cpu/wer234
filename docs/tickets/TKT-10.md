# TKT-10 - 5-Minute Stage Budget

Priority: Medium

Status: Completed

Description:
Ensure stage runtime remains within 300-second target.

**Current Implementation Status:**
- stage_progression_matrix.json: global_settings.total_stage_time_budget_seconds = 300.0
- BattleManager.gd: Has stage_time_remaining timer and stage_time_changed signal
- BattleManager.gd: Timer counts down and triggers victory when exhausted
- Wave pacing implemented via spawn interval calculation based on enemies_per_wave
- Wave advancement happens after each spawn timer timeout
- Current implementation: 100 waves with dynamic enemy count scaling

**Files:**
- systems/battle_manager.gd (timer and pacing logic)
- data/stage_progression_matrix.json (time budget configuration)

**Remaining Work:**
- Dynamic adjustment based on performance (deferred to polish phase)
- Fine-tuning of spawn rates (deferred to playtesting phase)

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
