# TKT-13 - Tactician Protocol

Priority: High

Status: Completed

Description:
Implement piercing bullets and EMP crowd-control systems.

**Current Implementation Status:**
- WeaponSystem: Added piercing_level variable and set_piercing_level() method
- WeaponSystem: Implemented _apply_damage_with_piercing() - bullets damage enemies behind target
- WeaponSystem: Piercing does reduced damage (50%) to pierced enemies
- MechaEntity: Added _emp_level variable and integration from SaveSystem
- MechaEntity: Implemented _apply_emp_effect() - missiles stun nearby enemies
- MechaEntity: EMP radius increases with level (100 + level * 50)
- MechaEntity: EMP stun duration increases with level (1.0 + level * 0.5 seconds)
- Status effect system: Fallback to speed_modifier if apply_stun not available
- SaveSystem: Upgrade persistence already implemented

**Files:**
- systems/weapon_system.gd (piercing logic)
- systems/mecha_entity.gd (EMP crowd control)
- systems/save_system_mecha.gd (upgrade persistence)
- scenes/screens/upgrades_screen.gd (UI and purchase logic)

**Remaining Work:**
- Testing and balancing deferred to playtesting phase
- Visual effects for piercing and EMP deferred to polish phase

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
