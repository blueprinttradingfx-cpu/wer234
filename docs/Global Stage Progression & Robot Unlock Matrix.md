To integrate this multi-cycle scaling system into your Godot 4 engine, you need two distinct data files: one for the **Global Stage Progression** (which defines the enemy multipliers, cycle shifts, and boss walls) and one for the **Robot Unlock Matrix** (which defines the free mechas handed to the player to bypass those walls).

Here are the complete JSON configurations and the clean architecture to load, parse, and apply them in your project.

---

## 💾 1. The Configuration JSON Files

### File 1: `stage_progression_matrix.json`

This file maps out the stages into **Cycles**. Each cycle increases enemy health, introduces a new mechanic archetype, and scales the final Boss HP.

```json
{
  "global_settings": {
    "total_stage_time_budget_seconds": 300.0,
    "loss_heart_threshold": 50
  },
  "cycles": [
    {
      "cycle_id": 1,
      "stage_range": [1, 10],
      "enemy_base_hp_multiplier": 1.0,
      "stages": [
        { "stage_id": 1, "stage_name": "Database Sector 0-Alpha", "archetype": "The Entry Stream", "boss_hp": 290.0, "enemies_per_wave": 10, "velocity_modifier": 1.0, "data_skip_multiplier": 1 },
        { "stage_id": 10, "stage_name": "Database Sector 9-Alpha", "archetype": "The Final Meltdown", "boss_hp": 4500.0, "enemies_per_wave": 30, "velocity_modifier": 2.0, "data_skip_multiplier": 6 }
      ]
    },
    {
      "cycle_id": 2,
      "stage_range": [11, 20],
      "enemy_base_hp_multiplier": 2.0,
      "stages": [
        { "stage_id": 11, "stage_name": "Database Sector 0-Beta", "archetype": "The Rush Protocol", "boss_hp": 1200.0, "enemies_per_wave": 14, "velocity_modifier": 1.20, "data_skip_multiplier": 2 },
        { "stage_id": 20, "stage_name": "Database Sector 9-Beta", "archetype": "The Final Meltdown", "boss_hp": 8000.0, "enemies_per_wave": 34, "velocity_modifier": 2.20, "data_skip_multiplier": 6 }
      ]
    },
    {
      "cycle_id": 3,
      "stage_range": [21, 30],
      "enemy_base_hp_multiplier": 4.0,
      "stages": [
        { "stage_id": 21, "stage_name": "Database Sector 0-Gamma", "archetype": "Shielded Packets", "boss_hp": 3000.0, "enemies_per_wave": 16, "velocity_modifier": 1.40, "data_skip_multiplier": 2 },
        { "stage_id": 30, "stage_name": "Database Sector 9-Gamma", "archetype": "The Final Meltdown", "boss_hp": 15000.0, "enemies_per_wave": 38, "velocity_modifier": 2.40, "data_skip_multiplier": 6 }
      ]
    }
  ]
}

```

*(Note: For brevity, this payload maps the boundary stages of each cycle; expand the lists smoothly from 1 to 30 in your production file).*

### File 2: `robot_unlock_catalog.json`

This file defines the stats of the free catch-up mechas and logs the exact stage milestones required to inject them into the player's garage.

```json
{
  "mechas": [
    {
      "mecha_id": "mecha_unit_alpha_base",
      "name": "Unit Alpha (Baseline)",
      "unlock_requirement": { "type": "stage_reached", "value": 1 },
      "base_stats": { "attack_damage": 10.0, "attack_speed": 2.5 },
      "skill": { "name": "Homing Missiles", "total_damage": 50.0, "cooldown": 10.0 }
    },
    {
      "mecha_id": "mecha_unit_beta_gatling",
      "name": "Unit Beta (Gatling Core)",
      "unlock_requirement": { "type": "stage_failed_or_reached", "value": 11 },
      "base_stats": { "attack_damage": 20.0, "attack_speed": 2.0 },
      "skill": { "name": "Plasma Flurry", "total_damage": 100.0, "cooldown": 8.0 }
    },
    {
      "mecha_id": "mecha_unit_gamma_laser",
      "name": "Unit Gamma (Laser Core)",
      "unlock_requirement": { "type": "stage_failed_or_reached", "value": 21 },
      "base_stats": { "attack_damage": 40.0, "attack_speed": 1.5 },
      "skill": { "name": "Mega Particle Beam", "total_damage": 250.0, "cooldown": 7.5 }
    }
  ]
}

```

