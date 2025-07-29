@tool
extends GravityShape2D
class_name CircleGravity2D

@export var radius : float = 1.0:
	set(newRadius):
		radius = newRadius
		updateShape.emit()
		
@export var sampling : int = 20:
	set(newSampling):
		sampling = newSampling
		updateShape.emit()
		
@export var gravityFalloff : float = 0.0:
	set(newGravityFalloff):
		gravityFalloff = newGravityFalloff
		updateShape.emit()
		
func getShapes(rotation: float) -> Array[Dictionary]:
	var shape : PackedVector2Array = []
	for i in sampling:
		var angle = 2.0 * PI * i / sampling
		shape.append(Vector2(radius * cos(angle), radius * sin(angle)))
	return [{
		"point_direction": Vector2(0, 0),
		"shape": shape,
		"gravityFalloff": gravityFalloff
	}]
