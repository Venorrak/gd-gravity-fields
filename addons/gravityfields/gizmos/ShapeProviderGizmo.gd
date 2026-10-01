extends EditorNode3DGizmoPlugin

var gizmoSize : float = 1

func _get_gizmo_name():
	return "Shape provider Gravity gizmo"
	
func _has_gizmo(node):
	return node is ShapeProvider

func _init():
	create_material("main", Color(0.5, 0, 1))
	
func _redraw(gizmo : EditorNode3DGizmo):
	gizmo.clear()

	var points = PackedVector3Array()
	var provider : ShapeProvider = gizmo.get_node_3d()
	points = getShapes(provider)
	_draw_path(provider.curve, Color.GREEN, get_material("main", gizmo), gizmo)

	gizmo.add_lines(points, get_material("main", gizmo), false)

func getShapes(provider : ShapeProvider) -> PackedVector3Array:
	var points = PackedVector3Array()
	var curve : Curve3D = provider.curve
	for offset in curve.get_baked_length() + 1:
		var transform : Transform3D = curve.sample_baked_with_rotation(offset, false, true)
		var newShape : PackedVector3Array = []
		newShape = _get_shape(provider.faces) if provider.multipleFaces else _get_shape(20)
		newShape = rotatePoints(newShape, [Basis().looking_at(transform.basis.z, transform.basis.y).orthonormalized()])
		newShape = translatePoints(newShape, transform.origin)
		points += newShape
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

# Wildly taken from the godot source code and put in the GPT to give me the translation to gdscript
# No shame
func _draw_path(c: Curve3D, path_color: Color, debug_material: Material, gizmo: EditorNode3DGizmo) -> void:
	var interval := 0.1
	var length := c.get_baked_length()

	var sample_count := int(length / interval) + 2
	interval = length / float(sample_count - 1)

	# Get frames
	var frames: Array[Transform3D] = []
	frames.resize(sample_count)
	for i in sample_count:
		frames[i] = c.sample_baked_with_rotation(i * interval, true, true)

	var collision_segments := PackedVector3Array()
	var bones := PackedVector3Array()
	var ribbon_lines := PackedVector3Array()

	for i in sample_count:
		var t: Transform3D = frames[i]
		var p1: Vector3 = t.origin
		var side: Vector3 = t.basis.x
		var up: Vector3 = t.basis.y
		var forward: Vector3 = t.basis.z

		# Collision segments
		if i != sample_count - 1:
			var p2 := frames[i + 1].origin
			collision_segments.append(p1)
			collision_segments.append(p2)

			# Ribbon as line pairs
			ribbon_lines.append(p1)
			ribbon_lines.append(p2)

		# Bones every 4 points
		if i % 4 == 0:
			var p_left  := p1 + (side + forward - up * 0.3) * 0.06
			var p_right := p1 + (-side + forward - up * 0.3) * 0.06

			bones.append_array([p1, p_left, p1, p_right])

	gizmo.add_collision_segments(collision_segments)
	gizmo.add_lines(bones, debug_material)
	gizmo.add_lines(ribbon_lines, debug_material)
