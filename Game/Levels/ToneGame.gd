extends Node2D
class_name ToneGameManager

# Game and setup
@export var bpm: float = 100
@export var tones: Array[String]
@export var key = 0
@export var metro: AudioStreamPlayer
@export var tone_recognition: ToneRecognition
#@export var character: Character
@export var scaleManager: ScalesManager
@export var sheet_renderer: SheetRenderer

# UI
@export var lbl_current_tone: Label
@export var lbl_score: Label
@export var slider_bpm: Slider
@export var lbl_bpm: Label
@export var itemlist_scale_key: ItemList
@export var itemlist_scale_type: ItemList

var running = true
var current_pos = 0
var last_note_hit = -1

var score = 0

var run_metro = true
var bpm_time = 0.0
var bpm_time_count = 0.0

signal on_scale_progress
signal on_scale_finished
signal on_scale_fail

# Overrides

func _ready() -> void:
	bpm_time = 60.0 / bpm
	
	slider_bpm.value = bpm
	
	# Setup UI
	itemlist_scale_key.clear()
	for note in scaleManager.note_names:
		itemlist_scale_key.add_item(note)
		
	itemlist_scale_key.select(0)
	
	itemlist_scale_type.clear()
	for type in scaleManager.EScaleTypes:
		itemlist_scale_type.add_item(type)
	
	itemlist_scale_type.select(0)
	_on_scale_key_list_item_selected(0)

func _process(delta: float) -> void:
	if running == false:
		return
		
	if run_metro:
		run_metronome(delta)
	progression_ui()

# Custom audio

func run_metronome(delta: float):
	if bpm_time_count < bpm_time:
		bpm_time_count += delta
		tone_progress(delta)
	else:
		metro.play()
		bpm_time_count = 0

func tone_progress(delta: float):
	if bpm_time_count < bpm_time:
		# Check note was hit within current beat
		var cur_note = tone_recognition.current_note + str(tone_recognition.current_octave)
		
		if (last_note_hit + 1) == current_pos and \
		cur_note == tones[current_pos]:
			last_note_hit += 1
			on_scale_progress.emit()
			
			# Add score for half
			if last_note_hit == (len(tones) / 2):
				score += 1
	else:
		# Set next target note
		if last_note_hit == current_pos:
			current_pos += 1
			
			if current_pos == len(tones):
				score += 3
				current_pos = 0
				last_note_hit = -1
				on_scale_finished.emit()
				
				# Restart pos
				#run_metro = false
				#character.on_reach_target_x.connect(on_character_reach_target)
		else:
			# Restart if failed
			current_pos = 0
			last_note_hit = -1
				
			tone_recognition.clear_current_note()
			on_scale_fail.emit()
			
			# Restart pos
			#run_metro = false
			#character.on_reach_target_x.connect(on_character_reach_target)
			

func progression_ui():
	lbl_current_tone.text = "Play note: " + tones[current_pos]
	lbl_score.text = "Score: " + str(score)
	
	# Show success color
	if current_pos == last_note_hit:
		lbl_current_tone.modulate = Color.LIME_GREEN
	else:
		lbl_current_tone.modulate = Color.WHITE
	
# Character callback
func on_character_reach_target():
	run_metro = true
	#character.on_reach_target_x.disconnect(on_character_reach_target)
	tone_recognition.clear_current_note()

# UI callbacks
func _on_bpm_slider_value_changed(value: float) -> void:
	bpm = value
	bpm_time = 60.0 / bpm
	lbl_bpm.text = str(bpm)


func _on_scale_key_list_item_selected(index: int) -> void:
	var type: ScalesManager.EScaleTypes = itemlist_scale_type.get_selected_items()[0]
	tones = scaleManager.generate_scale(itemlist_scale_key.get_item_text(index) , ScalesManager.EScaleTypes.Major)
	
	var reversed = []
	reversed.append_array(tones)
	reversed.reverse()
	tones.append_array(reversed)
	sheet_renderer.create_sequece(tones)
	print("Current scale: " + str(tones))

func _on_scale_type_list_item_selected(index: int) -> void:
	var key: String = itemlist_scale_key.get_item_text(itemlist_scale_key.get_selected_items()[0])
	tones = scaleManager.generate_scale(key, index)
	
	var reversed = []
	reversed.append_array(tones)
	reversed.reverse()
	tones.append_array(reversed)
	sheet_renderer.create_sequece(tones)
	print("Current scale: " + str(tones))
