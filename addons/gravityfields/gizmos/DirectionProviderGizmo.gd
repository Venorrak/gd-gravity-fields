extends EditorNode3DGizmoPlugin

var gizmoSize : float = 2

func _get_gizmo_name():
	return "Directional provider Gravity gizmo"
	
func _has_gizmo(node):
	return node is DirectionProvider

func _init():
	create_material("main", Color(0.502, 0.0, 1.0, 1.0))
	
func _redraw(gizmo : EditorNode3DGizmo):
	gizmo.clear()

	var provider : DirectionProvider = gizmo.get_node_3d()
	var points : PackedVector3Array = getLines(provider)
	gizmo.add_lines(points, get_material("main", gizmo), false)


func getLines(provider : DirectionProvider) -> PackedVector3Array:
	var points = _get_arrow()
	
	# Normalize the gravity direction
	var gravity_dir = provider.gravity_direction.normalized()
	
	# Create a basis looking in the gravity direction
	var up = Vector3.UP
	# Prevent cases where gravity_dir is parallel to UP
	if abs(gravity_dir.dot(up)) > 0.99:
		up = Vector3.RIGHT
	var basis = Basis().looking_at(gravity_dir, up)
	
	# Rotate points
	points = rotatePoints(points, [basis])
	return points


func rotatePoints(points : PackedVector3Array, rotations : Array[Basis]) -> PackedVector3Array:
	for o in rotations:
		for index in range(points.size()):
			points[index] = o * points[index]
	return points


func _get_arrow() -> PackedVector3Array:
	var points = PackedVector3Array()
	points.append(Vector3(0, 0, 0))
	points.append(Vector3(0, 0, -gizmoSize))
	points.append(Vector3(0, gizmoSize * 0.2, -gizmoSize * 0.9))
	points.append(Vector3(0, 0, -gizmoSize))
	points.append(Vector3(0, -gizmoSize * 0.2, -gizmoSize * 0.9))
	points.append(Vector3(0, 0, -gizmoSize))
	points.append(Vector3(gizmoSize * 0.2, 0, -gizmoSize * 0.9))
	points.append(Vector3(0, 0, -gizmoSize))
	points.append(Vector3(-gizmoSize * 0.2, 0, -gizmoSize * 0.9))
	points.append(Vector3(0, 0, -gizmoSize))
	return points
