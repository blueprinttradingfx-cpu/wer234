```markdown
# Comprehensive Game Design Document: Strategic Idle Mecha Defense
**Target Session Length:** 5 Minutes (300 Seconds) per Stage
**Core Defeat Condition:** Heart Counter reaches 50 (Maximum on-screen enemy limit)
**Hit Rate:** 100% (No missing)

---

## 🦾 1. Robot (Player) Configuration

The Mecha functions as a fully automated defensive engine. Base stats are engineered to clear early stages without upgrades while allowing upgrades to provide a noticeable power trip.

### Base Stats (Level 1)
*   **Base Attack Damage:** 10.0
*   **Base Attack Speed:** 2.5 attacks per second
*   **Constant Baseline Output:** 25.0 DPS

### Active Auto-Skill: Homing Missiles
*   **Trigger Mechanism:** Automated casting instantly upon cooldown completion.
*   **Damage Per Rocket:** 10.0
*   **Max Target Count:** 5 rockets per burst (50.0 total burst damage).
*   **Battery Cooldown:** 10.0 seconds (Ticks down continuously through combat and transitions).

---

## 👾 2. Enemy & Boss Entity Profiles

Normal enemy HP is kept flat to preserve the satisfying feeling of killing standard units in one hit. Scaling is achieved by manipulating physical crowding, pathing rules, and movement velocities.

### Normal Enemy Baseline
*   **HP:** 10.0 (Always dies in exactly 1 basic hit)
*   **Fail Weight:** Counts as 1 toward the 50-Heart capacity limit.

### Boss Enemy Progression
Boss HP scales deliberately to test the cumulative output of the player's weapon adjustments:
*   **Stage 1 Boss HP (Wave 100):** 290.0 (Killed in 9.6s by baseline stats)
*   **Stage 2 Boss HP (Wave 100):** 390.0 (Requires a second missile auto-cast salvo)

---

## 🗺️ 3. 10-Stage Global Progression Matrix

All stages have an absolute hard limit of **5 minutes (300 seconds)**. To handle higher enemy counts without extending stage runtimes, the game engine drops inter-wave breaks and utilizes **Data Aggregation Skips** (instantly jumping wave numbers when swarms are vaporized).

| Stage | Theme / Enemy Archetype | Wave Volume & Velocity | Data Skip Multiplier | Boss HP |
| :--- | :--- | :--- | :--- | :--- |
| **Stage 1** | **The Entry Stream:** Predictable lanes. | 10 units/wave (Base Speed) | 1x (No Skips) | 290 |
| **Stage 2** | **The Rush Protocol:** Fast runners. | 14 units/wave (+35% Speed) | 2x (Pairs skipped) | 390 |
| **Stage 3** | **Shielded Packets:** Frontline tanks. | 16 units/wave (Variable Speed) | 2x | 550 |
| **Stage 4** | **Splitting Malware:** Divide on death. | 12 base $\rightarrow$ 24 split tickers | 3x | 700 |
| **Stage 5** | **The EMP Jammer:** Disables targeters. | 18 units/wave (+50% Speed) | 3x | 950 |
| **Stage 6** | **Re-routing Logic:** Alter paths mid-run. | 20 units/wave (+60% Speed) | 4x | 1,200 |
| **Stage 7** | **Regenerative Stream:** Missing kills heals. | 22 units/wave (Base Speed) | 4x | 1,600 |
| **Stage 8** | **Swarm Carrier:** Drops payload inward. | 5 Carriers $\rightarrow$ 40 Tickers | 5x | 2,200 |
| **Stage 9** | **The Phantom Grid:** Intermittent cloaking. | 25 units/wave (+75% Speed) | 5x | 3,000 |
| **Stage 10**| **The Final Meltdown:** Absolute overload. | 30 units/wave (+100% Speed) | 6x (Hyper Skips) | 4,500 |

---

## 🛠️ 4. Overhaul Hangar (Permanent Metagame Upgrades)

Purchased in the main menu between live runs using Tech Credits salvaged from destroyed hostiles.

### Module 1: The Ballistic Core
*   **Chassis Calibrator:** Upgrades Base Attack Speed from 2.5 up to 8.0 attacks per second.
*   **Multi-Shot Loader:** Dictates a fixed, sequential multi-shot firing cadence rather than a random chance.
    *   *Base Unlocked:* Every 3rd sequential shot triggers a **Dual-Shot Array** (Targets 2 enemies at once).
    *   *Max Level Upgraded:* Every bullet cycle splits into a multi-directional **Triple-Shot Array**.

### Module 2: The Energy Matrix
*   **Processor Overclock:** Permanently reduces Homing Missile auto-cast battery cooldown from 10.0 seconds down to 4.0 seconds.
*   **Payload Expansion:** Scales the number of rockets deployed per automated salvo from 5 up to 15 rockets.

### Module 3: Tactician Protocol (Offensive Crowd Control)
*   **3A: Kinetic Piercing Barrel:** Shots pass cleanly through hostiles.
    *   *Level 1:* Bullets pierce +1 target (kills up to 2 enemies per shot).
    *   *Level 2 (Max):* Bullets pierce +2 targets (kills up to 3 enemies per shot). Excellent counter to Stage 3 shield arrays.
*   **3B: EMP Disruption Grid:** Adds utility lightning directly to the weapon configuration. Every fixed sequence of shots chains an EMP shock to **3 to 5 adjacent units**, freezing them completely for **1.5 to 2.5 seconds** to prevent Heart Limit overflow.

---

## 📈 5. Software Upgrades & Rewarded Ad Monetization

Software upgrades act as rogue-lite, mid-run temporary patch cards that pop up every **20 waves** (Waves 20, 40, 60, 80). The game briefly enters slow-motion, offering a selection interface.


```

