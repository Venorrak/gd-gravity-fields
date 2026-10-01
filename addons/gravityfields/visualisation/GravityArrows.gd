@tool
@icon("res://addons/gravityfields/icons/GravityArrows.svg")
class_name GravityArrows extends Node3D

## Helper for visualy seeing the effects of the gravity in the editor. [br]
## Will show arrows pointing in the direction of the gravity. [br]
##
## The following addon is needed for this node to work
##
## [color=yellow][url]https://github.com/DmitriySalnikov/godot_debug_draw_3d[/url][/color]

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
## Single provider that will move the particles
@export var provider: GravityProvider
## The lenght of the arrow will represent the strength of the gravity
@export var representativeLength: bool = false
## Distance between the arrows inside the zone
@export var arrowMargin: float = 5:
	set(value):
		arrowMargin = abs(value)
		_calculateArrowDisposition()
## Size of the zone withing which the arrows will appear
@export var zoneSize: Vector3 = Vector3(10, 10, 10):
	set(value):
		zoneSize = value.abs()
		_calculateArrowDisposition()

var _positions: PackedVector3Array = []
var _directions: PackedVector3Array = []

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if not type_exists("DebugDraw3D"):
		push_error("GravityArrows require the debug_draw_3d addon go to https://github.com/DmitriySalnikov/godot_debug_draw_3d")
		warnings.append("GravityArrows require the debug_draw_3d addon go to https://github.com/DmitriySalnikov/godot_debug_draw_3d")
	return warnings

func _ready() -> void:
	update_configuration_warnings()
	if not type_exists("DebugDraw3D"):
		set_process(false)
		return
	_calculateArrowDisposition()

func _process(delta: float) -> void:
	if not visible or not provider or not enabled: return
	for i in _positions.size():
		var gravity: Vector3 = provider.get_custom_gravity(_positions[i] + global_position)
		DebugDraw3D.draw_arrow_ray(_positions[i] + global_position, gravity.normalized(), gravity.length() if representativeLength else 2, Color.PURPLE, 0.5, true)
	DebugDraw3D.draw_box(global_position, Quaternion(global_basis), zoneSize, Color.RED)
		
func _calculateArrowDisposition() -> void:
	_positions.clear()
	_directions.clear()
	var qty: Vector3 = zoneSize / arrowMargin
	for x in ceili(qty.x):
		for y in ceili(qty.y):
			for z in ceili(qty.z):
				_positions.append(Vector3(
					x * arrowMargin,
					y * arrowMargin,
					z * arrowMargin
				))
