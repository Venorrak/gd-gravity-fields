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

func get_custom_gravity(bodyPosition : Vector3, providerRotation: Vector3) -> Vector3:
	var gravity : Vector3 = Vector3.DOWN * gravityForce
	var rotatedBodyPosition = rotateByProvider(bodyPosition, providerRotation * -1)
	var closestOffset : float = get_closest_offset(rotatedBodyPosition)
	var closestTransform : Transform3D = sample_baked_with_rotation(closestOffset, false, true)
	closestTransform = rotate_transform_by_provider(closestTransform, providerRotation)
	if multipleFaces:
		var center: Vector3 = closestTransform.origin
		var up: Vector3 = closestTransform.basis.y.normalized()
		var step : float = TAU / faces
		var forward : Vector3 = closestTransform.basis.z.normalized()
		var side : Vector3 = closestTransform.basis.x.normalized()
		
		var to_body: Vector3 = (bodyPosition - center)
		
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
		gravity = (closestTransform.origin - bodyPosition).normalized() * gravityForce
	return gravity

func rotateByProvider(input, gRotation: Vector3):
	input = input.rotated(Vector3(0, 1, 0), gRotation.y)
	input = input.rotated(Vector3(1, 0, 0), gRotation.x)
	input = input.rotated(Vector3(0, 0, 1), gRotation.z)
	return input

# TODO https://docs.godotengine.org/en/stable/tutorials/plugins/editor/3d_gizmos.html
