@tool
class_name GravityDetector extends Area3D

@export var gravityProvider : GravityProvider:
	set(value):
		gravityProvider = value
		update_configuration_warnings()
		notify_property_list_changed()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	var validNode : bool = true
	if gravity_space_override == SPACE_OVERRIDE_DISABLED:
		warnings.append("gravity_space_override should be enabled in any way to affect the gravity")
	return warnings

func _rotate_by_provider(input, provider_transform: Transform3D, inverse := false):
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
	if body is GravityBody3D:
		body._gravityProviders.append({"provider": gravityProvider, "detector": self})
		body._sort_providers()

func _body_exited(body : Node3D) -> void:
	if body is GravityBody3D:
		body._gravityProviders.erase({"provider": gravityProvider, "detector": self})
