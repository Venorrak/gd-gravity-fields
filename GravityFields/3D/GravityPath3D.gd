@tool
class_name GravityPath3D extends Node3D

signal area_entered(area: Area3D)
signal area_exited(area: Area3D)
signal area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int)
signal area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int)
signal body_entered(body: Node3D)
signal body_exited(body: Node3D)
signal body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int)
signal body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int)

@export var path : Path3D:
	set(value):
		path = value
		_fetchCurve()
var curve : Curve3D:
	set(value):
		curve = value
		updateShapes()
@export var width : float = 8:
	set(value):
		width = value
		updateShapes()
@export var height : float = 5:
	set(value):
		height = value
		updateShapes()
@export var sectionLength : float = 1.1:
	set(value):
		sectionLength = value
		updateShapes()
@export var mirror : bool = false:
	set(value):
		mirror = value
		updateShapes()
@export_tool_button("Fetch Curve")
var fetchCurve = _fetchCurve

@export_category("Area3D")
@export var monitoring : bool = true:
	set(value):
		monitoring = value
		updateShapes()
@export var monitorable : bool = true:
	set(value):
		monitorable = value
		updateShapes()
@export var priority : int = 0:
	set(newPriority):
		priority = newPriority
		updateShapes()
@export_group("Gravity")
@export var gravitySpaceOverride : Area3D.SpaceOverride = Area3D.SpaceOverride.SPACE_OVERRIDE_REPLACE:
	set(value):
		gravitySpaceOverride = value
		updateShapes()
@export var effects : bool = true:
	set(newEffects):
		effects = newEffects
		updateShapes()
@export var zoneGravity : float = 9.8:
	set(newGravity):
		zoneGravity = newGravity
		updateShapes()
@export_group("Linear Damp")
@export var linearDampSpaceOverride : Area3D.SpaceOverride = Area3D.SpaceOverride.SPACE_OVERRIDE_DISABLED:
	set(value):
		linearDampSpaceOverride = value
		updateShapes()
@export_group("Angular Damp", "angularDamp")
@export var angularDampSpaceOverride : Area3D.SpaceOverride = Area3D.SpaceOverride.SPACE_OVERRIDE_DISABLED:
	set(value):
		angularDampSpaceOverride = value
		updateShapes()
@export_category("CollisionObject3D")
@export var disableMode : CollisionObject3D.DisableMode = CollisionObject3D.DisableMode.DISABLE_MODE_REMOVE:
	set(value):
		disableMode = value
		updateShapes()
@export_group("Collision")
@export_flags_2d_physics var layer = 1:
	set(value):
		layer = value
		updateShapes()
@export_flags_2d_physics var mask = 1:
	set(value):
		mask = value
		updateShapes()
@export var collisionPriority : float = 1.0:
	set(value):
		collisionPriority = value
		updateShapes()
@export_group("Input")
@export var pickable : bool = true:
	set(value):
		pickable = value
		updateShapes()
@export var captureOnDrag : bool = false:
	set(value):
		captureOnDrag = value
		updateShapes()

func updateShapes() -> void:
	clearShapes()
	createShapes()
	if mirror:
		createShapes(true)

func createShapes(mirrored: bool = false) -> void:
	for i in curve.get_baked_length():
		var newArea : Area3D = Area3D.new()
		var newCollision : CollisionShape3D = CollisionShape3D.new()
		var newShape : UniqueConvexPolygonShape3D = UniqueConvexPolygonShape3D.new()
		newShape.setup_local_to_scene()
		var pTransform : Transform3D = curve.sample_baked_with_rotation(i, false, true)
		if mirrored:
			newShape.points = ShapeGenerator(pTransform, true)
			newArea.gravity_direction = Vector3.UP.rotated(pTransform.basis.get_rotation_quaternion().get_axis(), pTransform.basis.get_rotation_quaternion().get_angle())
		else:
			newShape.points = ShapeGenerator(pTransform)
			newArea.gravity_direction = Vector3.DOWN.rotated(pTransform.basis.get_rotation_quaternion().get_axis(), pTransform.basis.get_rotation_quaternion().get_angle())
		newCollision.shape = newShape
		newArea.add_child(newCollision)
		
		newArea = basicArea3DSetup(newArea)
		add_child(newArea)
		newArea.owner = get_parent()
		newCollision.owner = get_parent()
	
