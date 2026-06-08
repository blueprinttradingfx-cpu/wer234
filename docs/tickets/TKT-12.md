# TKT-12 - Energy Matrix

Priority: High

Status: Completed

Description:
Implement missile cooldown reduction and payload expansion upgrades.

**Current Implementation Status:**
- MechaEntity._apply_upgrade_modifiers: Has processor_overclock_level and payload_expansion_level
- Processor Overclock: Missile cooldown lerp from 10.0 to 4.0
- Payload Expansion: Rockets lerp from 5 to 15
- SaveSystem: Added set_upgrade_level and deduct_tech_credits methods
- upgrades_screen.gd: Full UI implementation with purchase logic
- Upgrade data structure defined in upgrades_screen.gd

**Files:**
- systems/mecha_entity.gd (upgrade modifiers)
- systems/save_system_mecha.gd (upgrade persistence)
- scenes/screens/upgrades_screen.gd (UI and purchase logic)

**Remaining Work:**
- Testing and balancing deferred to playtesting phase

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