┌─────────────────────────────────────────────────────────────────────────┐
│                    [SOFTWARE MATRIX UPGRADE DETECTED]                   │
│                                                                         │
│   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐   │
│   │    CARD 1     │   │    CARD 2     │   │    CARD 3     │   │  ⚡ SLOT 4 ⚡  │   │
│   │               │   │               │   │               │   │  [REWARD AD]  │   │
│   │  +15% Attack  │   │ -0.5s Missile │   │  +10% Bullet  │   │               │   │
│   │     Speed     │   │   Cooldown    │   │   Velocity    │   │ OVERCLOCK CAM │   │
│   │               │   │               │   │               │   │ (Double DPS)  │   │
│   └───────────────┘   └───────────────┘   └───────────────┘   └───────────────┘   │
│                                                                         │
│                         [🎬 WATCH AD TO RE-ROLL OPTIONS]                 │
└─────────────────────────────────────────────────────────────────────────┘

```

### Monetization Placements:
1.  **The Overclock 4th Slot:** A high-tier, glowing 4th card option appears on the choice screen. Watching a 30-second video ad unlocks temporary, highly volatile power spikes (e.g., *Infinite Missile Barrage for the next 5 waves* or *+100% Fire Rate for this run*).
2.  **The Matrix Re-Roll Buffer:** If a player draws 3 common cards that do not match their currently active setup strategy, they can watch a rewarded ad to completely refresh the 3 random options.

```

---

# Main Scene Screen
┌───────────────────────────────────────────────────────────────────────────┐
│ Player Name                      [STAGE 11]  [WAVE 11/100]                │
│ ☠️ Alive Enemies: 30/50 ⏱️ CLOCK: 04:52                                  │
│───────────────────────────────────────────────────────────────────────────│
|                                              Floating Nav Settings: [⏸️] |
│ ┌───────────────────────────────────────────────────────────────────────┐ │
│ │ (Spawn Boundary) <- 👾 👾 👾 👾 👾 👾 👾 👾 👾 👾   👾 👾 👾   │ │
│ │  |                                                                👾 │ │
│ │  v                     						                      👾 │ │
│ │ 👾                       				                          👾 │ │
│ │ 👾                     				                              👾 │ │
│ │ 👾                  ┌─────────────────────┐                        👾 │ │
│ │ 👾                  │   ╭─────────────╮   │                        👾 │ │
│ │ 👾                  │   │   🛡️ 🛡️ 🛡️  │   │                        👾 │ │
│ │ 👾                  │   │    🤖      │   │                        👾 │ │
│ │ 👾                  │   │   MECHA     │   │                        👾 │ │
│ │ 👾                  │   │   CORE      │   │                        👾 │ │
│ │ 👾                  │   │   🛡️ 🛡️ 🛡️  │   │                         👾 │ │
│ │ 👾                  │   ╰─────────────╯   │                        👾 │ │
│ │ 👾                  └─────────────────────┘                        👾 │ │
│ │ 👾                                                                 👾 │ │
│ │ 👾                                                                 👾 │ │
│ │ 👾 👾 👾 👾 👾 👾 👾 👾 👾 👾 👾 👾 👾 👾 👾 👾 👾  👾 👾   │ │
│ └───────────────────────────────────────────────────────────────────────┘ │
│───────────────────────────────────────────────────────────────────────────│
│ BATTERY Cooldown UI Effect:      ▰▰▰▰▰▰▰▰▱▱▱▱                    │
| Software Power Ups: Locked Buttons:                                       |
| ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────┐ │
│ │ ⚡     │ │ 🎯      │ │ 🔋      │ │ 💨      │ │ 🧬      │ │ [🔥 RUN]  │ │
│ │ AtkSpd  │ │ Pierce  │ │ Cooldown│ │ MoveSpd │ │ Matrix  │ │ OVERCLOCK │ │
│ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └───────────┘ │
│───────────────────────────────────────────────────────────────────────────│
| ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────┐ │
│ │ ⚡     │ │ 🎯      │ │ 🔋      │ │ 💨      │ │ 🧬      │ │ [🔥 RUN]  │ │
│ │ Shop    │ │ Hangar    │ │ Upgrades    │ │ Battle Pass    │ │ Leaderboard    │ │   < -- Main Nav HeaderLayout
│ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └───────────┘ │
└───────────────────────────────────────────────────────────────────────────┘

