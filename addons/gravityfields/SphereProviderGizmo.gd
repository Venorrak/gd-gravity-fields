extends EditorNode3DGizmoPlugin

var gizmoSize : float = 1

func _get_gizmo_name():
	return "Sphere provider Gravity gizmo"
	
func _has_gizmo(node):
	return node is SphereProvider

func _init():
	create_material("main", Color(0.5, 0, 1))
	
func _redraw(gizmo : EditorNode3DGizmo):
	gizmo.clear()

	var points = PackedVector3Array()
	var provider : SphereProvider = gizmo.get_node_3d()
	points = getLines(provider)

	gizmo.add_lines(points, get_material("main", gizmo), false)

func getLines(provider : SphereProvider) -> PackedVector3Array:
	var points : PackedVector3Array = _get_shape(20)
	var points2 : PackedVector3Array = _get_shape(20)
	points2 = rotatePoints(points2, [Basis().looking_at(Vector3.UP, Vector3.UP.rotated(Vector3(1, 0, 0), PI / 2)).orthonormalized()])
	return points + points2

func _get_shape(sides : int) -> PackedVector3Array:
	var points : PackedVector3Array = []
	var step : float = TAU / sides
	for i in sides:
		var angle = step * i
		if sides % 2 != 0:
			angle -= (PI / 2)
		if sides % 2 == 0:
			angle += step / 2
		var nextAngle = angle + step
		points.append(Vector3(gizmoSize * cos(angle), gizmoSize * sin(angle), 0))
		points.append(Vector3(gizmoSize * cos(nextAngle), gizmoSize * sin(nextAngle), 0))
	return points

func rotatePoints(points : PackedVector3Array, rotations : Array[Basis]) -> PackedVector3Array:
	for o in rotations:
		for index in points.size():
			var vec : Vector3 = points[index]
			vec = o * vec
			points.set(index, vec)
	return points
