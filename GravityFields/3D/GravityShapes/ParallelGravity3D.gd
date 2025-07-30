@tool
extends GravityShape3D
class_name ParallelGravity3D

@export var width : float = 10:
	set(value):
		width = value
		updateShape.emit()
@export var length : float = 10:
	set(value):
		length = value
		updateShape.emit()
@export var height : float = 10:
	set(value):
		height = value
		updateShape.emit()
@export var mirror : bool = true:
	set(value):
		mirror = value
		updateShape.emit()

func rotateByParent(input: Vector3, gRotation: Vector3) -> Vector3:
	input = input.rotated(Vector3(1, 0, 0), gRotation.x)
	input = input.rotated(Vector3(0, 1, 0), gRotation.y)
	input = input.rotated(Vector3(0, 0, 1), gRotation.z)
	return input
	
func rotateByParentReversed(input: Vector3, gRotation: Vector3) -> Vector3:
	input = input.rotated(Vector3(1, 0, 0), gRotation.x)
	input = input.rotated(Vector3(0, 1, 0), gRotation.y)
	input = input.rotated(Vector3(0, 0, 1), gRotation.z + deg_to_rad(180))
	return input

func getShapes(gRotation: Vector3) -> Array[Dictionary]:
	var shapes : Array[Dictionary]
	shapes.append({
		"point_direction": rotateByParent(Vector3.DOWN, gRotation),
		"shape": [
			Vector3(-width / 2, 0, 0),
			Vector3(-width / 2, height, 0),
			Vector3(width / 2, height, 0),
			Vector3(width / 2, 0, 0),
			Vector3(width / 2, 0, length),
			Vector3(width / 2, height, length),
			Vector3(-width / 2, height, length),
			Vector3(-width / 2, 0, length)
			
		],
		"gravityFalloff": null
	})
	if mirror:
		shapes.append({
		"point_direction": rotateByParentReversed(Vector3.DOWN, gRotation),
		"shape": [
			Vector3(-width / 2, 0, 0),
			Vector3(-width / 2, -height, 0),
			Vector3(width / 2, -height, 0),
			Vector3(width / 2, 0, 0),
			Vector3(width / 2, 0, length),
			Vector3(width / 2, -height, length),
			Vector3(-width / 2, -height, length),
			Vector3(-width / 2, 0, length)
		],
		"gravityFalloff": null
	})
	return shapes
