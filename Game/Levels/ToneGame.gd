extends Node2D
class_name ToneGameManager

# Game and setup
var game_manager: GameManager
@export var _debug_note_success: bool = false
@export var bpm: float = 100
@export var tones: Array[String]
@export var key = 0
@export var metro: AudioStreamPlayer
@export var tone_recognition: ToneRecognition
@export var scaleManager: ScalesManager
@export var sheet_renderer: SheetRenderer
@export var wait_for_beat: int = 4
@export var beat_offset = 0
var beats_passed: int = 0

var sunriseImage: SunriseImage

# UI
@export_group("UI refs")
@export var gameplay_ui: Control
@export var lbl_current_tone: Label
@export var lbl_score: Label
@export var lbl_repetitions: Label
@export var slider_bpm: Slider
@export var lbl_bpm: Label
@export var lbl_recognized_tone: Label
@export var itemlist_scale_key: ItemList
@export var itemlist_scale_type: ItemList
@export var regognized_tone_ui_delay: float = 0.1
@export var piano_hint: PianoHint
@export var rating_dialog: RatingDialog
var regognized_tone_ui_timer: float = 0

@export_group("Audio")
@export var win_audio_player: AudioStreamPlayer
@export var win_audio_time: float = 2
@export var tone_audio_player: AudioStreamPlayer

var win: bool = false
var running = true
var current_pos = 0
var last_note_hit = -1

var score = 0
var finished_times: int = 0
var furtest_progression: int = 0
var target_progression: int = 0
var reps_to_do: int = 0

var run_metro = true
var bpm_time = 0.0
var bpm_time_count = 0.0

var mistake: bool = false
var mistake_count: int = 0

signal on_scale_progress
signal on_scale_finished
signal on_scale_fail

# Overrides
func _ready() -> void:
	finished_times = 0
	furtest_progression = 0
	
	bpm_time = 60.0 / bpm
	
	slider_bpm.value = bpm
	
	# Setup UI
	itemlist_scale_key.clear()
	for note in MusicConstants.TONE_NAMES:
		itemlist_scale_key.add_item(note)
		
	itemlist_scale_key.select(0)
	
	itemlist_scale_type.clear()
	for type in MusicConstants.EScaleTypes:
		itemlist_scale_type.add_item(type)
	
	itemlist_scale_type.select(0)
	_on_scale_key_list_item_selected(0)
	
	sheet_renderer.set_notes_position(-wait_for_beat - beat_offset)
	sheet_renderer.set_check_area_beat_offset(-beat_offset)

func _process(delta: float) -> void:
	# Back to menu after delay
	if win == true:
		if win_audio_time <= 0:
			game_manager.activate_menu(true)
			print("Progression succesufully finished")
		else:
			win_audio_time -= delta
	
	# Manage run
	if running == false:
		return
				
	# Fix mistake
	if mistake:
		var cur_note:String = tone_recognition.current_note + str(tone_recognition.current_octave)
		if (last_note_hit + 1) == current_pos and cur_note == tones[current_pos]:
			mistake = false
			mistake_count += 1
			run_metro = true
			piano_hint.hide_hint()
			
				
	# Sheets rendered update
	if run_metro:
		sheet_renderer.move_notes(delta)
	if run_metro and sheet_renderer.can_create_new_sequence() and reps_to_do > 1:
		sheet_renderer.create_sequece(tones)
	
	if run_metro:
		run_metronome(delta)
	progression_ui(delta)
		
	# Update sunrise image
	if sunriseImage != null:
		var prog: float = float(furtest_progression) / float(target_progression)
		sunriseImage.set_progress(prog * sunriseImage.stages)

# Custom audio

func run_metronome(delta: float):
	if bpm_time_count < bpm_time:
		bpm_time_count += delta
		# Check tone progression
		if beats_passed >= wait_for_beat:
			tone_progress(delta)
	else:
		sheet_renderer.fix_notes_movement(beats_passed - wait_for_beat)
		metro.stop()
		metro.play()
		bpm_time_count = 0
		beats_passed += 1

