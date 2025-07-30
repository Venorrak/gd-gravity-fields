@tool
extends GravityShape3D
class_name TwistGravity3D

@export var width : float = 8:
	set(value):
		width = value
		updateShape.emit()
@export var length : float = 20:
	set(value):
		length = value
		updateShape.emit()
@export var height : float = 5:
	set(value):
		height = value
		updateShape.emit()
@export var rotation : float = 90: #degree
	set(value):
		rotation = value
		updateShape.emit()
@export_range(1, 1000, 1) var increments : int = 20:
	set(value):
		increments = value
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

func rotateByTwist(input: Vector3, index: int) -> Vector3:
	var tRotation : float = (deg_to_rad(rotation) / float(increments - 1)) * index
	return input.rotated(Vector3(0, 0, 1), tRotation)

func rotateByTwist2(input: Vector3, index: int) -> Vector3:
	var tRotation : float = (deg_to_rad(rotation) / float(increments - 1)) * index
	return input.rotated(Vector3(0, 0, 1), tRotation + deg_to_rad(180))
	
func getShapes(gRotation: Vector3) -> Array[Dictionary]:
	var sections : Array[Dictionary] = []
	for i in increments:
		var polygon : PackedVector3Array = [
			rotateByTwist(Vector3(width / 2, 0, (length / increments) * i), i),
			rotateByTwist(Vector3(width / 2, 0, (length / increments) * (i + 1)), i),
			rotateByTwist(Vector3(width / 2, height, (length / increments) * (i + 1)), i),
			rotateByTwist(Vector3(width / 2, height, (length / increments) * i), i),
			rotateByTwist(Vector3(-width / 2, height, (length / increments) * i), i),
			rotateByTwist(Vector3(-width / 2, height, (length / increments) * (i + 1)), i),
			rotateByTwist(Vector3(-width / 2, 0, (length / increments) * (i + 1)), i),
			rotateByTwist(Vector3(-width / 2, 0, (length / increments) * i), i)
		]
		var newSection : Dictionary = {
			"point_direction": rotateByTwist(rotateByParent(Vector3.DOWN, gRotation), i),
			"shape": polygon,
			"gravityFalloff": null
		}
		sections.append(newSection)
	if mirror:
		for i in increments:
			var polygon : PackedVector3Array = [
				rotateByTwist2(Vector3(width / 2, 0, (length / increments) * i), i),
				rotateByTwist2(Vector3(width / 2, 0, (length / increments) * (i + 1)), i),
				rotateByTwist2(Vector3(width / 2, height, (length / increments) * (i + 1)), i),
				rotateByTwist2(Vector3(width / 2, height, (length / increments) * i), i),
				rotateByTwist2(Vector3(-width / 2, height, (length / increments) * i), i),
				rotateByTwist2(Vector3(-width / 2, height, (length / increments) * (i + 1)), i),
				rotateByTwist2(Vector3(-width / 2, 0, (length / increments) * (i + 1)), i),
				rotateByTwist2(Vector3(-width / 2, 0, (length / increments) * i), i)
			]
			var newSection : Dictionary = {
				"point_direction": rotateByTwist2(rotateByParent(Vector3.DOWN, gRotation), i),
				"shape": polygon,
				"gravityFalloff": null
			}
			sections.append(newSection)
	return sections
