extends GutTest

const JSON_PATH = "res://data/stage_progression_matrix.json"

func test_stage_configuration_file_exists() -> void:
    assert_true(ResourceLoader.exists(JSON_PATH), "Stage progression matrix JSON should exist")

func test_stage_configuration_json_is_dictionary() -> void:
    var file = FileAccess.open(JSON_PATH, FileAccess.READ)
    assert_not_null(file, "Stage progression matrix file should open")
    var json = JSON.parse_string(file.get_as_text())
    file.close()
    assert_true(json is Dictionary, "Stage progression matrix should parse as Dictionary")

func test_stage_configuration_contains_cycles_and_global_settings() -> void:
    var file = FileAccess.open(JSON_PATH, FileAccess.READ)
    assert_not_null(file, "Stage progression matrix file should open")
    var json = JSON.parse_string(file.get_as_text())
    file.close()
    assert_true(json is Dictionary, "Stage progression matrix should parse as Dictionary")
    assert_true(json.has("cycles"), "Stage progression matrix should contain cycles")
    assert_true(json.has("global_settings"), "Stage progression matrix should contain global_settings")
    assert_true(json["cycles"] is Array and json["cycles"].size() > 0, "cycles should be a non-empty Array")
    assert_true(json["global_settings"] is Dictionary, "global_settings should be a Dictionary")

func test_stage_configuration_archetypes_exist() -> void:
    var expected_archetypes = [
        "Entry Stream",
        "Rush Protocol",
        "Shielded Packets",
        "Splitting Malware",
        "EMP Jammer",
        "Re-routing Logic",
        "Regenerative Stream",
        "Swarm Carrier",
        "Phantom Grid",
        "Final Meltdown"
    ]

    var file = FileAccess.open(JSON_PATH, FileAccess.READ)
    assert_not_null(file, "Stage progression matrix file should open")
    var json = JSON.parse_string(file.get_as_text())
    file.close()
    assert_true(json is Dictionary, "Stage progression matrix should parse as Dictionary")

    for archetype in expected_archetypes:
        var found = false
        for cycle in json["cycles"]:
            if cycle is Dictionary and cycle.has("stages"):
                for stage in cycle["stages"]:
                    if stage is Dictionary:
                        var raw_archetype: String = stage.get("archetype", "")
                        var normalized_archetype: String = raw_archetype.replace("The ", "")
                        if normalized_archetype == archetype:
                            found = true
                            break
                if found:
                    break
        assert_true(found, "Stage progression matrix should contain archetype %s" % archetype)
