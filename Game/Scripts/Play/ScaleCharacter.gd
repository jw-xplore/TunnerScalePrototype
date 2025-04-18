extends Node2D
class_name ScaleCharacter

var mountain: ScaleMountain
@export var move_curve: Curve
@export var move_down_curve: Curve
@export var speed_curve: Curve
@export var anim_speed: float = 1

var current_point: Node2D
var next_point: Node2D
var current_point_id: int = 0
var pos: float = 0 # 0 = at current point, 1 = arrived at next point
var is_moving = false

func _ready() -> void:
	pass
	#set_mouintain(mountain)
	
func _process(delta: float) -> void:
	move_to_next_point(delta)
	
func set_mouintain(sc_mountain: ScaleMountain, prev_mountain: ScaleMountain = null):
	mountain = sc_mountain
	
	if prev_mountain == null:
		set_current_point(0, true)
		return
	
	# Traverse between mountains
	current_point = prev_mountain.get_point(pos)
	next_point = mountain.get_point(0)
	pos = 0
	current_point_id = 0
	
func move_to_next_point(delta: float):
	# Ingore if is at next point
	
	if next_point == null:
		return
	
	if not is_moving or pos > 1:
		return
	
	# Move
	pos += delta * anim_speed * speed_curve.sample(pos)
	
	var start = current_point.global_position
	var targ = next_point.global_position
	
	var y_move = 0
	if current_point.global_position.y - next_point.global_position.y < 0:
		y_move = move_down_curve.sample(pos)
	else:
		y_move = move_curve.sample(pos)
	
	var x = pos * (targ.x - start.x) + start.x
	var y = y_move * (targ.y - start.y) + start.y
	#var y = global_position.y
	global_position = Vector2(x, y)
	
	# Reached
	if pos >= 1:
		set_current_point(current_point_id + 1)
		"""
		if not mountain.is_end(next_point):
			set_current_point(current_point_id + 1)
		else:
			current_point_id += 1
			current_point = mountain.get_point(current_point_id)
		"""
			
		is_moving = false
		pos = 0

func activate_move(move = true):
	is_moving = move

func set_current_point(point_id: int, teleport = false):
	# Move to next
	pos = 0
	current_point_id = point_id
	if point_id + 1 < mountain.points.size():
		current_point = mountain.get_point(point_id)
		next_point = mountain.get_point(point_id + 1)
	else:
		current_point = mountain.get_point(point_id)
		next_point = mountain.get_point(point_id)
	
	if teleport:
		global_position = current_point.global_position
