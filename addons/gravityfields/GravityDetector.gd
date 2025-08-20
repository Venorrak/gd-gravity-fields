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
			warnings.append("gravity_space_override should be enabled in any way to see gravity configuration")
		else:
			if gravityProvider.gravity_point == true:
				warnings.append("The gravity should be directionnal in the area (for point use a GravityPoint3D)")
	return warnings

func _get_property_list():
	var ret = []
	if Engine.is_editor_hint():
		if gravityProvider == self or gravityProvider == null:
			ret.append({
				"name": &"gravityForce",
				"type": TYPE_FLOAT,
				"usage": PROPERTY_USAGE_DEFAULT
			})
	return ret

func get_custom_gravity(bodyPosition : Vector3) -> Vector3:
	return rotate_by_provider(gravity_direction * gravityForce, global_transform)

func rotate_by_provider(input, provider_transform: Transform3D, inverse := false):
	var clean_basis : Basis = provider_transform.basis.orthonormalized()

	if typeof(input) == TYPE_VECTOR3:
		if inverse:
			return clean_basis.inverse() * input
		else:
			return clean_basis * input

	elif typeof(input) == TYPE_TRANSFORM3D:
		var clean_provider : Transform3D = Transform3D(clean_basis, provider_transform.origin)
		if inverse:
			return clean_provider.affine_inverse() * input
		else:
			return clean_provider * input

	else:
		push_error("rotate_by_provider() only supports Vector3 or Transform3D")
		return input

func _init() -> void:
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)
	update_configuration_warnings()
	notify_property_list_changed()

func _body_entered(body : Node3D) -> void:
	if body is GravityBody3D && priority >= body._providerPriority:
		body._gravityProvider = gravityProvider
		body._providerPriority = priority
		if gravityProvider == null:
			body._gravityProvider = self

func _body_exited(body : Node3D) -> void:
	if body is GravityBody3D and body._gravityProvider == gravityProvider:
		body._gravityProvider = null
		body._providerPriority = -1
		for a in get_overlapping_areas():
			if a is GravityDetector:
				for b in a.get_overlapping_bodies():
					if b == body:
						a._body_entered(body)
