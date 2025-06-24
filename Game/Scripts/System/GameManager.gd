extends Node
class_name GameManager

@export var menu: MainMenu
@export var game_scene: PackedScene
@export var sunrise_image: SunriseImage
@export var save_manager: SaveManager
@export var tone_recognition: ToneRecognition

var tone_game: ToneGameManager
var active_level: String
@export var lbl_fps: Label

func _ready() -> void:
	set_physics_process(false)
	# Permisions
	var permissions
	if Engine.has_singleton("AndroidPermissions"):
		permissions = Engine.get_singleton("AndroidPermissions")
		permissions.init(get_instance_id(), false)
		
	if permissions != null and !permissions.isRecordAudioPermissionGranted():
		permissions.requestRecordAudioPermission()
	
	# Run menu
	activate_menu(true)
	
func _process(delta: float) -> void:
	# Update image based on menu
	if menu.visible == true:
		if save_manager.levels_count > 0:
			var comp = save_manager.completed_count
			var total = save_manager.levels_count
			var prog = (float(comp) / float(total))
			sunrise_image.set_progress(prog * sunrise_image.stages)
	else:
		pass
		#sunrise_image.set_progress(tone_game.pr)
	
	lbl_fps.text = "FPS: " + str(Engine.get_frames_per_second())
	
func activate_menu(menu_active: bool):
	# Menu
	menu.visible = menu_active
	menu.set_process(menu_active)
	menu.update_finished_levels()
	
	# Remove game
	if menu_active and tone_game != null:
		tone_game.queue_free()
		tone_game = null
		#sunrise_image.set_progress(0)
		deactivate_recording()
		
	# Game
	if not menu_active:
		activate_recording()
		tone_game = game_scene.instantiate()
		tone_game.tone_recognition = tone_recognition
		tone_game.sunriseImage = sunrise_image
		tone_game.game_manager = self
		add_child(tone_game)
		
func activate_recording():
	# Setup bus effects
	var idx := AudioServer.get_bus_index("Record")
	var effect = AudioServer.get_bus_effect(idx, 0)
	effect.set_recording_active(false) # Just in case it's already running
	AudioServer.set_bus_effect_enabled(idx, 0, false)
	await get_tree().create_timer(0.1).timeout # Give it a moment

	effect.set_recording_active(true)
	AudioServer.set_bus_effect_enabled(idx, 0, true)	
	
func deactivate_recording():
	var bus_idx := AudioServer.get_bus_index("Record")
	var effect := AudioServer.get_bus_effect(bus_idx, 0) as AudioEffectRecord

	effect.set_recording_active(false)
	AudioServer.set_bus_effect_enabled(bus_idx, 0, false)

func setup_game(bpm: int, repetitions: int, key: int, type: int, lvl_id: int):
	tone_game.slider_bpm.value = bpm
	var reps = (MusicConstants.PROGRESSIONS[type].size() * 2 -2) * repetitions
	tone_game.target_progression = reps
	tone_game.reps_to_do = repetitions
	
	tone_game.itemlist_scale_key.select(key)
	tone_game.itemlist_scale_type.select(type)
	#tone_game._on_scale_key_list_item_selected(key)
	#tone_game._on_scale_type_list_item_selected(type)
	
	tone_game.tone_audio_player.stream = menu.get_current_tone()

	# Current level
	active_level = save_manager.save_name_format(MusicConstants.TONE_NAMES[key], MusicConstants.PROGRESSION_NAMES[type], lvl_id)

func save_active_level_completed():
	save_manager.save_progress(active_level, true)
