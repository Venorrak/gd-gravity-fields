extends GravityBody3D

@export var arrow : ShapeCast3D
	
func _process(delta: float) -> void:
	arrow.target_position = get_custom_gravity().normalized() * 2
	arrow.global_rotation = Vector3.ZERO
