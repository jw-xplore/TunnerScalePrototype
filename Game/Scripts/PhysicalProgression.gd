extends Node

@export var tone_game_mngr: ToneGameManager
@export var character: ScaleCharacter
var current_moutain: ScaleMountain

@export var moutains: Array[ScaleMountain]

var current_mountain_id: int = 0

var mouintain_end = 8 # Works only for octave scales

"""
@export var character: Character
@export var current_pyramid: ScalePyramid
"""

func _ready() -> void:
	tone_game_mngr.on_scale_progress.connect(on_scale_progress)
	tone_game_mngr.on_scale_finished.connect(on_scale_finished)
	tone_game_mngr.on_scale_fail.connect(on_scale_fail)
	
	current_moutain = moutains[0]
	
func _process(delta: float) -> void:
	print("character.current_point_id: " + str(character.current_point_id))
	if character.current_point_id == mouintain_end \
	and current_mountain_id < moutains.size():
		current_mountain_id += 1
		character.set_mouintain(moutains[current_mountain_id])
	
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
