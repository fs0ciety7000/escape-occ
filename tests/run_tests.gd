# Headless test runner.
# Usage: godot --headless --path . --script res://tests/run_tests.gd
# Exits 1 on any failure. Never use bare assert() here: it halts before quit().
extends SceneTree

const InputSetup = preload("res://scripts/autoload/input_setup.gd")
const Health = preload("res://scripts/components/health.gd")
const Motion = preload("res://scripts/actors/player_motion.gd")
const PlayerScript = preload("res://scripts/actors/player.gd")
const PlayerScene = preload("res://scenes/actors/player.tscn")
const TestRoomScript = preload("res://scripts/rooms/test_room.gd")
const TestRoomScene = preload("res://scenes/rooms/test_room.tscn")
const STEP := 1.0 / 60.0

var _passed := 0
var _failed := 0


func _initialize() -> void:
	_run()


# Async so scene tests can wait one frame: nodes added during _initialize
# only get _ready() (and their @onready vars) on the next frame.
func _run() -> void:
	InputSetup.register()
	_test_project_settings()
	_test_input_actions()
	_test_health()
	_test_motion()
	await _test_player_attack()
	await _test_player_dodge()
	await _test_player_hit_and_death()
	await _test_test_room()
	print("tests: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func assert_eq(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		_passed += 1
	else:
		_failed += 1
		push_error("FAIL %s: expected %s, got %s" % [label, expected, actual])


func assert_near(actual: float, expected: float, label: String) -> void:
	assert_eq(is_equal_approx(actual, expected), true, "%s (%s ≈ %s)" % [label, actual, expected])


func _spawn_player() -> CharacterBody2D:
	var player: CharacterBody2D = PlayerScene.instantiate()
	root.add_child(player)
	await process_frame
	return player


# Advances the player's logic by `seconds` with no input.
func _wait(player: CharacterBody2D, seconds: float) -> void:
	var elapsed := 0.0
	while elapsed < seconds:
		player.step(STEP, Vector2.ZERO, false, false)
		elapsed += STEP


func _test_project_settings() -> void:
	var name: String = ProjectSettings.get_setting("application/config/name")
	var width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	assert_eq(name, "Escape from OCC", "project name")
	assert_eq(width, 320, "viewport width")
	assert_eq(ResourceLoader.exists("res://scenes/main.tscn"), true, "main scene exists")


func _test_input_actions() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down", "attack", "dodge"]:
		assert_eq(InputMap.has_action(action), true, "action %s registered" % action)
	assert_eq(InputMap.action_get_events("attack").size(), 3, "attack has key, key and pad")
	InputSetup.register()
	assert_eq(InputMap.action_get_events("dodge").size(), 3, "register is idempotent")


func _test_health() -> void:
	var health = Health.new(3)
	var deaths := [0]
	health.depleted.connect(func(): deaths[0] += 1)
	assert_eq(health.damage(1), 1, "damage applies")
	assert_eq(health.current, 2, "health decreases")
	assert_eq(health.heal(5), 1, "heal is capped at maximum")
	assert_eq(health.damage(10), 3, "damage is capped at current")
	assert_eq(health.is_dead(), true, "health depleted")
	assert_eq(deaths[0], 1, "depleted emitted once")
	assert_eq(health.damage(1), 0, "no damage once dead")
	assert_eq(health.heal(1), 0, "no heal once dead")
	assert_eq(deaths[0], 1, "depleted not emitted twice")


func _test_motion() -> void:
	var v := Motion.accelerate(Vector2.ZERO, Vector2.RIGHT, 90.0, 900.0, 1100.0, 0.05)
	assert_near(v.x, 45.0, "acceleration toward input")
	v = Motion.accelerate(Vector2(90, 0), Vector2.RIGHT, 90.0, 900.0, 1100.0, 0.05)
	assert_near(v.x, 90.0, "speed capped at max_speed")
	v = Motion.accelerate(Vector2(90, 0), Vector2.ZERO, 90.0, 900.0, 1100.0, 0.05)
	assert_near(v.x, 35.0, "friction without input")
	v = Motion.accelerate(Vector2.ZERO, Vector2(1, 1), 90.0, 9000.0, 1100.0, 1.0)
	assert_near(v.length(), 90.0, "diagonal not faster")
	assert_eq(Motion.facing_from(Vector2(0.9, 0.3), Vector2.DOWN), Vector2.RIGHT, "facing x")
	assert_eq(Motion.facing_from(Vector2(-0.2, -0.8), Vector2.DOWN), Vector2.UP, "facing y")
	assert_eq(Motion.facing_from(Vector2.ZERO, Vector2.LEFT), Vector2.LEFT, "facing kept")


func _test_player_attack() -> void:
	var player: CharacterBody2D = await _spawn_player()
	player.step(STEP, Vector2.LEFT, false, false)
	assert_eq(player.facing, Vector2.LEFT, "player faces input")
	player.step(STEP, Vector2.ZERO, true, false)
	assert_eq(player.state, PlayerScript.State.ATTACK, "attack starts")
	assert_eq(player.get_node("AttackHitbox").position, Vector2(-10, 0), "hitbox in front")
	_wait(player, player.attack_duration + STEP)
	assert_eq(player.state, PlayerScript.State.MOVE, "attack ends")
	player.free()


func _test_player_dodge() -> void:
	var player: CharacterBody2D = await _spawn_player()
	player.step(STEP, Vector2.UP, false, true)
	assert_eq(player.state, PlayerScript.State.DODGE, "dodge starts")
	assert_near(player.velocity.length(), player.dodge_speed, "dodge speed")
	assert_eq(player.is_invulnerable(), true, "invulnerable while dodging")
	assert_eq(player.take_hit(1, Vector2.ZERO), false, "dodge ignores hits")
	_wait(player, player.dodge_duration + STEP)
	assert_eq(player.state, PlayerScript.State.MOVE, "dodge ends")
	player.step(STEP, Vector2.UP, false, true)
	assert_eq(player.state, PlayerScript.State.MOVE, "dodge on cooldown")
	_wait(player, player.dodge_cooldown + STEP)
	player.step(STEP, Vector2.UP, false, true)
	assert_eq(player.state, PlayerScript.State.DODGE, "dodge again after cooldown")
	player.free()


func _test_player_hit_and_death() -> void:
	var player: CharacterBody2D = await _spawn_player()
	player.global_position = Vector2(100, 100)
	var deaths := [0]
	var last_health := [-1]
	player.died.connect(func(): deaths[0] += 1)
	player.health_changed.connect(func(current: int, _maximum: int): last_health[0] = current)
	assert_eq(player.take_hit(1, Vector2(90, 100)), true, "hit lands")
	assert_eq(player.health.current, player.max_health - 1, "hit removes health")
	assert_eq(last_health[0], player.max_health - 1, "health_changed emitted")
	assert_eq(player.state, PlayerScript.State.HURT, "hurt state")
	assert_eq(player.velocity.x > 0.0, true, "knockback away from source")
	assert_eq(player.take_hit(1, Vector2(90, 100)), false, "i-frames after hit")
	for i in player.max_health - 1:
		_wait(player, player.invulnerability_after_hit + STEP)
		player.take_hit(1, Vector2(90, 100))
	assert_eq(player.health.is_dead(), true, "player dies")
	assert_eq(player.state, PlayerScript.State.DEAD, "dead state")
	assert_eq(deaths[0], 1, "died emitted once")
	assert_eq(player.take_hit(1, Vector2(90, 100)), false, "no hit when dead")
	player.free()


func _test_test_room() -> void:
	var room: Node2D = TestRoomScene.instantiate()
	root.add_child(room)
	await process_frame
	var solids := room.get_node("Solids")
	assert_eq(solids.get_child_count(), TestRoomScript.SOLIDS.size(), "room builds its solids")
	assert_eq(room.get_node("Player").health.current, 5, "room spawns a full-health player")
	var dummy = room.get_node("Dummy")
	assert_eq(dummy.take_hit(1, Vector2.ZERO), true, "dummy takes hits")
	assert_eq(dummy.hits, 1, "dummy counts hits")
	room.free()
