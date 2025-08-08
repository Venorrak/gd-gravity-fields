@tool
class_name GravityDetector extends Area3D

@export var gravityProvider : Node3D:
	set(value):
		gravityProvider = value
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	var validNode : bool = true
	if not (gravityProvider is Marker3D or gravityProvider is Path3D or gravityProvider == null or gravityProvider is GravityDetector):
		validNode = false
		warnings.append("Gravity Supplyer should be a Marker3D, a Path3D or null(self)")
	if validNode and gravityProvider is Path3D:
		if not gravityProvider.curve is GCurve3D:
			warnings.append("Curve in Path3D should be a GCurve3D in order to work properly")
	if validNode and (gravityProvider == null or gravityProvider is GravityDetector):
		if gravityProvider.gravity_space_override == SPACE_OVERRIDE_DISABLED:
			warnings.append("gravity_space_override should be enabled in any way")
		else:
			if gravityProvider.gravity_point == true:
				warnings.append("The gravity should be directionnal in the area (for point use a Marker3D)")
	return warnings

func _init() -> void:
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)
	
func _body_entered(body : Node3D) -> void:
	if body is GravityBody3D:
		body.gravityProvider = gravityProvider

func _body_exited(body : Node3D) -> void:
	if body is GravityBody3D and body.gravityProvider == gravityProvider:
		body.gravityProvider = null
