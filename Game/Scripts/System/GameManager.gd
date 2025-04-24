extends Node
class_name GameManager

@export var menu: MainMenu
@export var game_scene: PackedScene
@export var sunrise_image: SunriseImage

var tone_game: ToneGameManager

func _ready() -> void:
	# Permisions
	var permissions
	if Engine.has_singleton("AndroidPermissions"):
		permissions = Engine.get_singleton("AndroidPermissions")
		permissions.init(get_instance_id(), false)
		
	if permissions != null and !permissions.isRecordAudioPermissionGranted():
		permissions.requestRecordAudioPermission()
	
	# Run menu
	activate_menu(true)
	
func activate_menu(menu_active: bool):
	# Menu
	menu.visible = menu_active
	menu.set_process(menu_active)
	
	# Remove game
	if menu_active and tone_game != null:
		tone_game.queue_free()
		tone_game = null
		sunrise_image.set_progress(0)
		deactivate_recording()
		
	# Game
	if not menu_active:
		activate_recording()
		tone_game = game_scene.instantiate()
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

func setup_game(bpm: int, repetitions: int, key: int, type: int):
	tone_game.slider_bpm.value = bpm
	var reps = (MusicConstants.PROGRESSIONS[type].size() * 2 -2) * repetitions
	tone_game.target_progression = reps
	tone_game.reps_to_do = repetitions
	
	tone_game.itemlist_scale_key.select(key)
	tone_game.itemlist_scale_type.select(type)
	tone_game._on_scale_key_list_item_selected(key)
	tone_game._on_scale_type_list_item_selected(type)