---

## 🛠️ 2. Godot 4 Architectural Implementation

To implement this progression engine, create a global autoload state singleton called `ProgressionManager.gd`. It will handle loading data, managing the active robot selection, tracking unlocks, and applying the multipliers to incoming enemy waves.

### Step A: The Core Singleton Engine (`ProgressionManager.gd`)

Create this file and register it under **Project Settings -> Autoload** as `ProgressionManager`.

```gdscript
extends Node

# --- Global Tracking State ---
var current_player_stage: int = 1
var unlocked_mecha_ids: Array[String] = ["mecha_unit_alpha_base"]
var active_mecha_id: String = "mecha_unit_alpha_base"

# --- Cached Databases ---
var stage_db: Dictionary = {}
var robot_db: Dictionary = {}

func _ready() -> void:
	load_databases()

func load_databases() -> void:
	stage_db = _parse_json_file("res://data/stage_progression_matrix.json")
	robot_db = _parse_json_file("res://data/robot_unlock_catalog.json")
	print("Progression Databases initialized successfully.")

func _parse_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing critical design database file at: " + path)
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(content) == OK:
		return json.data
	return {}

## Fetches the scaling variables for a specific stage, calculating the cycle multiplier
func get_config_for_stage(stage_num: int) -> Dictionary:
	var result = {
		"stage_name": "Unknown Grid Sector",
		"archetype": "The Entry Stream",
		"enemy_hp": 10.0, # Baseline
		"boss_hp": 290.0,
		"enemies_per_wave": 10,
		"velocity_modifier": 1.0,
		"data_skip_multiplier": 1
	}
	
	if stage_db.is_empty() or not stage_db.has("cycles"):
		return result
		
	for cycle in stage_db["cycles"]:
		if stage_num >= cycle["stage_range"][0] and stage_num <= cycle["stage_range"][1]:
			var hp_multiplier: float = cycle["enemy_base_hp_multiplier"]
			
			# Search for individual stage overrides inside the active cycle
			for stage in cycle["stages"]:
				if stage["stage_id"] == stage_num:
					result["stage_name"] = stage["stage_name"]
					result["archetype"] = stage["archetype"]
					result["enemy_hp"] = 10.0 * hp_multiplier # Applies the cycle stat wall
					result["boss_hp"] = stage["boss_hp"]
					result["enemies_per_wave"] = stage["enemies_per_wave"]
					result["velocity_modifier"] = stage["velocity_modifier"]
					result["data_skip_multiplier"] = stage["data_skip_multiplier"]
					break
			return result
	return result

## Checks milestones to evaluate if a free catching mecha should unlock
func evaluate_mecha_unlock_milestones(stage_attempted: int) -> Array:
	var newly_unlocked: Array = []
	if robot_db.is_empty() or not robot_db.has("mechas"):
		return newly_unlocked
		
	for mecha in robot_db["mechas"]:
		var mid: String = mecha["mecha_id"]
		if mid in unlocked_mecha_ids:
			continue
			
		var req = mecha["unlock_requirement"]
		if req["type"] == "stage_failed_or_reached" and stage_attempted >= req["value"]:
			unlocked_mecha_ids.append(mid)
			newly_unlocked.append(mecha)
			
	return newly_unlocked

## Returns the dictionary data layout for the player's active mecha model
func get_active_mecha_stats() -> Dictionary:
	for mecha in robot_db["mechas"]:
		if mecha["mecha_id"] == active_mecha_id:
			return mecha
	return {}

```

---

### Step B: Hooking Up the Spawner Loop (`BattleManager.gd`)

Inside your central game scene controller, use the `ProgressionManager` singleton to inject the scaled data values directly into the spawning loop and check for robot unlocks on a game over event:

