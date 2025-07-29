@tool
extends GravityShape3D
class_name PieGravity3D

@export var radius : float = 10:
	set(value):
		radius = value
		updateShape.emit()
@export var length : float = 10:
	set(value):
		length = value
		updateShape.emit()
@export var angle : float = 90: #degree
	set(value):
		angle = value
		updateShape.emit()
@export_range(1, 1000, 1) var increments : int = 50:
	set(value):
		increments = value
		updateShape.emit()

func rotateByParent(input: Vector3, gRotation: Vector3) -> Vector3:
	input.x += gRotation.x
	input.y += gRotation.y
	input.z += gRotation.z
	return input

func rotateByTwist(input: Vector3, index: int) -> Vector3:
	var tRotation : float = (deg_to_rad(angle) / float(increments)) * (index + 0.5)
	return input.rotated(Vector3(0, 0, 1), tRotation)

func Theta(index: float) -> float:
	return (deg_to_rad(angle) / increments) * index 

func getShapes(gRotation: Vector3) -> Array[Dictionary]:
	var sections : Array[Dictionary] = []
	for i in increments:
		var polygon : PackedVector3Array = [
			Vector3(0, 0, 0),
			Vector3(0, 0, length),
			Vector3(radius * cos(Theta(i)), radius * sin(Theta(i)), length),
			Vector3(radius * cos(Theta(i)), radius * sin(Theta(i)), 0),
			Vector3(radius * cos(Theta(i + 1)), radius * sin(Theta(i + 1)), 0),
			Vector3(radius * cos(Theta(i + 1)), radius * sin(Theta(i + 1)), length)
		]
		var newSection : Dictionary = {
			"point_direction": rotateByTwist(rotateByParent(Vector3.DOWN, gRotation), i),
			"shape": polygon,
			"gravityFalloff": null
		}
		sections.append(newSection)
	return sections
