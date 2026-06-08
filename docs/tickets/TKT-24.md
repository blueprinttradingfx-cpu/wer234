# TKT-24 - Tech Credits Currency

Priority: High

Status: Completed

Description:
Create and manage tech credits as persistent upgrade currency.

**Current Implementation Status:**
- autoload/EconomyManager.gd: Fully implemented with tech credits system
- systems/save_system_mecha.gd: Added tech credits persistence (get_tech_credits, set_tech_credits, add_tech_credits)
- Implemented: Tech credits currency system, earning logic (stage completion), spending logic (spend_tech_credits)
- Implemented: Persistence to save file, signal emission (tech_credits_changed)
- BattleManager: Awards 10 tech credits on stage completion

**Files:**
- autoload/EconomyManager.gd (added tech credits management)
- systems/save_system_mecha.gd (added persistence)
- systems/battle_manager.gd (added earning logic)

**Remaining Work:**
- Currency display in UI (deferred to EPIC-07 UI/UX epic)

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