```gdscript
extends Node
class_name BattleManager

var current_stage_config: Dictionary
@export var current_wave_enemy_scene: PackedScene

func _ready() -> void:
	# Query the Singleton for the current layer's stat profile
	var stage_idx = ProgressionManager.current_player_stage
	current_stage_config = ProgressionManager.get_config_for_stage(stage_idx)
	
	# Hook active mecha configuration data down to your weapon component node
	var mecha_profile = ProgressionManager.get_active_mecha_stats()
	$Mecha/WeaponSystem.base_damage = mecha_profile["base_stats"]["attack_damage"]
	$Mecha/WeaponSystem.attack_speed = mecha_profile["base_stats"]["attack_speed"]
	$Mecha/WeaponSystem.update_weapon_speed()

func spawn_enemy_entity() -> void:
	var enemy_instance = current_wave_enemy_scene.instantiate()
	
	# Pass the cycle-multiplied HP down to the newly created entity instance
	enemy_instance.max_hp = current_stage_config["enemy_hp"]
	
	# Pass velocity modifiers directly to the path-following components
	if "speed_modifier" in enemy_instance:
		enemy_instance.speed_modifier = current_stage_config["velocity_modifier"]
		
	add_child(enemy_instance)

func handle_player_defeat() -> void:
	# Evaluate if hitting the wall triggered a free robot claim
	var stage_idx = ProgressionManager.current_player_stage
	var checks = ProgressionManager.evaluate_mecha_unlock_milestones(stage_idx)
	
	if not checks.is_empty():
		var unlocked_bot = checks[0]
		# Automatically equip the catch-up mecha to immediately clear the wall
		ProgressionManager.active_mecha_id = unlocked_bot["mecha_id"]
		
		# Emit signal or switch layout panel to open the reward unlock modal window
		print("ALERT: Unlocked free catch-up mecha: ", unlocked_bot["name"])
		
	# Route user back to main lobby menu loop
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

```

This setup connects your balancing files to the engine. When the player steps onto Stage 11, the `BattleManager` pulls the `x2.0` multiplier, forcing a defeat. The system intercepts the loss, gives them `Unit Beta` with its matching `20.0` damage base profile, and restarts the flow—all managed seamlessly behind the scenes through clean data streaming.


Here is the complete, production-ready JSON schema tailored for Godot 4. This schema defines the structure for your 10-stage progression matrix, validating parameters for the robot baseline, enemies, bosses, and the custom wave-aggregation data skip logic.

