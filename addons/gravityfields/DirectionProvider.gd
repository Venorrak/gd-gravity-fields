@tool
@icon("res://addons/gravityfields/DirectionProvider.svg")
class_name DirectionProvider extends GravityProvider
## Gravity provider for planes

## Direction of the gravity. Will be normalized
@export var gravity_direction : Vector3 = Vector3.DOWN:
	set(value):
		gravity_direction = value
		update_gizmos()

## Get the custom gravity vector
func get_custom_gravity(globalBodyPosition : Vector3) -> Vector3:
	var direction : Vector3 = gravity_direction.normalized()
	var distance : float = (globalBodyPosition - global_position).dot(direction)
	return _rotate_by_provider(direction * gravityForce, global_transform) * _get_falloff(distance)
