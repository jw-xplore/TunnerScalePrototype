extends CharacterBody2D
class_name Character

@export var speed = 1200
@export var speed_slowdown = 200
@export var jump_speed = -1800
@export var gravity = 4000
@export var rot_speed = 5
@export var move_left = 64

var current_rotation = 0
var target_x = 0

signal on_reach_target_x

func _ready() -> void:
	target_x = position.x

func _physics_process(delta):
	# Add gravity every frame
	velocity.y += gravity * delta
	
	# Rotate
	if current_rotation < 0:
		$Sprite.rotation += rot_speed * delta
		current_rotation += rot_speed * delta
	else:
		velocity.x = 0
		$Sprite.rotation = 0
		current_rotation = 0
		
	# Move
	var change = target_x - position.x
	if abs(target_x - position.x) < 5:
		position.x = target_x
		on_reach_target_x.emit()
	else:
		position.x += sign(target_x - position.x) * speed * delta
	
	move_and_slide()
	
		
func on_scale_progress(move: float):
	velocity.y = jump_speed
	current_rotation = -PI * 0.5
	target_x = target_x + move
	#current_movement -= move_left

func on_scale_fail(pos: float):
	target_x = pos
