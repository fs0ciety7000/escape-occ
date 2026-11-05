# Top HUD: hazard band and health blocks (orange), per DESIGN.md.
extends Control

const Palette = preload("res://scripts/palette.gd")
const BAND_HEIGHT := 6
const BLOCK := Vector2(6, 5)

var _current := 0
var _maximum := 0


func set_health(current: int, maximum: int) -> void:
	_current = current
	_maximum = maximum
	queue_redraw()


func _draw() -> void:
	var width := get_viewport_rect().size.x
	draw_rect(Rect2(0, 0, width, BAND_HEIGHT), Palette.HUD_DARK)
	var x := -12.0
	while x < width:
		var stripe := PackedVector2Array(
			[
				Vector2(x, 0),
				Vector2(x + 6, 0),
				Vector2(x + 12, BAND_HEIGHT),
				Vector2(x + 6, BAND_HEIGHT)
			]
		)
		draw_colored_polygon(stripe, Palette.HAZARD)
		x += 12.0
	if _maximum <= 0:
		return
	draw_rect(Rect2(2, BAND_HEIGHT + 2, 4 + _maximum * 8, 9), Palette.HUD_DARK)
	for i in _maximum:
		var color := Palette.EMERGENCY if i < _current else Palette.EMERGENCY_EMPTY
		draw_rect(Rect2(Vector2(5 + i * 8, BAND_HEIGHT + 4), BLOCK), color)
