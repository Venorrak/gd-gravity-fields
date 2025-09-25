@tool
class_name DirectionProvider extends GravityProvider

@export var gravity_direction : Vector3 = Vector3.DOWN:
	set(value):
		gravity_direction = value
		update_gizmos()

func get_custom_gravity(globalBodyPosition : Vector3) -> Vector3:
	return _rotate_by_provider(gravity_direction.normalized() * gravityForce, global_transform)
