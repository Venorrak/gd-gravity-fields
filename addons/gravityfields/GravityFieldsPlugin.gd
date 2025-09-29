@tool
extends EditorPlugin

const shapeProviderGizmo = preload("res://addons/gravityfields/ShapeProviderGizmo.gd")
const sphereProviderGizmo = preload("res://addons/gravityfields/SphereProviderGizmo.gd")
const directionProviderGizmo = preload("res://addons/gravityfields/DirectionProviderGizmo.gd")
var gizmo1 = shapeProviderGizmo.new()
var gizmo2 = sphereProviderGizmo.new()
var gizmo3 = directionProviderGizmo.new()

func _enter_tree():
	add_node_3d_gizmo_plugin(gizmo1)
	add_node_3d_gizmo_plugin(gizmo2)
	add_node_3d_gizmo_plugin(gizmo3)

func _exit_tree():
	remove_node_3d_gizmo_plugin(gizmo1)
	remove_node_3d_gizmo_plugin(gizmo2)
	remove_node_3d_gizmo_plugin(gizmo3)
