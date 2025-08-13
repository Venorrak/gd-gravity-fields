@tool
class_name GravityPoint3D extends Marker3D

@export var gravityForce : float = 9.8

func get_custom_gravity(bodyPosition : Vector3) -> Vector3:
	var gravity : Vector3 = Vector3.DOWN * gravityForce
	gravity = (global_position - bodyPosition).normalized() * gravityForce
	return gravity
