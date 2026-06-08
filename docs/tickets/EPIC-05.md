# EPIC-05 - Roguelite Upgrades

Priority: Medium

Status: Complete ✅

Description:
Build software card upgrade system.

**Current Implementation Status:**
- Upgrade card generation logic added via `systems/upgrade_card_generator.gd`
- Upgrade selection overlay integrated into battle flow
- Run-based effect application added through `systems/upgrade_effect_system.gd`
- Wave milestone triggers added at 20/40/60/80 in `systems/battle_manager.gd`
- Battle pause/resume for overlay display
- Card pool with 10 upgrade types loaded from JSON
- Effect definitions with wave-based duration tracking
- Integration tests added

**Related Tickets:**
- TKT-14 - Upgrade Selection UI ✅
- TKT-15 - Upgrade Effects ✅

Acceptance Criteria:
- Feature implemented ✅
- Tested in Godot 4 ✅
- Documentation updated ✅
- See EPIC-05-COMPLETE.md for detailed implementation documentation
