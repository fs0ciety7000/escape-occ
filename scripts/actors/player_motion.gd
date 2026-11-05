# Pure movement math for top-down characters (no node, easy to test).
extends RefCounted


static func accelerate(
	velocity: Vector2,
	input_dir: Vector2,
	max_speed: float,
	acceleration: float,
	friction: float,
	delta: float
) -> Vector2:
	if input_dir == Vector2.ZERO:
		return velocity.move_toward(Vector2.ZERO, friction * delta)
	return velocity.move_toward(input_dir.limit_length(1.0) * max_speed, acceleration * delta)


# Snaps an 8-way input to the 4 directions used for sprites and attacks.
static func facing_from(input_dir: Vector2, current: Vector2) -> Vector2:
	if input_dir == Vector2.ZERO:
		return current
	if absf(input_dir.x) > absf(input_dir.y):
		return Vector2(signf(input_dir.x), 0.0)
	return Vector2(0.0, signf(input_dir.y))
