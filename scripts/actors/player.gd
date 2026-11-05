# Player controller: 8-way movement, sword swing, dodge roll with i-frames, health.
# Gameplay logic lives in step() so tests can drive it without input or physics frames.
extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

enum State { MOVE, ATTACK, DODGE, HURT, DEAD }

const Motion = preload("res://scripts/actors/player_motion.gd")
const Health = preload("res://scripts/components/health.gd")
const Palette = preload("res://scripts/palette.gd")
const HITBOX_REACH := 10.0

@export var max_speed := 90.0
@export var acceleration := 900.0
@export var friction := 1100.0
@export var dodge_speed := 220.0
@export var dodge_duration := 0.18
@export var dodge_cooldown := 0.35
@export var attack_duration := 0.2
@export var attack_damage := 1
@export var hurt_duration := 0.2
@export var invulnerability_after_hit := 0.8
@export var knockback_speed := 160.0
@export var max_health := 5

var state: State = State.MOVE
var facing := Vector2.DOWN
var health

var _state_time := 0.0
var _dodge_cooldown_left := 0.0
var _invulnerable_left := 0.0
var _dodge_dir := Vector2.DOWN
var _hit_this_swing: Array[Node] = []

@onready var _hitbox: Area2D = $AttackHitbox
@onready var _hitbox_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D


func _ready() -> void:
	health = Health.new(max_health)
	health.changed.connect(func(current: int, maximum: int): health_changed.emit(current, maximum))
	health.depleted.connect(_on_health_depleted)
	_hitbox.body_entered.connect(_on_hitbox_body_entered)
	_set_hitbox_enabled(false)


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	step(
		delta,
		input_dir,
		Input.is_action_just_pressed("attack"),
		Input.is_action_just_pressed("dodge")
	)
	move_and_slide()
	modulate.a = 0.45 if _invulnerable_left > 0.0 and state != State.DEAD else 1.0
	queue_redraw()


func step(delta: float, input_dir: Vector2, attack_pressed: bool, dodge_pressed: bool) -> void:
	_state_time += delta
	_dodge_cooldown_left = maxf(_dodge_cooldown_left - delta, 0.0)
	_invulnerable_left = maxf(_invulnerable_left - delta, 0.0)
	match state:
		State.MOVE:
			facing = Motion.facing_from(input_dir, facing)
			if attack_pressed:
				_start_attack()
			elif dodge_pressed and can_dodge():
				_start_dodge(input_dir)
			else:
				velocity = Motion.accelerate(
					velocity, input_dir, max_speed, acceleration, friction, delta
				)
		State.ATTACK:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			if _state_time >= attack_duration:
				_set_hitbox_enabled(false)
				_set_state(State.MOVE)
		State.DODGE:
			velocity = _dodge_dir * dodge_speed
			if _state_time >= dodge_duration:
				velocity = _dodge_dir * max_speed
				_set_state(State.MOVE)
		State.HURT:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			if _state_time >= hurt_duration:
				_set_state(State.MOVE)
		State.DEAD:
			velocity = Vector2.ZERO


func can_dodge() -> bool:
	return state == State.MOVE and _dodge_cooldown_left <= 0.0


func is_invulnerable() -> bool:
	return state == State.DODGE or state == State.DEAD or _invulnerable_left > 0.0


# Called by hazards and enemies. Returns true when the hit landed.
func take_hit(damage: int, from_position: Vector2) -> bool:
	if is_invulnerable():
		return false
	_set_hitbox_enabled(false)
	health.damage(damage)
	if health.is_dead():
		return true
	_invulnerable_left = invulnerability_after_hit
	var away := global_position - from_position
	var push_dir := away.normalized() if away != Vector2.ZERO else -facing
	velocity = push_dir * knockback_speed
	_set_state(State.HURT)
	return true


func _start_attack() -> void:
	_hit_this_swing.clear()
	_hitbox.position = facing * HITBOX_REACH
	_set_hitbox_enabled(true)
	_set_state(State.ATTACK)


func _start_dodge(input_dir: Vector2) -> void:
	_dodge_dir = input_dir.normalized() if input_dir != Vector2.ZERO else facing
	_dodge_cooldown_left = dodge_duration + dodge_cooldown
	velocity = _dodge_dir * dodge_speed
	_set_state(State.DODGE)


func _set_state(new_state: State) -> void:
	state = new_state
	_state_time = 0.0


func _set_hitbox_enabled(enabled: bool) -> void:
	_hitbox_shape.set_deferred("disabled", not enabled)


func _on_hitbox_body_entered(body: Node) -> void:
	if state != State.ATTACK or body in _hit_this_swing:
		return
	_hit_this_swing.append(body)
	if body.has_method("take_hit"):
		body.take_hit(attack_damage, global_position)


func _on_health_depleted() -> void:
	velocity = Vector2.ZERO
	_set_hitbox_enabled(false)
	_set_state(State.DEAD)
	died.emit()


# Greybox look until real sprites land: coat, head, facing marker, swing.
func _draw() -> void:
	draw_rect(Rect2(-4, 5, 8, 2), Color(0, 0, 0, 0.5))
	if state == State.DEAD:
		draw_rect(Rect2(-7, 0, 14, 5), Palette.PLAYER_COAT)
		draw_rect(Rect2(-9, 0, 3, 4), Palette.PLAYER_SKIN)
		return
	var coat := Palette.PLAYER_COAT_LIGHT if state == State.DODGE else Palette.PLAYER_COAT
	draw_rect(Rect2(-5, -5, 10, 11), Palette.OUTLINE)
	draw_rect(Rect2(-4, -4, 8, 9), coat)
	draw_rect(Rect2(-4, -11, 8, 7), Palette.OUTLINE)
	draw_rect(Rect2(-3, -10, 6, 5), Palette.PLAYER_SKIN)
	draw_rect(Rect2(-3, -10, 6, 2), Palette.PLAYER_HAIR)
	draw_rect(Rect2(facing * 5.0 - Vector2(1, 1), Vector2(2, 2)), Palette.TEXT)
	if state == State.ATTACK:
		var size := Vector2(
			absf(facing.x) * 6 + absf(facing.y) * 14, absf(facing.y) * 6 + absf(facing.x) * 14
		)
		draw_rect(Rect2(facing * HITBOX_REACH - size / 2.0, size), Palette.HAZARD)
