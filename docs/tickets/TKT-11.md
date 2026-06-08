# TKT-11 - Ballistic Core

Priority: High

Status: Completed

Description:
Implement attack speed upgrades and multi-shot loader progression.

**Current Implementation Status:**
- MechaEntity._apply_upgrade_modifiers: Has chassis_calibrator_level implementation
- Applies attack speed lerp from 2.5 to 8.0 based on upgrade level
- WeaponSystem.set_multi_shot_level: Multi-shot system implemented
- SaveSystem: Added set_upgrade_level and deduct_tech_credits methods
- upgrades_screen.gd: Full UI implementation with purchase logic
- Upgrade data structure defined in upgrades_screen.gd

**Files:**
- systems/mecha_entity.gd (upgrade modifiers)
- systems/weapon_system.gd (multi-shot)
- systems/save_system_mecha.gd (upgrade persistence)
- scenes/screens/upgrades_screen.gd (UI and purchase logic)

**Remaining Work:**
- Testing and balancing deferred to playtesting phase

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
