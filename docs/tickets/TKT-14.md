# TKT-14 - Upgrade Selection UI

Priority: Medium

Status: In Progress

Description:
Show upgrade choices every 20 waves.

**Current Implementation Status:**
- BattleManager now emits upgrade milestones at 20/40/60/80
- `main_gundam_scene.gd` displays the `SoftwareUpgradeOverlay` during milestone pauses
- Card selection logic wired to upgrade effect application

**Files to Create:**
- scenes/overlays/upgrade_selection.tscn
- scenes/overlays/upgrade_selection.gd

**Remaining Work:**
- Create upgrade selection UI scene
- Add wave milestone triggers in BattleManager
- Implement card selection logic
- Pause battle during selection
- Resume battle after selection

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
