@tool
class_name GPath3D extends Path3D

func get_custom_gravity(bodyPosition : Vector3) -> Vector3:
	return curve.get_custom_gravity(bodyPosition - global_position, global_transform)
