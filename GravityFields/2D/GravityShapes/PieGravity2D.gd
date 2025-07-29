@tool
extends GravityShape2D
class_name PieGravity2D

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
		
var radiant = 0

@export_range(0.0, 360.0, 0.01) var degree : float = 0:
	set(newDegree):
		degree = newDegree
		radiant = degree * 0.01745329
		updateShape.emit()
		
func getShapes(rotation: float) -> Array[Dictionary]:
	var shape : PackedVector2Array = []
	shape.append(Vector2(0, 0))
	for i in sampling + 1:
		var theta = radiant * i / sampling
		shape.append(Vector2(radius * cos(theta), radius * sin(theta)))
	return [{
		"point_direction": Vector2(0, 0),
		"shape": shape,
		"gravityFalloff": gravityFalloff
	}]
