# Greybox test room (one 320x180 screen): open space with two desk rows,
# a training dummy and a live-cable hazard. Reloads the scene when the player dies.
extends Node2D

const Palette = preload("res://scripts/palette.gd")
const ROOM_SIZE := Vector2(320, 180)
const WALL_FACE := 28.0
const RESPAWN_DELAY := 1.2
const BEACON_HZ := 0.4

# Solid areas in room pixels: outer walls, then desk rows (partition + desk).
const SOLIDS: Array[Rect2] = [
	Rect2(0, 0, 320, 32),
	Rect2(0, 172, 320, 8),
	Rect2(0, 0, 8, 180),
	Rect2(312, 0, 8, 180),
	Rect2(40, 64, 96, 20),
	Rect2(184, 64, 96, 20),
]
const DESKS: Array[Rect2] = [Rect2(40, 64, 96, 20), Rect2(184, 64, 96, 20)]

var _time := 0.0

@onready var _player: CharacterBody2D = $Player
@onready var _hud: Control = $HUD/HudView
@onready var _beacon: PointLight2D = $Beacon


func _ready() -> void:
	_build_solids()
	_player.health_changed.connect(_hud.set_health)
	_player.died.connect(_on_player_died)
	_hud.set_health(_player.health.current, _player.health.maximum)


func _process(delta: float) -> void:
	_time += delta
	# Slow beacon pulse (0.4 Hz), far below the 3 flashes/s accessibility limit.
	_beacon.energy = 0.8 + 0.6 * (0.5 + 0.5 * sin(_time * TAU * BEACON_HZ))


func _build_solids() -> void:
	var body := StaticBody2D.new()
	body.name = "Solids"
	body.collision_layer = 1
	body.collision_mask = 0
	add_child(body)
	for rect: Rect2 in SOLIDS:
		var shape := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = rect.size
		shape.shape = box
		shape.position = rect.get_center()
		body.add_child(shape)


func _on_player_died() -> void:
	get_tree().create_timer(RESPAWN_DELAY).timeout.connect(get_tree().reload_current_scene)


func _draw() -> void:
	_draw_floor()
	_draw_walls()
	for desk: Rect2 in DESKS:
		_draw_desk_row(desk)


func _draw_floor() -> void:
	draw_rect(Rect2(Vector2.ZERO, ROOM_SIZE), Palette.TILE)
	for y in range(32, int(ROOM_SIZE.y), 16):
		draw_rect(Rect2(0, y, ROOM_SIZE.x, 1), Palette.TILE_JOINT)
	for x in range(0, int(ROOM_SIZE.x), 16):
		draw_rect(Rect2(x, 32, 1, ROOM_SIZE.y - 32), Palette.TILE_JOINT)


func _draw_walls() -> void:
	# Top wall face in pale yellow brick, then a concrete baseboard.
	draw_rect(Rect2(0, 0, ROOM_SIZE.x, WALL_FACE), Palette.BRICK_SHADOW)
	for y in range(0, int(WALL_FACE), 4):
		draw_rect(Rect2(0, y, ROOM_SIZE.x, 1), Palette.BRICK_JOINT)
		var offset := 0 if y % 8 == 0 else 4
		for x in range(offset, int(ROOM_SIZE.x), 8):
			draw_rect(Rect2(x, y, 1, 4), Palette.BRICK_JOINT)
	draw_rect(Rect2(0, 0, ROOM_SIZE.x, 1), Palette.BRICK)
	draw_rect(Rect2(0, WALL_FACE, ROOM_SIZE.x, 4), Palette.CONCRETE)
	# Night windows.
	for x in [24, 88, 216, 280]:
		draw_rect(Rect2(x - 1, 6, 22, 16), Palette.CONCRETE)
		draw_rect(Rect2(x, 7, 20, 14), Palette.SHADOW)
		draw_rect(Rect2(x + 9, 7, 2, 14), Palette.CONCRETE)
	# Side and bottom walls.
	draw_rect(Rect2(0, 0, 8, ROOM_SIZE.y), Palette.CONCRETE)
	draw_rect(Rect2(ROOM_SIZE.x - 8, 0, 8, ROOM_SIZE.y), Palette.CONCRETE)
	draw_rect(Rect2(0, ROOM_SIZE.y - 8, ROOM_SIZE.x, 8), Palette.CONCRETE)


func _draw_desk_row(rect: Rect2) -> void:
	# Blue partition on top, desk below, a red "LOCKED" screen per seat.
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 6)), Palette.PARTITION)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 1)), Palette.PARTITION_LIGHT)
	draw_rect(
		Rect2(rect.position + Vector2(0, 5), Vector2(rect.size.x, 1)), Palette.PARTITION_SHADOW
	)
	draw_rect(
		Rect2(rect.position + Vector2(0, 6), Vector2(rect.size.x, rect.size.y - 6)),
		Palette.FURNITURE
	)
	for seat in int(rect.size.x / 24):
		var screen := rect.position + Vector2(4 + seat * 24, 8)
		draw_rect(Rect2(screen, Vector2(16, 6)), Palette.FURNITURE_DARK)
		draw_rect(Rect2(screen + Vector2(5, 2), Vector2(6, 2)), Palette.DANGER)
