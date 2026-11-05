# Headless test runner.
# Usage: godot --headless --path . --script res://tests/run_tests.gd
# Exits 1 on any failure. Never use bare assert() here: it halts before quit().
extends SceneTree

var _passed := 0
var _failed := 0


func _initialize() -> void:
	_test_project_settings()
	print("tests: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func assert_eq(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		_passed += 1
	else:
		_failed += 1
		push_error("FAIL %s: expected %s, got %s" % [label, expected, actual])


func _test_project_settings() -> void:
	var name: String = ProjectSettings.get_setting("application/config/name")
	var width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	assert_eq(name, "Escape from OCC", "project name")
	assert_eq(width, 320, "viewport width")
	assert_eq(ResourceLoader.exists("res://scenes/main.tscn"), true, "main scene exists")
