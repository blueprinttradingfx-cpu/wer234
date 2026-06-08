# Strategic Idle Mecha Defense - Scoped Backlog

## EPIC-01 - Core Combat Loop
**Priority:** High

**Description:** Implement automated mecha combat, enemy spawning, wave progression, heart-limit defeat condition.

## TKT-01 - Weapon System
**Priority:** High

**Description:** Build WeaponSystem.gd with attack speed, targeting, firing cadence, and multi-shot support.

## TKT-02 - Enemy Framework
**Priority:** High

**Description:** Create enemy entities with HP, damage handling, movement, and death reporting.

## TKT-03 - Boss System
**Priority:** High

**Description:** Implement boss spawning, boss HP scaling, and stage-completion flow.

## EPIC-02 - Progression & Scaling
**Priority:** High

**Description:** Implement stage progression matrix, cycle scaling, and robot unlocks.

## TKT-04 - ProgressionManager
**Priority:** High

**Description:** Create autoload singleton for stage progression and unlock tracking.

## TKT-05 - Stage Data Loader
**Priority:** Medium

**Description:** Load and validate progression JSON configuration files.

## TKT-06 - Cycle Scaling
**Priority:** High

**Description:** Apply HP multipliers, velocity modifiers, and wave density scaling by cycle.

## TKT-07 - Robot Unlock Matrix
**Priority:** High

**Description:** Unlock and auto-equip catch-up mechas at milestone stages.

## EPIC-03 - Stage Content
**Priority:** High

**Description:** Implement 10 stage archetypes and progression mechanics.

## TKT-08 - Stage Archetypes
**Priority:** High

**Description:** Implement Entry Stream, Rush Protocol, Shielded Packets, Splitting Malware, EMP Jammer, Re-routing Logic, Regenerative Stream, Swarm Carrier, Phantom Grid, and Final Meltdown.

## TKT-09 - Data Aggregation Skip
**Priority:** Medium

**Description:** Implement wave skip multipliers and pacing controls.

## TKT-10 - 5-Minute Stage Budget
**Priority:** Medium

**Description:** Ensure stage runtime remains within 300-second target.

## EPIC-04 - Meta Progression
**Priority:** High

**Description:** Build hangar upgrades and permanent progression.

## TKT-11 - Ballistic Core
**Priority:** High

**Description:** Implement attack speed upgrades and multi-shot loader progression.

## TKT-12 - Energy Matrix
**Priority:** High

**Description:** Implement missile cooldown reduction and payload expansion upgrades.

## TKT-13 - Tactician Protocol
**Priority:** High

**Description:** Implement piercing bullets and EMP crowd-control systems.

## EPIC-05 - Roguelite Upgrades
**Priority:** Medium

**Description:** Build software card upgrade system.

## TKT-14 - Upgrade Selection UI
**Priority:** Medium

**Description:** Show upgrade choices every 20 waves.

## TKT-15 - Upgrade Effects
**Priority:** Medium

**Description:** Implement temporary run-based buffs and modifiers.

## EPIC-06 - Monetization
**Priority:** Medium

**Description:** Integrate rewarded ad flows.

## TKT-16 - Rewarded Overclock Slot
**Priority:** Medium

**Description:** Unlock premium fourth upgrade card via rewarded ad.

## TKT-17 - Upgrade Re-roll Ads
**Priority:** Medium

**Description:** Allow ad-based reroll of upgrade choices.

## EPIC-07 - UI/UX
**Priority:** High

**Description:** Build battle HUD, menus, and progression screens.

## TKT-18 - Battle HUD
**Priority:** High

**Description:** Implement stage, wave, enemy count, timer, cooldown, and power-up UI.

## TKT-19 - Main Navigation
**Priority:** Medium

**Description:** Implement Shop, Hangar, Upgrades, Battle Pass, and Leaderboard navigation.

## TKT-20 - Unlock Modal
**Priority:** Medium

**Description:** Display robot unlock rewards and progression notifications.

## EPIC-08 - Godot Data Layer
**Priority:** High

**Description:** Configuration and validation systems.

## TKT-21 - JSON Schema Integration
**Priority:** High

