@tool
extends GravityShape2D
class_name DiskGravity2D

@export var radius : float = 1.0:
	set(newRadius):
		radius = newRadius
		updateShape.emit()
		
@export var length : float = 1.0:
	set(newLength):
		length = newLength
		updateShape.emit()
		
@export var sampling : int = 20:
	set(newSampling):
		sampling = newSampling
		updateShape.emit()

func _getRectangle(reversed : bool) -> PackedVector2Array:
	var mod : int = -1 if reversed else 1
	return [
		Vector2(-length / 2, 0),
		Vector2(-length / 2, radius * mod),
		Vector2(length / 2, radius * mod),
		Vector2(length / 2, 0),
	]

func _getDemiCircle(reversed: bool) -> PackedVector2Array:
	var mod : int = -1 if reversed else 1
	var shape : PackedVector2Array = []
	for i in sampling + 1:
		var theta = PI * i / sampling + ((mod * PI) / 2)
		shape.append(Vector2(radius * cos(theta), radius * sin(theta)))
	return shape

func _offset(shape: PackedVector2Array, reversed: bool) -> PackedVector2Array:
	var mod : int = -1 if reversed else 1
	for index in shape.size():
		shape.set(index, shape[index] + Vector2((mod * length) / 2, 0))
	return shape

func getShapes(rotation: float) -> Array[Dictionary]:
	return [
		{
			"point_direction": Vector2.DOWN.rotated(rotation),
			"shape": _getRectangle(true),
			"gravityFalloff": null
		},
		{
			"point_direction": Vector2(length/2, 0),
			"shape": _offset(_getDemiCircle(true), false),
			"gravityFalloff": 0.0
		},
		{
			"point_direction": Vector2.UP.rotated(rotation),
			"shape": _getRectangle(false),
			"gravityFalloff": null
		},
		{
			"point_direction": Vector2(-length/2, 0),
			"shape": _offset(_getDemiCircle(false), true),
			"gravityFalloff": 0.0
		},
	]
