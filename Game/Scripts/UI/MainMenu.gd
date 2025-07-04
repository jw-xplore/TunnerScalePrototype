extends Control
class_name MainMenu

@export var lbl_key: Label
@export var lbl_type: Label
@export var game_manager: GameManager
@export var level_buttons_holder: Control
@export var piano_hint: PianoHint
@export var scale_manager: ScalesManager

@export_group("Audio")
@export var audio_player: AudioStreamPlayer
@export var tones_sounds: Array[AudioStream]

var current_key: int = 0
var current_type: int = 0
var level_buttons = []

func _ready() -> void:
	lbl_key.text = MusicConstants.TONE_NAMES[current_key]
	lbl_type.text = MusicConstants.PROGRESSION_NAMES[current_type]
	level_buttons = level_buttons_holder.get_children()
	
	update_finished_levels()
	
# Key selection
func _on_btn_key_left_button_down() -> void:
	if current_key <= 0:
		current_key = MusicConstants.TONES_COUNT - 1
	else:
		current_key -= 1
		
	lbl_key.text = MusicConstants.TONE_NAMES[current_key]
	
	update_finished_levels()
	# Audio
	play_current_tone()

func _on_btn_key_right_button_down() -> void:
	if current_key >= MusicConstants.TONES_COUNT - 1:
		current_key = 0
	else:
		current_key += 1
		
	lbl_key.text = MusicConstants.TONE_NAMES[current_key]
	
	update_finished_levels()
	# Audio
	play_current_tone()

# Type selection
func _on_btn_type_left_button_down() -> void:
	if current_type <= 0:
		current_type = MusicConstants.PROGRESSION_NAMES.size() - 1
	else:
		current_type -= 1
		
	lbl_type.text = MusicConstants.PROGRESSION_NAMES[current_type]
	
	update_finished_levels()

func _on_btn_type_right_button_down() -> void:
	if current_type >= MusicConstants.PROGRESSION_NAMES.size() - 1:
		current_type = 0
	else:
		current_type += 1
		
	lbl_type.text = MusicConstants.PROGRESSION_NAMES[current_type]
	
	update_finished_levels()

# Select difficulty level
func _on_btn_easy_button_down() -> void:
	start_game(0)

func _on_btn_medium_button_down() -> void:
	start_game(1)

func _on_btn_hard_button_down() -> void:
	start_game(2)

func start_game(difficulty: int):
	game_manager.activate_menu(false)
	var dif = Difficulties.LEVELS[difficulty]
	game_manager.setup_game(dif[0], dif[1], current_key, current_type, difficulty)
	# Audio
	play_current_tone()

func update_finished_levels():
	var key = MusicConstants.TONE_NAMES[current_key]
	var type = MusicConstants.PROGRESSION_NAMES[current_type]
	
	# Show hint
	var proggression: Array[int] = scale_manager.generate_scale_changes(key, current_type)
	piano_hint.show_hint_proggression(proggression)
	
	# Show completed
	var completed: bool = false
	
	for i in range(0, level_buttons.size()):
		completed = game_manager.save_manager.is_completed(key, type, i)
		level_buttons[i].display_highligh(completed)

func play_current_tone():
	audio_player.stream = tones_sounds[current_key]
	audio_player.play()

func get_current_tone() -> AudioStream:
	return tones_sounds[current_key]

# Link to feedback form
func _on_feedback_button_button_down() -> void:
	pass # Replace with function body.
