@tool
class_name SphereProvider extends GravityProvider

func get_custom_gravity(globalBodyPosition : Vector3) -> Vector3:
	var gravity : Vector3 = Vector3.DOWN * gravityForce
	gravity = (global_position - globalBodyPosition).normalized() * gravityForce
	return gravity
