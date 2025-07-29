@tool
class_name GravityField2D extends Node2D

signal area_entered(area: Area2D)
signal area_exited(area: Area2D)
signal area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int)
signal area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int)
signal body_entered(body: Node2D)
signal body_exited(body: Node2D)
signal body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int)
signal body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int)

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
@export var gravitySpaceOverride : Area2D.SpaceOverride = Area2D.SpaceOverride.SPACE_OVERRIDE_REPLACE:
	set(value):
		gravitySpaceOverride = value
		updateShapes()
@export var shape : GravityShape2D = CircleGravity2D.new():
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
@export var linearDampSpaceOverride : Area2D.SpaceOverride = Area2D.SpaceOverride.SPACE_OVERRIDE_DISABLED:
	set(value):
		linearDampSpaceOverride = value
		updateShapes()
@export_group("Angular Damp", "angularDamp")
@export var angularDampSpaceOverride : Area2D.SpaceOverride = Area2D.SpaceOverride.SPACE_OVERRIDE_DISABLED:
	set(value):
		angularDampSpaceOverride = value
		updateShapes()
@export_category("CollisionObject2D")
@export var disableMode : CollisionObject2D.DisableMode = CollisionObject2D.DisableMode.DISABLE_MODE_REMOVE:
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

var lastGlobalRotation : float

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_editor_process(delta)
	else:
		pass

func _physics_process(delta: float) -> void:
	if not lastGlobalRotation:
		lastGlobalRotation = global_rotation
	if global_rotation != lastGlobalRotation:
		updateShapes()
	lastGlobalRotation = global_rotation

func _editor_process(delta: float) -> void:
	pass

func updateShapes() -> void:
	clearShapes()
	createShapes()

func clearShapes() -> void:
	for ch in get_children():
		if ch.is_class("Area2D"):
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
		var newArea : Area2D = Area2D.new()
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
		newArea.input_pickable = pickable
		newArea.area_entered.connect(mock_area_entered)
		newArea.area_exited.connect(mock_area_exited)
		newArea.area_shape_entered.connect(mock_area_shape_entered)
		newArea.area_shape_exited.connect(mock_area_shape_exited)
		newArea.body_entered.connect(mock_body_entered)
		newArea.body_exited.connect(mock_body_exited)
		newArea.body_shape_entered.connect(mock_body_shape_entered)
		newArea.body_shape_exited.connect(mock_body_shape_exited)
		var newCollision : CollisionPolygon2D = CollisionPolygon2D.new()
		newCollision.polygon = s["shape"]
		newArea.add_child(newCollision)
		add_child(newArea)

func mock_area_entered(area: Area2D) -> void:
	area_entered.emit(area)

func mock_area_exited(area: Area2D) -> void:
	area_exited.emit(area)

func mock_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	area_shape_entered.emit(area_rid, area, area_shape_index, local_shape_index)
	
func mock_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	area_shape_exited.emit(area_rid, area, area_shape_index, local_shape_index)	

func mock_body_entered(body: Node2D) -> void:
	body_entered.emit(body)
	
func mock_body_exited(body: Node2D) -> void:
	body_exited.emit(body)
	
func mock_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	body_shape_entered.emit(body_rid, body, body_shape_index, local_shape_index)

func mock_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	body_shape_exited.emit(body_rid, body, body_shape_index, local_shape_index)	
