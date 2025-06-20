extends Control
class_name TutorialScreen

@export var show: bool = true
@export var show_everytime: bool = false
@export var tone_recognition: ToneRecognition
@export var save_manager: SaveManager

@export_group("UI")
@export var read_delay: float = 5
@export var detect_tone_delay: float = 1
@export var fade_out_speed: float = 1
@export var continue_wrap: Control
@export var lbl_recognized_tone: Label
@export var piano_hint: TextureRect

var tone_test_passed: bool = false

func _ready() -> void:
	if show == false:
		queue_free()
		
	if save_manager.open_first_time == false and show_everytime == false:
		queue_free()
		
	continue_wrap.modulate.a = 0
		
func _process(delta: float) -> void:
	# Show continue
	if read_delay > 0:
		read_delay -= delta
	else:
		# Show
		if continue_wrap.modulate.a < 1:
			continue_wrap.modulate.a = lerp(continue_wrap.modulate.a, continue_wrap.modulate.a + fade_out_speed, delta)
		
		# Handle tone recognition
		lbl_recognized_tone.text = "Played: " + tone_recognition.current_note + str(tone_recognition.current_octave)
		if  tone_recognition.current_note == "" or tone_recognition.current_octave == 0:
			lbl_recognized_tone.text = "Play"
		
		if detect_tone_delay > 0:
			detect_tone_delay -= delta
			tone_recognition.clear_current_note()
		else:
			if tone_recognition.current_note == "C" and tone_recognition.current_octave == 4:
				tone_test_passed = true
	
	# Fadeout
	if tone_test_passed:
		if modulate.a > 0:
			modulate.a = lerp(modulate.a, modulate.a - fade_out_speed, delta)
		else:
			queue_free()
