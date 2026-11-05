# Hit points as plain data, shared by the player and (later) enemies.
extends RefCounted

signal changed(current: int, maximum: int)
signal depleted

var maximum: int
var current: int


func _init(max_value: int = 5) -> void:
	maximum = max_value
	current = max_value


func damage(amount: int) -> int:
	if amount <= 0 or current <= 0:
		return 0
	var applied := mini(amount, current)
	current -= applied
	changed.emit(current, maximum)
	if current == 0:
		depleted.emit()
	return applied


func heal(amount: int) -> int:
	if amount <= 0 or current <= 0:
		return 0
	var applied := mini(amount, maximum - current)
	current += applied
	if applied > 0:
		changed.emit(current, maximum)
	return applied


func is_dead() -> bool:
	return current <= 0
