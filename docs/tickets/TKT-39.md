# TKT-39 - Hangar Screen

Priority: Medium

Status: Not Started

Description:
Implement permanent upgrades interface.

**Current Implementation Status:**
- scenes/screens/: Directory structure exists
- ProgressionManager: Has mecha data and unlock tracking
- SaveSystem: Has upgrade level tracking
- Missing: Hangar scene, upgrade UI, mecha selection, upgrade purchase

**Files to Create:**
- scenes/screens/hangar_screen.tscn
- scenes/screens/hangar_screen.gd

**Remaining Work:**
- Create hangar screen scene
- Implement mecha selection UI (show unlocked mechas)
- Implement upgrade tree UI (Ballistic Core, Energy Matrix, Tactician Protocol)
- Add upgrade purchase buttons with tech credits cost
- Connect to EconomyManager for currency
- Connect to SaveSystem for upgrade persistence
- Style hangar with game theme

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
