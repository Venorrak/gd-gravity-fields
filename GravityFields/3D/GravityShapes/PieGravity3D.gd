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
@export_range(3, 1000, 1) var faces : int = 30:
	set(value):
		faces = value
		updateShape.emit()

func rotateByParent(input: Vector3, gRotation: Vector3) -> Vector3:
	input = input.rotated(Vector3(1, 0, 0), gRotation.x)
	input = input.rotated(Vector3(0, 1, 0), gRotation.y)
	input = input.rotated(Vector3(0, 0, 1), gRotation.z)
	return input

func rotateByTwist(input: Vector3, index: int) -> Vector3:
	var tRotation : float = (deg_to_rad(angle) / float(increments)) * (index + 0.5)
	return input.rotated(Vector3(0, 0, 1), tRotation + deg_to_rad(-90))

func Theta(index: float) -> float:
	return (deg_to_rad(angle) / faces) * index 

func getShapes(gRotation: Vector3) -> Array[Dictionary]:
	var sections : Array[Dictionary] = []
	for i in increments:
		var polygon : PackedVector3Array = []
		polygon.append(Vector3(0, 0, (i) * (length /  increments)))
		polygon.append(Vector3(0, 0, (i + 1) * (length /  increments)))
		for f in faces + 1:
			polygon.append(Vector3(radius * cos(Theta(f)), radius * sin(Theta(f)), i * (length /  increments)))
			polygon.append(Vector3(radius * cos(Theta(f)), radius * sin(Theta(f)), (i + 1) * (length /  increments)))

		var newSection : Dictionary = {
			"point_direction": Vector3(0, 0, (i + 0.5) * (length /  increments)),
			"shape": polygon,
			"gravityFalloff": 0.0
		}
		sections.append(newSection)
	return sections
