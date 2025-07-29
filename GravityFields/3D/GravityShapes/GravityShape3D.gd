@tool
extends Resource
class_name GravityShape3D

signal updateShape

func getShapes(rotation: Vector3) -> Array[Dictionary]:
	return []
	
#{
#	"point_direction" : Vector3,
#	"shape": PackedVector3Array,
#	"gravityFalloff": float | null #if null means that it's a direction
#}

# path : array of points with rotation 
# parallel
# sandwish
