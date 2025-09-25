@tool
class_name ShapeProvider extends GravityProvider

@export var curve : Curve3D = Curve3D.new()
@export var multipleFaces : bool = true:
	set(value):
		if value == multipleFaces : return
		multipleFaces = value
		update_gizmos()
		notify_property_list_changed()
var faces : int = 4:
	set(value):
		faces = value
		update_gizmos()
var peak : bool = false:
	set(value):
		if value == peak : return
		peak = value
		notify_property_list_changed()
var height: float = 0
var radius: float = 0
	
func _ready() -> void:
	curve.changed.connect(update_gizmos)

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
			ret.append({
				"name": &"peak",
				"type": TYPE_BOOL,
				"usage": PROPERTY_USAGE_DEFAULT,
			})
			if peak:
				ret.append({
					"name": &"height",
					"type": TYPE_FLOAT,
					"usage": PROPERTY_USAGE_DEFAULT
				})
				ret.append({
					"name": &"radius",
					"type": TYPE_FLOAT,
					"usage": PROPERTY_USAGE_DEFAULT
				})
		return ret

func get_custom_gravity(globalBodyPosition : Vector3) -> Vector3:
	if not curve : return Vector3.ZERO
	if curve.point_count < 2 : return Vector3.ZERO
	
	var local_body_position : Vector3 = globalBodyPosition - global_position
	
	var gravity: Vector3 = Vector3.DOWN * gravityForce
	var rotated_body_position = _rotate_by_provider(local_body_position, global_transform, true)
	var closest_offset: float = curve.get_closest_offset(rotated_body_position)
	var closest_transform: Transform3D = curve.sample_baked_with_rotation(closest_offset, false, true)
	closest_transform = _rotate_by_provider(closest_transform, global_transform, false)
	# Convert local_body_position to world position for gravity direction
	var body_world_pos = global_transform.origin + local_body_position
	if multipleFaces:
		var center: Vector3 = closest_transform.origin
		var up: Vector3 = closest_transform.basis.y.normalized()
		var step : float = TAU / faces
		var forward : Vector3 = closest_transform.basis.z.normalized()
		var side : Vector3 = closest_transform.basis.x.normalized()
		
		var to_body: Vector3 = (body_world_pos - center)
		
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
		
		var gravity_angle = -step * index
		gravity = up.rotated(forward, gravity_angle + PI) * gravityForce
		if peak:
			var b : Basis = Basis()
			# use vector.cross() here 
			b = b.looking_at(forward.normalized(), gravity.normalized())
			gravity = gravity.rotated(b.x.normalized(), -atan2(height, radius))
	else:
		gravity = (closest_transform.origin - body_world_pos).normalized() * gravityForce
	return gravity