func ShapeGenerator(tr: Transform3D, mirrored: bool = false) -> PackedVector3Array:
	var q : Quaternion = tr.basis.get_rotation_quaternion()
	var shape : PackedVector3Array
	if mirrored:
		shape = [
			Vector3(-width / 2, 0, 0).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(-width / 2, -height, 0).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(width / 2, -height, 0).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(width / 2, 0, 0).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(width / 2, 0, sectionLength).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(width / 2, -height, sectionLength).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(-width / 2, -height, sectionLength).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(-width / 2, 0, sectionLength).rotated(q.get_axis(), q.get_angle()) + tr.origin
		]
	else:
		shape = [
			Vector3(-width / 2, 0, 0).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(-width / 2, height, 0).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(width / 2, height, 0).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(width / 2, 0, 0).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(width / 2, 0, sectionLength).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(width / 2, height, sectionLength).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(-width / 2, height, sectionLength).rotated(q.get_axis(), q.get_angle()) + tr.origin,
			Vector3(-width / 2, 0, sectionLength).rotated(q.get_axis(), q.get_angle()) + tr.origin
		]
	return shape

func basicArea3DSetup(a : Area3D) -> Area3D:
	a.monitoring = monitoring
	a.monitorable = monitorable
	a.priority = priority
	a.gravity_space_override = gravitySpaceOverride
	a.gravity = zoneGravity
	a.linear_damp_space_override = linearDampSpaceOverride
	a.angular_damp_space_override = angularDampSpaceOverride
	a.disable_mode = disableMode
	a.collision_layer = layer
	a.collision_mask = mask
	a.collision_priority = collisionPriority
	a.input_ray_pickable = pickable
	a.input_capture_on_drag = captureOnDrag
	a.area_entered.connect(mock_area_entered)
	a.area_exited.connect(mock_area_exited)
	a.area_shape_entered.connect(mock_area_shape_entered)
	a.area_shape_exited.connect(mock_area_shape_exited)
	a.body_entered.connect(mock_body_entered)
	a.body_exited.connect(mock_body_exited)
	a.body_shape_entered.connect(mock_body_shape_entered)
	a.body_shape_exited.connect(mock_body_shape_exited)
	return a
	
func clearShapes() -> void:
	for ch in get_children():
		if ch.is_class("Area3D"):
			ch.area_entered.disconnect(mock_area_entered)
			ch.area_exited.disconnect(mock_area_exited)
			ch.area_shape_entered.disconnect(mock_area_shape_entered)
			ch.area_shape_exited.disconnect(mock_area_shape_exited)
			ch.body_entered.disconnect(mock_body_entered)
			ch.body_exited.disconnect(mock_body_exited)
			ch.body_shape_entered.disconnect(mock_body_shape_entered)
			ch.body_shape_exited.disconnect(mock_body_shape_exited)
			ch.queue_free()
	
func _fetchCurve() -> void:
	curve = path.curve

func mock_area_entered(area: Area3D) -> void:
	area_entered.emit(area)

func mock_area_exited(area: Area3D) -> void:
	area_exited.emit(area)

func mock_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	area_shape_entered.emit(area_rid, area, area_shape_index, local_shape_index)
	
func mock_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	area_shape_exited.emit(area_rid, area, area_shape_index, local_shape_index)	

func mock_body_entered(body: Node3D) -> void:
	body_entered.emit(body)
	
func mock_body_exited(body: Node3D) -> void:
	body_exited.emit(body)
	
func mock_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	body_shape_entered.emit(body_rid, body, body_shape_index, local_shape_index)

func mock_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	body_shape_exited.emit(body_rid, body, body_shape_index, local_shape_index)
