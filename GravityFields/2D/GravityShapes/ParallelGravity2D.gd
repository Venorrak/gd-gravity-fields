@tool
extends GravityShape2D
class_name ParallelGravity2D

@export var width : float = 1.0:
	set(newWidth):
		width = newWidth
		updateShape.emit()

@export var height : float = 1.0:
	set(newHeight):
		height = newHeight
		updateShape.emit()

@export var direction : Vector2 = Vector2(0, 1):
	set(newDirection):
		direction = newDirection.normalized()
		updateShape.emit()

func getShapes(rotation: float) -> Array[Dictionary]:
	return [
		{
			"point_direction": direction.rotated(rotation),
			"shape": PackedVector2Array([
				Vector2(width / -2, height / -2),
				Vector2(width / 2, height / -2),
				Vector2(width / 2, height / 2),
				Vector2(width / -2, height / 2)
			]),
			"gravityFalloff": null
		},
	]
