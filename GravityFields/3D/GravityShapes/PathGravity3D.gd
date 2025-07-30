@tool
extends GravityShape3D
class_name PathGravity3D

@export var width : float = 8:
	set(value):
		width = value
		updateShape.emit()
@export var height : float = 5:
	set(value):
		height = value
		updateShape.emit()
@export var pathPath : NodePath:
	set(value):
		pathPath = value
		fetchCurve()
@export_tool_button("fetch curve") var fetchAction = fetchCurve
var path : Curve3D

func _init() -> void:
	fetchCurve()

func fetchCurve() -> void:
	pass
func getShapes(rotation: Vector3) -> Array[Dictionary]:
	return []
