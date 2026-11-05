# Registers the game's input actions at startup (autoload "InputSetup").
# Keys use physical positions, so WASD stays WASD on an AZERTY keyboard (ZQSD).
extends Node

const DEADZONE := 0.25

# action -> list of events: keys (physical keycodes), joypad buttons, joypad axes.
const BINDINGS := {
	"move_left":
	[
		{"key": KEY_A},
		{"key": KEY_LEFT},
		{"button": JOY_BUTTON_DPAD_LEFT},
		{"axis": JOY_AXIS_LEFT_X, "value": -1.0}
	],
	"move_right":
	[
		{"key": KEY_D},
		{"key": KEY_RIGHT},
		{"button": JOY_BUTTON_DPAD_RIGHT},
		{"axis": JOY_AXIS_LEFT_X, "value": 1.0}
	],
	"move_up":
	[
		{"key": KEY_W},
		{"key": KEY_UP},
		{"button": JOY_BUTTON_DPAD_UP},
		{"axis": JOY_AXIS_LEFT_Y, "value": -1.0}
	],
	"move_down":
	[
		{"key": KEY_S},
		{"key": KEY_DOWN},
		{"button": JOY_BUTTON_DPAD_DOWN},
		{"axis": JOY_AXIS_LEFT_Y, "value": 1.0}
	],
	"attack": [{"key": KEY_J}, {"key": KEY_SPACE}, {"button": JOY_BUTTON_X}],
	"dodge": [{"key": KEY_K}, {"key": KEY_SHIFT}, {"button": JOY_BUTTON_B}],
}


func _ready() -> void:
	register()


static func register() -> void:
	for action: String in BINDINGS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action, DEADZONE)
		for binding: Dictionary in BINDINGS[action]:
			InputMap.action_add_event(action, _make_event(binding))


static func _make_event(binding: Dictionary) -> InputEvent:
	if binding.has("key"):
		var key := InputEventKey.new()
		key.physical_keycode = binding["key"]
		return key
	if binding.has("button"):
		var button := InputEventJoypadButton.new()
		button.button_index = binding["button"]
		return button
	var motion := InputEventJoypadMotion.new()
	motion.axis = binding["axis"]
	motion.axis_value = binding["value"]
	return motion
