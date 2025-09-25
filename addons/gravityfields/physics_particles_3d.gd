@tool
extends Node3D

@export var detector: GravityDetector

@export var enabled : bool = false:
	set(value):
		enabled = value
		if (is_inside_tree()):
			set_process(value)
@export var nbOfParticles : int = 5:
	set(value):
		nbOfParticles = value
		if (is_inside_tree()):
			_changeNbOfParticles(value)
@export var particleLifetime : float = 5
@export var paritcleSpawnerSize : Vector3 = Vector3(1, 1, 1)
var points : PackedVector3Array = []
var pointsLifetime : PackedFloat32Array = []



func _ready() -> void:
	for i in nbOfParticles:
		_appendParticle()

func _process(delta: float) -> void:
	_updatePoints(delta)
	DebugDraw3D.draw_box(global_position, Quaternion(global_basis), paritcleSpawnerSize, Color.RED)
	DebugDraw3D.draw_points(points, DebugDraw3D.POINT_TYPE_SPHERE, 0.01, Color.PURPLE, delta)

func _updatePoints(delta: float) -> void:
	if not detector or not detector.gravityProvider : return
	var provider = detector.gravityProvider
	for index in points.size():
		if pointsLifetime[index] > 0:
			points.set(index, points[index] + provider.get_custom_gravity(points[index]) * delta)
			pointsLifetime.set(index, pointsLifetime[index] - delta)
		else:
			pointsLifetime.set(index, particleLifetime)
			points.set(index, _randomParticlePosition())

func _appendParticle() -> void:
	points.append(_randomParticlePosition())
	pointsLifetime.append(randf_range(0, particleLifetime))

func _randomParticlePosition() -> Vector3:
	return Vector3(randf_range(0, paritcleSpawnerSize.x), randf_range(0, paritcleSpawnerSize.y), randf_range(0, paritcleSpawnerSize.z)) + global_position

func _changeNbOfParticles(nb : int) -> void:
	var diff : int = nb - points.size()
	if diff > 0:
		points.resize(points.size() + diff)
		pointsLifetime.resize(pointsLifetime.size() + diff)
		for i in diff:
			_appendParticle()
	elif diff < 0:
		points.resize(points.size() + diff)
		pointsLifetime.resize(pointsLifetime.size() + diff)
