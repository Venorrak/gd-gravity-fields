class_name DVector3

var x: float
var y: float
var z: float

func _init(vec : Vector3):
	x = float(vec.x)
	y = float(vec.y)
	z = float(vec.z)

func add(v: DVector3) -> DVector3:
	x = x + v.x
	y = y + v.y
	z = z + v.z
	return self

func scale(s: float) -> DVector3:
	x = x * s
	y = y * s
	z = z * s
	return self

func dot(v: DVector3) -> float:
	return x * v.x + y * v.y + z * v.z

func length() -> float:
	return sqrt(x * x + y * y + z * z)

func normalized() -> Vector3:
	var len = length()
	if len == 0.0:
		return Vector3(0.0, 0.0, 0.0) # Prevent division by zero
	return Vector3(x / len, y / len, z / len)

func rotated(quat: Quaternion) -> DVector3:
	# Manual quaternion rotation math with doubles
	var qx = quat.x
	var qy = quat.y
	var qz = quat.z
	var qw = quat.w

	var ix = qw * x + qy * z - qz * y
	var iy = qw * y + qz * x - qx * z
	var iz = qw * z + qx * y - qy * x
	var iw = -qx * x - qy * y - qz * z


	x = ix * qw + iw * -qx + iy * -qz - iz * -qy
	y = iy * qw + iw * -qy + iz * -qx - ix * -qz
	z = iz * qw + iw * -qz + ix * -qy - iy * -qx
	return self

func to_vector3() -> Vector3:
	# Convert back to Godot's Vector3 for rendering/physics
	return Vector3(x, y, z)

func to_vector3_rounded(decimals: int = 5) -> Vector3:
	var factor = pow(10.0, decimals)
	var rx = floor(x * factor + 0.5) / factor
	var ry = floor(y * factor + 0.5) / factor
	var rz = floor(z * factor + 0.5) / factor
	return Vector3(rx, ry, rz)
