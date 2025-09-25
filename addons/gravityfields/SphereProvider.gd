@tool
@icon("res://addons/gravityfields/SphereProvider.svg")
class_name SphereProvider extends GravityProvider
## Gravity provider for spheres

## Get the custom gravity vector
func get_custom_gravity(globalBodyPosition : Vector3) -> Vector3:
	var gravity : Vector3 = Vector3.DOWN * gravityForce
	gravity = (global_position - globalBodyPosition).normalized() * gravityForce
	return gravity
