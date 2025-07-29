extends RigidBody2D
@export var speed : float

func _process(delta: float) -> void:
	var direction : float = Input.get_axis("ui_left", "ui_right")
	var push : Vector2 = Vector2(speed * direction, 0)
	var appliedGravity : Vector2 = get_gravity()
	constant_force = push.rotated(appliedGravity.angle() - PI/2)
	#print(appliedGravity)
