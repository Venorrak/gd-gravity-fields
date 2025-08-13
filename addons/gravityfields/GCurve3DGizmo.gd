extends EditorNode3DGizmoPlugin

var gizmoSize : float = 0.5

func _get_gizmo_name():
	return "Custom Gravity indicators"

func _has_gizmo(node):
	if node is GPath3D or node is GravityPoint3D or node is GravityDetector:
		return true
	return false

func _init():
	create_material("main", Color(0.5, 0, 1))

func _redraw(gizmo : EditorNode3DGizmo):
	gizmo.clear()

	var points = PackedVector3Array()
	var node3d = gizmo.get_node_3d()
	
	if node3d is GPath3D and node3d.curve is GCurve3D:
		var path : GPath3D = node3d as GPath3D
		points = getPathLines(path)
	if node3d is GravityPoint3D:
		var point : GravityPoint3D = node3d as GravityPoint3D
		points = getPointLines(point)
	if node3d is GravityDetector and (node3d.gravityProvider == null or node3d.gravityProvider == node3d):
		var zone : GravityDetector = node3d as GravityDetector
		points = getZoneLines(zone)

	gizmo.add_lines(points, get_material("main", gizmo), false)

func getPathLines(path : GPath3D) -> PackedVector3Array:
	var points = PackedVector3Array()
	var curve : GCurve3D = path.curve
	for offset in curve.get_baked_length() + 1:
		var transform : Transform3D = curve.sample_baked_with_rotation(offset, false, true)
		var newShape : PackedVector3Array = []
		newShape = _get_shape(curve.faces) if curve.multipleFaces else _get_shape(20)
		newShape = rotatePoints(newShape, [Basis().looking_at(transform.basis.z, transform.basis.y).orthonormalized()])
		newShape = translatePoints(newShape, transform.origin)
		points += newShape
	return points
	
func getPointLines(point : GravityPoint3D) -> PackedVector3Array:
	var points = _get_shape(20)
	var arrow = _get_arrow()
	if point.gravityForce > 0:
		arrow = rotatePoints(arrow, [Basis().looking_at(Vector3.UP, Vector3.UP.rotated(Vector3(1, 0, 0), PI / 2)).orthonormalized()])
	else:
		arrow = rotatePoints(arrow, [Basis().looking_at(Vector3.DOWN, Vector3.DOWN.rotated(Vector3(1, 0, 0), PI / 2)).orthonormalized()])
	arrow = translatePoints(arrow, Vector3(0, gizmoSize, 0))
	points += arrow
	return points
	
func getZoneLines(zone : GravityDetector) -> PackedVector3Array:
	var points = _get_arrow()
	points = rotatePoints(points, [Basis().looking_at(zone.gravity_direction, zone.gravity_direction.rotated(Vector3(1, 0, 0), PI / 2)).orthonormalized().inverse()])
	return points
	
func rotatePoints(points : PackedVector3Array, rotations : Array[Basis]) -> PackedVector3Array:
	for o in rotations:
		for index in points.size():
			var vec : Vector3 = points[index]
			vec = o * vec
			points.set(index, vec)
	return points
	
func translatePoints(points : PackedVector3Array, movement: Vector3) -> PackedVector3Array:
	for index in points.size():
		points.set(index, points[index] + movement)
	return points

func _get_arrow() -> PackedVector3Array:
	var points = PackedVector3Array()
	points.append(Vector3(0, 0, 0))
	points.append(Vector3(0, 0, gizmoSize))
	points.append(Vector3(0, gizmoSize * 0.2, gizmoSize * 0.9))
	points.append(Vector3(0, 0, gizmoSize))
	points.append(Vector3(0, -gizmoSize * 0.2, gizmoSize * 0.9))
	points.append(Vector3(0, 0, gizmoSize))
	points.append(Vector3(gizmoSize * 0.2, 0, gizmoSize * 0.9))
	points.append(Vector3(0, 0, gizmoSize))
	points.append(Vector3(-gizmoSize * 0.2, 0, gizmoSize * 0.9))
	points.append(Vector3(0, 0, gizmoSize))
	return points
	
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
