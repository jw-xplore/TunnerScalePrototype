extends Control
class_name MainMenu

@export var lbl_key: Label
@export var lbl_type: Label
@export var game_manager: GameManager

var current_key = 0
var current_type = 0

func _ready() -> void:
	lbl_key.text = MusicConstants.TONE_NAMES[current_key]
	lbl_type.text = MusicConstants.PROGRESSION_NAMES[current_type]
	
# Key selection
func _on_btn_key_left_button_down() -> void:
	if current_key <= 0:
		current_key = MusicConstants.TONES_COUNT - 1
	else:
		current_key -= 1
		
	lbl_key.text = MusicConstants.TONE_NAMES[current_key]

func _on_btn_key_right_button_down() -> void:
	if current_key >= MusicConstants.TONES_COUNT - 1:
		current_key = 0
	else:
		current_key += 1
		
	lbl_key.text = MusicConstants.TONE_NAMES[current_key]

# Type selection
func _on_btn_type_left_button_down() -> void:
	if current_type <= 0:
		current_type = MusicConstants.PROGRESSION_NAMES.size() - 1
	else:
		current_type -= 1
		
	lbl_type.text = MusicConstants.PROGRESSION_NAMES[current_type]

func _on_btn_type_right_button_down() -> void:
	if current_type >= MusicConstants.PROGRESSION_NAMES.size() - 1:
		current_type = 0
	else:
		current_type += 1
		
	lbl_type.text = MusicConstants.PROGRESSION_NAMES[current_type]

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
	game_manager.setup_game(dif[0], dif[1], current_key, current_type)
