@tool
extends Resource
class_name GravityShape2D

signal updateShape

func getShapes(rotation: float) -> Array[Dictionary]:
	return []

#{
#	"point_direction" : Vector2,
#	"shape": PackedVector2Array,
#	"gravityFalloff": float | null #if null means that it's a direction
#}
