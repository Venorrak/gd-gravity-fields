class_name GravityBody3D extends RigidBody3D

@export var customGravityScale : float = 1

var gravityProvider = null
func _init() -> void:
	gravity_scale = 0

func get_custom_gravity() -> Vector3:
	if gravityProvider:
		return gravityProvider.get_custom_gravity(global_position) * customGravityScale
	else:
		return Vector3.ZERO

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var gravity = get_custom_gravity()
	state.linear_velocity += gravity * state.step
