@tool
class_name GravityPath3D extends Path3D

func get_custom_gravity(bodyPosition : Vector3) -> Vector3:
	## bodyPosition : global_position of the gravityBody
	return curve.get_custom_gravity(bodyPosition - global_position, global_transform)