# Weapon System

Here is a robust, modular Godot 4 GDScript component (`WeaponSystem.gd`) that implements the sequential multi-shot behavior. It hooks directly into the core dataset we established, advancing a firing index with every automated shot and parsing your custom upgrade tiers from the Overhaul Hangar.

### 🛠️ Firing Engine Component (`WeaponSystem.gd`)

```gdscript
extends Node2D
class_name WeaponSystem

# --- Signals for UI/VFX Hookups ---
signal enemy_shot_fired(projectile_data: Dictionary)

# --- Configuration References (Injected by BattleManager) ---
var base_damage: float = 10.0
var attack_speed: float = 2.5 # Attacks per second

# --- Multi-Shot Upgrade State ---
# Level 0: Pure Single Shot
# Level 1: [Single] -> [Single] -> [Dual]
# Level 2: [Single] -> [Dual] -> [Triple]
var multi_shot_level: int = 0 

# --- Internal Core Automation State ---
var shot_sequence_index: int = 0
@onready var fire_timer: Timer = $FireTimer

func _ready() -> void:
	setup_fire_timer()

func setup_fire_timer() -> void:
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	update_weapon_speed()

## Call this whenever attack speed upgrades are purchased or applied
func update_weapon_speed() -> void:
	if attack_speed > 0:
		fire_timer.start(1.0 / attack_speed)
	else:
		fire_timer.stop()

func _on_fire_timer_timeout() -> void:
	var target_enemies = acquire_targets()
	if target_enemies.is_empty():
		return # Idle state: No enemies within screen boundaries
		
	execute_firing_sequence(target_enemies)

## Scans the screen context to return valid targets sorted by closest distance
func acquire_targets() -> Array[Node2D]:
	var targets: Array[Node2D] = []
	var live_enemies = get_tree().get_nodes_in_group("enemies")
	
	# Early exit if the screen board is completely clear
	if live_enemies.is_empty():
		return targets
		
	# Sort enemies radially by proximity to the center mecha positioning
	live_enemies.sort_custom(func(a, b): 
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	for enemy in live_enemies:
		if is_instance_valid(enemy):
			targets.append(enemy)
	return targets

## Evaluates the strict sequential cadence rules based on Upgrade Level
func execute_firing_sequence(available_targets: Array[Node2D]) -> void:
	var bullet_count: int = 1 # Default Level 0 Baseline
	
	match multi_shot_level:
		1:
			# Sequence rhythm: Single (0) -> Single (1) -> Dual (2)
			if shot_sequence_index == 2:
				bullet_count = 2
			else:
				bullet_count = 1
			shot_sequence_index = (shot_sequence_index + 1) % 3
			
		2:
			# Sequence rhythm: Single (0) -> Dual (1) -> Triple (2)
			if shot_sequence_index == 1:
				bullet_count = 2
			elif shot_sequence_index == 2:
				bullet_count = 3
			else:
				bullet_count = 1
			shot_sequence_index = (shot_sequence_index + 1) % 3
			
		_:
			# Level 0 default behavior: Flat loop, no indexing calculation needed
			bullet_count = 1
			
	# Deploy the calculated bullet array into target entities
	deploy_projectiles(bullet_count, available_targets)

## Distributes shots across distinct targets to resolve local crowd density
func deploy_projectiles(count: int, targets: Array[Node2D]) -> void:
	for i in range(count):
		# If density is lower than weapon capability, dump remaining payload into the primary target
		var target = targets[i] if i < targets.size() else targets[0]
		
		if is_instance_valid(target):
			# Because hit rate is 100%, we execute damage immediately
			# (Pierce / EMP logic can hook directly into the targeted enemy context here)
			if target.has_method("take_damage"):
				target.take_damage(base_damage)
				
			# Emit tracking payload for visual sprite/laser instancing components
			enemy_shot_fired.emit({
				"target_position": target.global_position,
				"damage": base_damage,
				"bullet_index": i
			})

```

---

### 👾 Target Enemy Setup (`EnemyUnit.gd`)

To ensure the 100% hit rate system functions correctly without breaking, your enemy instances need a matching `take_damage` receiver method that safely passes death data back up to the `BattleManager` node tree.

```gdscript
extends CharacterBody2D
class_name EnemyUnit

@export var max_hp: float = 10.0
var current_hp: float = 10.0

@onready var battle_manager = get_node_or_null("/root/BattleManager")

func _ready() -> void:
	add_to_group("enemies")
	current_hp = max_hp

func take_damage(amount: float) -> void:
	current_hp -= amount
	if current_hp <= 0:
		execute_destruction()

func execute_destruction() -> void:
	# Handshake validation to prevent dual-frame reporting errors
	remove_from_group("enemies")
	
	if battle_manager and battle_manager.has_method("register_enemy_destruction"):
		battle_manager.register_enemy_destruction()
		
	# Trigger local explosion visual systems here before freeing memory
	queue_free()

```