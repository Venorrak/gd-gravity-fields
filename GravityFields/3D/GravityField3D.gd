@tool
class_name GravityField3D extends Node3D

signal area_entered(area: Area3D)
signal area_exited(area: Area3D)
signal area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int)
signal area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int)
signal body_entered(body: Node3D)
signal body_exited(body: Node3D)
signal body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int)
signal body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int)

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
@export var shape : GravityShape3D = TwistGravity3D.new():
	set(newShape):
		if shape:
			shape.updateShape.disconnect(updateShapes)
		shape = newShape
		clearShapes()
		if newShape:
			newShape.updateShape.connect(updateShapes)
			createShapes()
@export var effects : bool = true:
	set(newEffects):
		effects = newEffects
		updateShapes()
@export var zoneGravity : float:
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
		
var lastGlobalRotation : Vector3

func _physics_process(delta: float) -> void:
	if not lastGlobalRotation:
		lastGlobalRotation = global_rotation
	if global_rotation != lastGlobalRotation:
		updateShapes()
	lastGlobalRotation = global_rotation

func updateShapes() -> void:
	clearShapes()
	createShapes()
	
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
	
func createShapes() -> void:
	var shapes : Array[Dictionary] = shape.getShapes(global_rotation)
	for s in shapes:
		var newArea : Area3D = Area3D.new()
		newArea.monitoring = monitoring
		newArea.monitorable = monitorable
		newArea.priority = priority
		newArea.gravity_space_override = gravitySpaceOverride
		newArea.gravity_point = s["gravityFalloff"] != null
		if s["gravityFalloff"] != null:
			newArea.gravity_point_unit_distance = s["gravityFalloff"]
			newArea.gravity_point_center = s["point_direction"]
		else:
			newArea.gravity_direction = s["point_direction"]
		newArea.gravity = zoneGravity
		newArea.linear_damp_space_override = linearDampSpaceOverride
		newArea.angular_damp_space_override = angularDampSpaceOverride
		newArea.disable_mode = disableMode
		newArea.collision_layer = layer
		newArea.collision_mask = mask
		newArea.collision_priority = collisionPriority
		newArea.input_ray_pickable = pickable
		newArea.input_capture_on_drag = captureOnDrag
		newArea.area_entered.connect(mock_area_entered)
		newArea.area_exited.connect(mock_area_exited)
		newArea.area_shape_entered.connect(mock_area_shape_entered)
		newArea.area_shape_exited.connect(mock_area_shape_exited)
		newArea.body_entered.connect(mock_body_entered)
		newArea.body_exited.connect(mock_body_exited)
		newArea.body_shape_entered.connect(mock_body_shape_entered)
		newArea.body_shape_exited.connect(mock_body_shape_exited)
		var newCollision : CollisionShape3D = CollisionShape3D.new()
		var newShape : UniqueConvexPolygonShape3D = UniqueConvexPolygonShape3D.new()
		newShape.setup_local_to_scene()
		newShape.points = s["shape"]
		newCollision.shape = newShape
		newArea.add_child(newCollision)
		add_child(newArea)
		newArea.owner = get_parent()
		newCollision.owner = get_parent()
		
	
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
