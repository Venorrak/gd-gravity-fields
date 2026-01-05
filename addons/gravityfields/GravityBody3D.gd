@icon("res://addons/gravityfields/GravityBody3D.svg")
class_name GravityBody3D extends RigidBody3D
## RigidBody3D influenced by the custom gravity

## Just like the normal gravity scale but custom. To only rely on custom gravity, set the normal gravity to 0
@export var customGravityScale : float = 1

var _gravityDetectors : Array[GravityDetector] = []

## get_gravity but it's custom, you get it.
func get_custom_gravity() -> Vector3:
	if not _gravityDetectors.is_empty():
		var v : Vector3 = Vector3.ZERO
		for i in _gravityDetectors.size():
			var d = _gravityDetectors[i]
			var p = d.gravityProvider
			match  d.gravity_space_override:
				Area3D.SpaceOverride.SPACE_OVERRIDE_COMBINE:
					v += p.get_custom_gravity(global_position)
				Area3D.SpaceOverride.SPACE_OVERRIDE_COMBINE_REPLACE:
					v += p.get_custom_gravity(global_position)
					if _gravityDetectors[i + 1].priority < d.priority:
						break
				Area3D.SpaceOverride.SPACE_OVERRIDE_REPLACE:
					v = p.get_custom_gravity(global_position)
					break
				Area3D.SpaceOverride.SPACE_OVERRIDE_REPLACE_COMBINE:
					v = p.get_custom_gravity(global_position)
		return v * customGravityScale 
	else:
		return Vector3.ZERO

## List of detectors it is in. Ordered by priority
func get_detectors() -> Array[GravityDetector]:
	return _gravityDetectors

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var gravity = get_custom_gravity()
	state.linear_velocity += gravity * state.step

func _sort_detectors() -> void:
	_gravityDetectors.sort_custom(func(a, b): return a.priority > b.priority)
