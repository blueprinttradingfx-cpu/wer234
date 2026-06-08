# TKT-37 - Upgrade Generation Logic

Priority: Medium

Status: Done

Description:
Implement randomized card generation system.

**Current Implementation Status:**
- systems/upgrade_card_generator.gd created and instantiated by SoftwareUpgradeOverlay
- data/upgrade_card_pool.json added with stage-gated rarity pool and weights
- Duplicate prevention is enforced in selection
- Stage filtering is applied during generation

**Files Created:**
- systems/upgrade_card_generator.gd
- data/upgrade_card_pool.json

**Remaining Work:**
- Integrate selection into the in-game upgrade reward flow
- Add live effect application for selected software upgrades

Acceptance Criteria:
- Feature implemented
- Tested in Godot 4
- Documentation updated
