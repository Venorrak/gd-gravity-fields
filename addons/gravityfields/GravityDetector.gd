@tool
@icon("res://addons/gravityfields/GravityDetector.svg")
class_name GravityDetector extends Area3D

## Area3D that passes the associated provider to all gravityBody that enters it.

## The provider associated to this detector. Multiple detectors can have the same provider
@export var gravityProvider : GravityProvider:
	set(value):
		gravityProvider = value
		update_configuration_warnings()
		notify_property_list_changed()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	var validNode : bool = true
	if not gravityProvider:
		warnings.append("No gravity provider bound")
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
	if (body is GravityBody3D or body is GravityCharacter3D) and gravityProvider:
		body._gravityDetectors.append(self)
		body._sort_detectors()

func _body_exited(body : Node3D) -> void:
	if body is GravityBody3D or body is GravityCharacter3D:
		body._gravityDetectors.erase(self)
