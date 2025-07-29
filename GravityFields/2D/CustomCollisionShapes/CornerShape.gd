@tool
extends CollisionPolygon2D
class_name CornerCollisionShape2D

@export var length : float = 1:
	set(value):
		length = value
		updatePolygon()
@export var width : float = 1:
	set(value):
		width = value
		updatePolygon()
var radiant = 1
@export_range(0.0, 360.0, 0.01) var degree : float = 0:
	set(newDegree):
		degree = newDegree
		radiant = degree * 0.01745329
		updatePolygon()
@export var sampling : int = 10:
	set(value):
		sampling = value
		updatePolygon()

func updatePolygon() -> void:
	var points : PackedVector2Array = []
	if radiant == 0.0:
		polygon = [
			Vector2(0, -width/2),
			Vector2(length, -width/2),
			Vector2(length, width/2),
			Vector2(0, width/2)
		]
	for i in sampling + 1:
		var theta = radiant * i / sampling
		points.append(Vector2((length / 2) * cos(theta), (length / 2) * sin(theta)))
	for i in range(sampling, -1, -1):
		var theta = radiant * i / sampling
		points.append(Vector2((length / 2) * cos(theta), (length / 2) * sin(theta)) * width)
	polygon = points
