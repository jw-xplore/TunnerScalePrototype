extends Node

@export var tone_game_mngr: ToneGameManager
@export var character: ScaleCharacter
@export var moutain_scene: PackedScene
@export var starting_point: Node2D
@export var mountains_offset: float = 25
var current_moutain: ScaleMountain

@export var mouintans_count = 3
var moutains: Array[ScaleMountain]

var current_mountain_id: int = 0

"""
@export var character: Character
@export var current_pyramid: ScalePyramid
"""

func _ready() -> void:
	generate_peaks()
	current_moutain = moutains[0]
	
	if current_moutain.points.size() == 0:
		current_moutain.on_get_points.connect(on_first_mountain_get_points)
	else:
		on_first_mountain_get_points(current_moutain.points)
	
func _process(delta: float) -> void:
	
	if character.current_point_id == current_moutain.points.size() \
	and current_mountain_id < moutains.size() :
		current_mountain_id += 1
		character.set_mouintain(moutains[current_mountain_id], moutains[current_mountain_id-1])

func on_first_mountain_get_points(points):
	character.set_mouintain(current_moutain)
	
	# Connect
	tone_game_mngr.on_scale_progress.connect(on_scale_progress)
	tone_game_mngr.on_scale_finished.connect(on_scale_finished)
	tone_game_mngr.on_scale_fail.connect(on_scale_fail)
	
	# Disconnect
	current_moutain.on_get_points.disconnect(on_first_mountain_get_points)

func on_scale_progress():
	#character.on_scale_progress(current_pyramid.scale_size) 
	character.activate_move()
	
func on_scale_finished():
	pass
	"""
	character.on_scale_fail(current_pyramid.start_point.global_position.x)
	current_pyramid.enable_collisions(false)
	character.on_reach_target_x.connect(on_character_reach_target)
	"""
	
func on_scale_fail():
	character.set_current_point(0, true)
	"""
	character.on_scale_fail(current_pyramid.start_point.global_position.x)
	current_pyramid.enable_collisions(false)
	character.on_reach_target_x.connect(on_character_reach_target)
	"""
	
func on_character_reach_target():
	pass
	"""
	current_pyramid.enable_collisions(true)
	character.on_reach_target_x.disconnect(on_character_reach_target)
	"""

func generate_peaks():
	for i in range(0, mouintans_count):
		var new_mountain: ScalePeak = moutain_scene.instantiate()
		add_child(new_mountain)
		var w: float = (new_mountain.sprite_size + mountains_offset) * i * 2
		new_mountain.global_position = starting_point.global_position + Vector2(w, 0)
		moutains.append(new_mountain)
