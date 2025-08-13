@tool
class_name GCurve3D extends Curve3D

@export_category("Gravity")
@export var gravityForce : float = 9.8
@export var multipleFaces : bool = true:
	set(value):
		if value == multipleFaces : return
		multipleFaces = value
		notify_property_list_changed()
var faces : int = 2

func _init() -> void:
	up_vector_enabled = true

func _get_property_list():
	if Engine.is_editor_hint():
		var ret = []
		if multipleFaces:
			ret.append({
				"name": &"faces",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint_string": "2, 360",
				"hint": PROPERTY_HINT_RANGE
			})
		return ret

func get_custom_gravity(local_body_position: Vector3, provider_transform: Transform3D) -> Vector3:
	var gravity: Vector3 = Vector3.DOWN * gravityForce
	var rotated_body_position = rotate_by_provider(local_body_position, provider_transform, true)
	var closest_offset: float = get_closest_offset(rotated_body_position)
	var closest_transform: Transform3D = sample_baked_with_rotation(closest_offset, false, true)
	closest_transform = rotate_by_provider(closest_transform, provider_transform, false)
	# Convert local_body_position to world position for gravity direction
	var body_world_pos = provider_transform.origin + local_body_position
	if multipleFaces:
		var center: Vector3 = closest_transform.origin
		var up: Vector3 = closest_transform.basis.y.normalized()
		var step : float = TAU / faces
		var forward : Vector3 = closest_transform.basis.z.normalized()
		var side : Vector3 = closest_transform.basis.x.normalized()
		
		var to_body: Vector3 = (local_body_position - center)
		
		# Project to_body vector onto the plane orthogonal to forward (remove the forward component)
		var to_body_plane: Vector3 = to_body - forward * to_body.dot(forward)
		to_body_plane = to_body_plane.normalized()

		# Get angle between 'up' and projected vector
		var angle: float = atan2(
			to_body_plane.dot(side),
			to_body_plane.dot(up)
		)

		angle += step / 2
			
		if angle < 0:
			angle += TAU
		
		if angle > TAU:
			angle -= TAU

		var index: int = int(floor(angle / step)) % faces
		#print(index)
		
		var gravity_angle = -step * index
		
		gravity = up.rotated(forward, gravity_angle + PI) * gravityForce
	else:
		gravity = (closest_transform.origin - body_world_pos).normalized() * gravityForce
	return gravity


func rotate_by_provider(input, provider_transform: Transform3D, inverse := false):
	var clean_basis : Basis = provider_transform.basis.orthonormalized()

	if typeof(input) == TYPE_VECTOR3:
		if inverse:
			return clean_basis.inverse() * input
		else:
			return clean_basis * input

	elif typeof(input) == TYPE_TRANSFORM3D:
		var clean_provider : Transform3D = Transform3D(clean_basis, provider_transform.origin)
		if inverse:
			return clean_provider.affine_inverse() * input
		else:
			return clean_provider * input

	else:
		push_error("rotate_by_provider() only supports Vector3 or Transform3D")
		return input
