@tool
@icon("res://addons/gravityfields/icons/GravityDetector.svg")
class_name GravityDetector extends Area3D

## Area3D that passes the associated provider to all gravityBody that enters it.

## The provider associated to this detector. Multiple detectors can have the same provider
@export var gravityProvider : GravityProvider:
	set(value):
		gravityProvider = value
		update_configuration_warnings()
		notify_property_list_changed()

## Types of body filtering
enum FilterType { 
	NONE, ## No filter
	WHITELIST, ## Only the specified groups will be influenced
	BLACKLIST  ## only the specified groups will not be influenced
}
## Type of filter used to decide if we influence the Gravity body with the provider
@export var filterType: FilterType = FilterType.NONE:
	set(value):
		filterType = value
		notify_property_list_changed()

## List of groups to be Whitelisted or Blacklisted
var filterList: PackedStringArray = []

func _get_property_list() -> Array[Dictionary]:
	var ret: Array[Dictionary] = []
	if Engine.is_editor_hint():
		if not filterType == FilterType.NONE:
			ret.append({
				"name": &"filterList",
				"type": TYPE_PACKED_STRING_ARRAY,
				"usage": PROPERTY_USAGE_DEFAULT
			})
	return ret

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

## Checks if the body is accepted by the configured filter
func verifyFilter(body: Node3D) -> bool:
	if filterType == FilterType.WHITELIST:
		for g in filterList:
			if body.is_in_group(g): return true
		return false
	elif filterType == FilterType.BLACKLIST:
		for g in filterList:
			if body.is_in_group(g): return false
		return true
	return true

func _body_entered(body : Node3D) -> void:
	if (body is GravityBody3D or body is GravityCharacter3D) and gravityProvider and verifyFilter(body):
		body._gravityDetectors.append(self)
		body._sort_detectors()

func _body_exited(body : Node3D) -> void:
	if body is GravityBody3D or body is GravityCharacter3D:
		body._gravityDetectors.erase(self)
