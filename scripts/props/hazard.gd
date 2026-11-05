# Live-cable floor hazard: hurts any body that can take hits while it stands on it.
# Danger is shown by shape (hatching) as well as color, per DESIGN.md.
extends Area2D

const Palette = preload("res://scripts/palette.gd")

@export var size := Vector2(24, 12)
@export var damage := 1

var _time := 0.0


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	add_child(shape)


func _physics_process(delta: float) -> void:
	_time += delta
	for body in get_overlapping_bodies():
		if body.has_method("take_hit"):
			body.take_hit(damage, global_position)
	queue_redraw()


func _draw() -> void:
	var area := Rect2(-size / 2.0, size)
	draw_rect(area, Palette.FURNITURE_DARK)
	# Red hatching, one 2 px stripe every 4 px.
	var x := area.position.x + 1.0
	while x < area.end.x - 1.0:
		draw_rect(Rect2(x, area.position.y + 1.0, 2.0, size.y - 2.0), Palette.DANGER)
		x += 4.0
	draw_rect(area, Palette.HAZARD, false, 1.0)
	# Slow spark: about one blink per second, well under the 3 flashes/s limit.
	if fmod(_time, 1.0) < 0.15:
		draw_rect(Rect2(-1, -1, 3, 3), Palette.TEXT)
