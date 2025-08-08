@tool
class_name GravityDetector extends Area3D

@export var gravityProvider : Node3D:
	set(value):
		gravityProvider = value
		update_configuration_warnings()
		notify_property_list_changed()
var gravityForce : float = 9.8

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	var validNode : bool = true
	if not (gravityProvider is GravityPoint3D or gravityProvider is Path3D or gravityProvider == null or gravityProvider is GravityDetector):
		validNode = false
		warnings.append("Gravity Supplyer should be a GravityPoint3D, a Path3D or null(self)")
	if validNode and gravityProvider is Path3D:
		if not gravityProvider.curve is GCurve3D:
			warnings.append("Curve in Path3D should be a GCurve3D in order to work properly")
	if validNode and (gravityProvider == null or gravityProvider is GravityDetector):
		if gravityProvider.gravity_space_override == SPACE_OVERRIDE_DISABLED:
			warnings.append("gravity_space_override should be enabled in any way")
		else:
			if gravityProvider.gravity_point == true:
				warnings.append("The gravity should be directionnal in the area (for point use a GravityPoint3D)")
	return warnings

func _get_property_list():
	if Engine.is_editor_hint():
		var ret = []
		if gravityProvider == self or gravityProvider == null:
			ret.append({
				"name": &"gravityForce",
				"type": TYPE_FLOAT,
				"usage": PROPERTY_USAGE_DEFAULT
			})
		return ret

func get_custom_gravity(bodyPosition : Vector3) -> Vector3:
	return rotateByProvider(gravity_direction * gravityForce, global_rotation)

func rotateByProvider(input: Vector3, gRotation: Vector3) -> Vector3:
	input = input.rotated(Vector3(1, 0, 0), gRotation.x)
	input = input.rotated(Vector3(0, 1, 0), gRotation.y)
	input = input.rotated(Vector3(0, 0, 1), gRotation.z)
	return input

func _init() -> void:
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)
	update_configuration_warnings()
	notify_property_list_changed()
	
func _body_entered(body : Node3D) -> void:
	if body is GravityBody3D:
		body.gravityProvider = gravityProvider
		if gravityProvider == null:
			body.gravityProvider = self

func _body_exited(body : Node3D) -> void:
	if body is GravityBody3D and body.gravityProvider == gravityProvider:
		body.gravityProvider = null