Save this as `stage_progression_schema.json`:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "MechaDefenseProgressionMatrix",
  "description": "Configuration schema for the 10-stage strategic idle progression engine.",
  "type": "object",
  "required": [
    "global_settings",
    "stages"
  ],
  "properties": {
    "global_settings": {
      "type": "object",
      "required": [
        "total_stage_time_budget_seconds",
        "loss_heart_threshold",
        "robot_baseline"
      ],
      "properties": {
        "total_stage_time_budget_seconds": {
          "type": "number",
          "minimum": 0.0,
          "default": 300.0
        },
        "loss_heart_threshold": {
          "type": "integer",
          "minimum": 1,
          "default": 50
        },
        "robot_baseline": {
          "type": "object",
          "required": [
            "base_attack_damage",
            "base_attack_speed",
            "missile_burst_damage",
            "missile_battery_cooldown"
          ],
          "properties": {
            "base_attack_damage": { "type": "number", "minimum": 0.0, "default": 10.0 },
            "base_attack_speed": { "type": "number", "minimum": 0.0, "default": 2.5 },
            "missile_burst_damage": { "type": "number", "minimum": 0.0, "default": 50.0 },
            "missile_battery_cooldown": { "type": "number", "minimum": 0.0, "default": 10.0 }
          }
        }
      }
    },
    "stages": {
      "type": "array",
      "minItems": 1,
      "maxItems": 10,
      "items": {
        "type": "object",
        "required": [
          "stage_id",
          "stage_name",
          "archetype_theme",
          "boss_hp",
          "wave_phases"
        ],
        "properties": {
          "stage_id": {
            "type": "integer",
            "minimum": 1,
            "maximum": 10
          },
          "stage_name": {
            "type": "string"
          },
          "archetype_theme": {
            "type": "string",
            "enum": [
              "The Entry Stream",
              "The Rush Protocol",
              "Shielded Packets",
              "Splitting Malware",
              "The EMP Jammer",
              "Re-routing Logic",
              "Regenerative Stream",
              "Swarm Carrier",
              "The Phantom Grid",
              "The Final Meltdown"
            ]
          },
          "boss_hp": {
            "type": "number",
            "minimum": 1.0
          },
          "wave_phases": {
            "type": "array",
            "minItems": 1,
            "items": {
              "type": "object",
              "required": [
                "phase_name",
                "wave_range",
                "spawn_rules"
              ],
              "properties": {
                "phase_name": {
                  "type": "string"
                },
                "wave_range": {
                  "type": "array",
                  "minItems": 2,
                  "maxItems": 2,
                  "items": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 100
                  }
                },
                "spawn_rules": {
                  "type": "object",
                  "required": [
                    "enemies_per_wave",
                    "enemy_velocity_modifier",
                    "spawn_interval",
                    "group_spawn_count",
                    "data_skip_multiplier"
                  ],
                  "properties": {
                    "enemies_per_wave": {
                      "type": "integer",
                      "minimum": 1
                    },
                    "enemy_velocity_modifier": {
                      "type": "number",
                      "minimum": 1.0,
                      "description": "Multiplier for enemy base speed. 1.35 equals +35% speed."
                    },
                    "spawn_interval": {
                      "type": "number",
                      "minimum": 0.0,
                      "description": "Seconds between spawning units/groups. 0.0 drops all instantly (Bosses)."
                    },
                    "group_spawn_count": {
                      "type": "integer",
                      "minimum": 1,
                      "description": "Number of enemies to drop per tick interval (e.g., 1 for single lanes, 2 for pairs)."
                    },
                    "data_skip_multiplier": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 6,
                      "description": "Number of waves skipped forward on clear to manage the 5-minute pace budget."
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

```

---

## 💾 Implementation Example: Stage 1 & Stage 2 JSON Payload

Here is how you populate data matching the schema framework above, saving it as `stage_data.json` for Godot parsing:

```json
{
  "global_settings": {
    "total_stage_time_budget_seconds": 300.0,
    "loss_heart_threshold": 50,
    "robot_baseline": {
      "base_attack_damage": 10.0,
      "base_attack_speed": 2.5,
      "missile_burst_damage": 50.0,
      "missile_battery_cooldown": 10.0
    }
  },
  "stages": [
    {
      "stage_id": 1,
      "stage_name": "Mainframe Database Sector 0-Alpha",
      "archetype_theme": "The Entry Stream",
      "boss_hp": 290.0,
      "wave_phases": [
        {
          "phase_name": "The Entry Stream",
          "wave_range": [1, 99],
          "spawn_rules": {
            "enemies_per_wave": 10,
            "enemy_velocity_modifier": 1.0,
            "spawn_interval": 0.4,
            "group_spawn_count": 1,
            "data_skip_multiplier": 1
          }
        }
      ]
    },
    {
      "stage_id": 2,
      "stage_name": "Mainframe Database Sector 0-Beta",
      "archetype_theme": "The Rush Protocol",
      "boss_hp": 390.0,
      "wave_phases": [
        {
          "phase_name": "The Aggressive Stream",
          "wave_range": [1, 40],
          "spawn_rules": {
            "enemies_per_wave": 14,
            "enemy_velocity_modifier": 1.35,
            "spawn_interval": 0.25,
            "group_spawn_count": 1,
            "data_skip_multiplier": 1
          }
        },
        {
          "phase_name": "The System Overload (Double Skips)",
          "wave_range": [41, 99],
          "spawn_rules": {
            "enemies_per_wave": 14,
            "enemy_velocity_modifier": 1.35,
            "spawn_interval": 0.4,
            "group_spawn_count": 2,
            "data_skip_multiplier": 2
          }
        }
      ]
    }
  ]
}

```

---

## 🤖 Godot 4 JSON Validator Script

Attach this script to your `BattleManager` or an Initialization Singleton (`Autoload`) to import and validate your values safely when booting your runtime game client:

```gdscript
extends Node

const DATA_PATH = "res://data/stage_data.json"

var progression_matrix: Dictionary

func _ready() -> void:
	load_progression_matrix()

func load_progression_matrix() -> void:
	if not FileAccess.file_exists(DATA_PATH):
		push_error("Progression file missing at path: " + DATA_PATH)
		return
		
	var file = FileAccess.open(DATA_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			progression_matrix = data_received
			print("Progression Matrix successfully parsed. Stages loaded: ", progression_matrix["stages"].size())
		else:
			push_error("Unexpected data format inside JSON configuration file.")
	else:
		push_error("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())

```