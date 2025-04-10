extends StaticBody2D
class_name ScalePyramid

@export var scale_size: float = 64
@export var start_point: Node2D
@export var collision: CollisionPolygon2D

func enable_collisions(enable: bool):
	collision.disabled = !enable
