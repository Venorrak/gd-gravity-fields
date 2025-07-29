@tool
extends GravityShape2D
class_name SquareGravity2D

@export var width : float = 1.0:
	set(newWidth):
		width = newWidth
		updateShape.emit()

func getShapes(rotation: float) -> Array[Dictionary]:
	return [
		{
			"point_direction": Vector2.DOWN.rotated(rotation),
			"shape": PackedVector2Array([
				Vector2(0, 0),
				Vector2(width / -2, width / -2),
				Vector2(width / 2, width / -2)
			]),
			"gravityFalloff": null
		},
		{
			"point_direction": Vector2.LEFT.rotated(rotation),
			"shape": PackedVector2Array([
				Vector2(0, 0),
				Vector2(width / 2, width / -2),
				Vector2(width / 2, width / 2)
			]),
			"gravityFalloff": null
		},
		{
			"point_direction": Vector2.UP.rotated(rotation),
			"shape": PackedVector2Array([
				Vector2(0, 0),
				Vector2(width / 2, width / 2),
				Vector2(width / -2, width / 2)
			]),
			"gravityFalloff": null
		},
		{
			"point_direction": Vector2.RIGHT.rotated(rotation),
			"shape": PackedVector2Array([
				Vector2(0, 0),
				Vector2(width / -2, width / 2),
				Vector2(width / -2, width / -2),
			]),
			"gravityFalloff": null
		}
	]
