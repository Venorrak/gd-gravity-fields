@tool
class_name GravityBody3D extends RigidBody3D

@export var customGravityScale : float = 1

var _gravityProvider = null
var _providerPriority : int = -1
func _init() -> void:
	gravity_scale = 0

func get_custom_gravity() -> Vector3:
	if _gravityProvider:
		return _gravityProvider.get_custom_gravity(global_position) * customGravityScale
	else:
		return Vector3.ZERO

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var gravity = get_custom_gravity()
	state.linear_velocity += gravity * state.step
