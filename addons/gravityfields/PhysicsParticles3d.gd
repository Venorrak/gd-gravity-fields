@tool
@icon("res://addons/gravityfields/PhysicsParticles3D.svg")
class_name PhysicsParticles3D extends Node3D
## Helper particles for visualy seeing the effects of the gravity in the editor
##
## The following addon is needed for this node to work
##
## [color=yellow][url]https://github.com/DmitriySalnikov/godot_debug_draw_3d[/url][/color]

## Single provider that will move the particles
@export var provider: GravityProvider
## Type of particle being drawed
@export var Type : DebugDraw3D.PointType = DebugDraw3D.POINT_TYPE_SQUARE
## Size of the particles
@export var size : float = 0.05
## think about it, what would "enabled" do ?
@export var enabled : bool = false:
	set(value):
		update_configuration_warnings()
		if not type_exists("DebugDraw3D"):
			enabled = false
			return
		enabled = value
		if (is_inside_tree()):
			set_process(value)
## Number of spawed particles
@export var nbOfParticles : int = 50:
	set(value):
		if (value >= 0):
			nbOfParticles = value
			if (is_inside_tree()):
				_changeNbOfParticles(value)
## How long will the particle be alive for ?
@export var particleLifetime : float = 0.5
## Size of the zone withing which the particles will spawn
@export var paritcleSpawnerSize : Vector3 = Vector3(1, 1, 1)
## List of all the positions of the points
var points : PackedVector3Array = []
## List of the time left for each point
var pointsLifetime : PackedFloat32Array = []

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if not type_exists("DebugDraw3D"):
		warnings.append("physics_particles require the debug_draw_3d addon go to https://github.com/DmitriySalnikov/godot_debug_draw_3d")
	return warnings

func _ready() -> void:
	update_configuration_warnings()
	if not type_exists("DebugDraw3D"):
		set_process(false)
		return
	for i in nbOfParticles:
		_appendParticle()

func _process(delta: float) -> void:
	_updatePoints(delta)
	DebugDraw3D.draw_box(global_position, Quaternion(global_basis), paritcleSpawnerSize, Color.RED)
	DebugDraw3D.draw_points(points, Type, size, Color.PURPLE, delta)

func _updatePoints(delta: float) -> void:
	if not provider : return
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
