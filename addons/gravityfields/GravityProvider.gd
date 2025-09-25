@abstract class_name GravityProvider extends Node3D
## A gravity provider takes in the position of the gravity body and return the gravity that should be applied to it

## Force of the gravity
@export var gravityForce : float = 9.8

## Get the custom gravity vector
@abstract func get_custom_gravity(globalBodyPosition : Vector3) -> Vector3

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