**Description:** Implement schema validation for configuration files.

## TKT-22 - BattleManager Loader
**Priority:** High

**Description:** Load progression matrix at startup.

## TKT-23 - Save/Load System
**Priority:** High

**Description:** Persist upgrades and progression data.

## EPIC-09 - Currency System
**Priority:** High

**Description:** Implement persistent upgrade currency.

## TKT-24 - Tech Credits Currency
**Priority:** High

**Description:** Create and manage tech credits as persistent upgrade currency.

## EPIC-10 - Detailed Enemy Behaviors
**Priority:** High

**Description:** Implement specific enemy archetype mechanics.

## TKT-25 - Shielded Packets Behavior
**Priority:** High

**Description:** Implement tank enemy behavior with shield mechanics.

## TKT-26 - Splitting Malware Behavior
**Priority:** High

**Description:** Implement enemy splitting on death mechanic.

## TKT-27 - EMP Jammer Behavior
**Priority:** High

**Description:** Implement targeting disruption mechanic.

## TKT-28 - Re-routing Logic Behavior
**Priority:** High

**Description:** Implement dynamic path changing for enemies.

## TKT-29 - Regenerative Stream Behavior
**Priority:** High

**Description:** Implement enemy regeneration mechanic.

## TKT-30 - Swarm Carrier Behavior
**Priority:** High

**Description:** Implement carrier spawn payload system.

## TKT-31 - Phantom Grid Behavior
**Priority:** High

**Description:** Implement cloaking/invisibility mechanic.

## EPIC-11 - Wave Management
**Priority:** High

**Description:** Implement wave flow and defeat conditions.

## TKT-32 - Wave Manager
**Priority:** High

**Description:** Build 100-wave stage flow system.

## TKT-33 - Heart Counter Loss System
**Priority:** High

**Description:** Implement defeat condition at 50 hearts.

## EPIC-12 - Stage Configurations
**Priority:** High

**Description:** Configure individual stage parameters.

## TKT-34 - Stage 1 Configuration
**Priority:** High

**Description:** Configure Entry Stream stage parameters.

## TKT-35 - Stage 2 Configuration
**Priority:** High

**Description:** Configure Rush Protocol stage parameters.

## TKT-36 - Stage 3-10 Configuration
**Priority:** High

**Description:** Configure remaining stages and archetypes.

## EPIC-13 - Upgrade Card Logic
**Priority:** Medium

**Description:** Implement upgrade generation and application.

## TKT-37 - Upgrade Generation Logic
**Priority:** Medium

**Description:** Implement randomized card generation system.

## EPIC-14 - Additional UI Screens
**Priority:** Medium

**Description:** Build remaining menu interfaces.

## TKT-38 - Main Menu
**Priority:** Medium

**Description:** Implement navigation and stage selection.

## TKT-39 - Hangar Screen
**Priority:** Medium

**Description:** Implement permanent upgrades interface.


Epic Development Priority Order
COMPLETED (Foundation):

EPIC-01 - Core Combat Loop ✓
EPIC-02 - Progression & Scaling ✓
EPIC-08 - Godot Data Layer ✓
EPIC-09 - Currency System ✓
EPIC-07 - UI/UX ✓
EPIC-11 - Wave Management ✓
EPIC-12 - Stage Configurations ✓
EPIC-04 - Meta Progression ✓
EPIC-03 - Stage Content ✓
EPIC-10 - Detailed Enemy Behaviors ✓
NEXT PRIORITY (Critical Path):

All critical path epics completed
MEDIUM PRIORITY (Post-Core):

8. EPIC-13 - Upgrade Card Logic (Medium, Not Started)
Required for EPIC-05
Ticket: TKT-37
9. EPIC-05 - Roguelite Upgrades (Medium, Not Started)
Depends on EPIC-13
Tickets: TKT-14, TKT-15
10. EPIC-14 - Additional UI Screens (Medium, Not Started)
Depends on EPIC-07 - COMPLETED
Tickets: TKT-38, TKT-39
11. EPIC-06 - Monetization (Medium, Not Started)
Depends on EPIC-05
Tickets: TKT-16, TKT-17