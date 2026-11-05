# Training dummy for the test room: solid, takes hits, flashes, counts them.
extends StaticBody2D

const Palette = preload("res://scripts/palette.gd")
const FLASH_TIME := 0.12
const SHAPE_SIZE := Vector2(10, 8)

var hits := 0

var _flash_left := 0.0


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SHAPE_SIZE
	shape.shape = rect
	add_child(shape)


func _process(delta: float) -> void:
	if _flash_left > 0.0:
		_flash_left = maxf(_flash_left - delta, 0.0)
		queue_redraw()


func take_hit(_damage: int, _from_position: Vector2) -> bool:
	hits += 1
	_flash_left = FLASH_TIME
	queue_redraw()
	return true


func _draw() -> void:
	var body := Palette.TEXT if _flash_left > 0.0 else Palette.PARTITION
	draw_rect(Rect2(-5, 3, 10, 2), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(-6, -13, 12, 17), Palette.OUTLINE)
	draw_rect(Rect2(-5, -12, 10, 15), body)
	draw_rect(Rect2(-5, -12, 10, 2), Palette.PARTITION_LIGHT)
	draw_rect(Rect2(-1, -16, 2, 4), Palette.CONCRETE)
	# One pip per hit (up to 10), above the dummy.
	for i in mini(hits, 10):
		draw_rect(Rect2(-10 + i * 2, -20, 1, 2), Palette.HAZARD)