func tone_progress(delta: float):
	if bpm_time_count < bpm_time:
		# Check note was hit within current beat
		var cur_note: String = tone_recognition.current_note + str(tone_recognition.current_octave)
		
		var pas: bool = (_debug_note_success == true) or cur_note == tones[current_pos]
		
		if (last_note_hit + 1) == current_pos and \
		pas:
			last_note_hit += 1
			sheet_renderer.tested_note_feedback(true)
			tone_recognition.clear_current_note()
			on_scale_progress.emit()
			
			# Check overall progress
			var finished = finished_times * MusicConstants.PROGRESSIONS[itemlist_scale_type.get_selected_items()[0]].size()
			if (current_pos + finished) > furtest_progression:
				furtest_progression = last_note_hit + finished
				
			
			# Add score for half
			if last_note_hit == (len(tones) / 2.0):
				score += 1
	else:
		# Set next target note
		if last_note_hit == current_pos:
			current_pos += 1
			
			if current_pos == len(tones):
				score += 3
				current_pos = 0
				last_note_hit = -1
				
				finished_times += 1
				reps_to_do -= 1
				on_scale_finished.emit()
				
				# All finished - win
				if reps_to_do <= 0:
					#game_manager.save_active_level_completed()
					win_audio_player.play()
					run_metro = false
					win = true
					
					# Show rating
					gameplay_ui.visible = false
					if rating_dialog.rate(mistake_count) == 1:
						game_manager.save_active_level_completed()

		else:
			# Mistake
			run_metro = false
			mistake = true
			
			piano_hint.show_hint(scaleManager.last_notes_i[current_pos])
			#current_pos -= 1
			#last_note_hit -= 1
			
			beats_passed -= 1
			sheet_renderer.set_notes_position(beats_passed -wait_for_beat - 1)
			
			sheet_renderer.tested_note_feedback(false)
			tone_recognition.clear_current_note()
			on_scale_fail.emit()
			
	
func progression_ui(delta: float):
	lbl_current_tone.text = "Tone: " + tones[current_pos]
	lbl_repetitions.text = "Repetitions: " + str(reps_to_do)
	lbl_score.text = "Score: " + str(score)
	
	# Tone update
	if regognized_tone_ui_timer > 0:
		regognized_tone_ui_timer -= delta
	else:
		lbl_recognized_tone.text = "(" +  str(tone_recognition.current_fq) + " Hz) " + tone_recognition.current_note + str(tone_recognition.current_octave)
		regognized_tone_ui_timer = regognized_tone_ui_delay
	

# UI callbacks
func _on_bpm_slider_value_changed(value: float) -> void:
	bpm = value
	bpm_time = 60.0 / bpm
	lbl_bpm.text = str(bpm)
	sheet_renderer.set_bpm(bpm)

func _on_scale_key_list_item_selected(index: int) -> void:
	var t: int = itemlist_scale_type.get_selected_items()[0]
	tones = scaleManager.generate_scale(itemlist_scale_key.get_item_text(index) , t)
	add_reversed()

func _on_scale_type_list_item_selected(index: int) -> void:
	var k: String = itemlist_scale_key.get_item_text(itemlist_scale_key.get_selected_items()[0])
	tones = scaleManager.generate_scale(k, index)
	add_reversed()

func add_reversed():
	# Add down scale
	var reversed = []
	reversed.append_array(tones)
	reversed.reverse()
	# Cut Key notes from reversed
	reversed.remove_at(reversed.size() - 1)
	reversed.remove_at(0)
	
	tones.append_array(reversed)
	sheet_renderer.clear_sheet()
	sheet_renderer.create_sequece(tones)
	print("Current scale: " + str(tones))

func _on_simple_button_button_down() -> void:
	game_manager.activate_menu(true)
		
