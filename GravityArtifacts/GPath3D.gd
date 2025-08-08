class_name GPath3D extends Path3D

func get_gravity(bodyPosition : Vector3) -> Vector3:
	return curve.get_gravity(global_position - bodyPosition)
