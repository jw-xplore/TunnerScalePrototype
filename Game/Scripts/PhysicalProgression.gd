extends Node

@export var tone_game_mngr: ToneGameManager
@export var character: Character

@export var current_pyramid: ScalePyramid

func _ready() -> void:
	tone_game_mngr.on_scale_progress.connect(on_scale_progress)
	tone_game_mngr.on_scale_finished.connect(on_scale_finished)
	tone_game_mngr.on_scale_fail.connect(on_scale_fail)

func on_scale_progress():
	character.on_scale_progress(current_pyramid.scale_size) 
	
func on_scale_finished():
	character.on_scale_fail(current_pyramid.start_point.global_position.x)
	current_pyramid.enable_collisions(false)
	character.on_reach_target_x.connect(on_character_reach_target)
	
func on_scale_fail():
	character.on_scale_fail(current_pyramid.start_point.global_position.x)
	current_pyramid.enable_collisions(false)
	character.on_reach_target_x.connect(on_character_reach_target)
	
func on_character_reach_target():
	current_pyramid.enable_collisions(true)
	character.on_reach_target_x.disconnect(on_character_reach_target)
