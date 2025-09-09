@tool
class_name GravityBody3D extends RigidBody3D

@export var customGravityScale : float = 1

var _gravityProviders : Array = []
# { "provider": object, "detector": object}
func _init() -> void:
	gravity_scale = 0

func get_custom_gravity() -> Vector3:
	if not _gravityProviders.is_empty():
		var v : Vector3 = Vector3.ZERO
		for i in _gravityProviders.size():
			var p = _gravityProviders[i]
			match  p["detector"].gravity_space_override:
				Area3D.SpaceOverride.SPACE_OVERRIDE_COMBINE:
					v += p["provider"].get_custom_gravity(global_position)
				Area3D.SpaceOverride.SPACE_OVERRIDE_COMBINE_REPLACE:
					v += p["provider"].get_custom_gravity(global_position)
					if _gravityProviders[i + 1]["detector"].priority < p["detector"].priority:
						break
				Area3D.SpaceOverride.SPACE_OVERRIDE_REPLACE:
					v = p["provider"].get_custom_gravity(global_position)
					break
				Area3D.SpaceOverride.SPACE_OVERRIDE_REPLACE_COMBINE:
					v = p["provider"].get_custom_gravity(global_position)
		return v * customGravityScale 
	else:
		return Vector3.ZERO

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var gravity = get_custom_gravity()
	state.linear_velocity += gravity * state.step

func _sort_providers() -> void:
	_gravityProviders.sort_custom(func(a, b): return a["detector"].priority > b["detector"].priority)
