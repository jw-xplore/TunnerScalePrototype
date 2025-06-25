@tool
extends Control
class_name SheetRenderer

@export var tone_game: ToneGameManager

@export_group("Properties")
@export var line_space: float = 25
@export var note_distance: float = 100
@export var fade_size: float = 250

@export_group("Sheet assets")
@export var line_scene: PackedScene
@export var note_quarter_scene: PackedScene

@export_group("Node references")
@export var lines_holder: Control
@export var notes_holder: Control
@export var check_area: Control

@export_group("Positions")
@export var remove_note_position: float = -200
@export var new_sequence_position: float = 200

var note_names = ['C', 'D', 'E', 'F', 'G', 'A', 'B']
var lowest_position_treble_c4 = 10
const OCTAVE_DISTANCE = 7
var half_step: float = 0

var tested_note: Control
var last_note: Control
var last_note_pos_x: float = 0
var leading_note_id: int = 0
var leading_note: Control
var move_per_sec: float

func _ready() -> void:
	half_step = line_space * 0.5
	
	# Create line base
	for i in range(0, 5):
		var line: Control = line_scene.instantiate()
		lines_holder.add_child(line)
		
		line.position = Vector2(0, i * line_space)
		
func _process(delta: float) -> void:
	# Process note visibility
	for note in notes_holder.get_children():
		if note.global_position.x > fade_size:
			note.modulate.a = (fade_size - (note.global_position.x - fade_size)) / fade_size
		
	# Remove notes if too left
	"""
	for note in notes_holder.get_children():
		if note.global_position.x < remove_note_position:
			notes_holder.remove_child(note)
			note.queue_free()
			break;
	"""
		
func create_sequece(notes: Array[String]):
	for note in notes:
		if note.length() == 2:
			create_note(note[0], int(note[1]))
		elif note.length() == 3: # Sharps
			create_note(note.substr(0, 2), int(note[2]))
		
func create_note(note: String, octave: int, note_obj: Control = null):
	var pos: int = note_names.find(note[0])
	if pos == -1:
		return
		
	# Create note
	if note_obj == null:
		note_obj = note_quarter_scene.instantiate()
		notes_holder.add_child(note_obj)
	
	if leading_note == null:
		leading_note = note_obj
		leading_note_id = 0
	
	# Position and scale
	last_note_pos_x += note_distance
	var octave_position: float = (octave - 4) * half_step * OCTAVE_DISTANCE
	var y: float = lowest_position_treble_c4 * half_step - pos * half_step - octave_position
	note_obj.position.x = last_note_pos_x
	note_obj.position.y = y
	
	# Negative scale to rotate note
	if y < half_step * 5:
		note_obj.get_node("NoteParts").scale = -note_obj.get_node("NoteParts").scale
		
	# Sharp
	if note.length() > 1 and note[1] == "#":
		note_obj.get_node("Sharp").visible = true
	else:
		note_obj.get_node("Sharp").visible = false
		
	# C Line
	if note == "C" and octave == 4:
		note_obj.get_node("CLine").visible = true
		
	# Color
	note_obj.modulate = Color.WHITE
		
func clear_sheet():
	for note in notes_holder.get_children():
		notes_holder.remove_child(note)
		note.queue_free()
		
var move_track: float = 0
var time_track: float = 0

func set_bpm(bmp: int):
	move_per_sec = (tone_game.bpm / 60) * note_distance

func move_notes(delta: float):
	notes_holder.position -= Vector2(move_per_sec * delta, 0)
	
	# Move leading note
	if leading_note.global_position.x < 0:
		var note: String = tone_game.tones[leading_note_id]
		if note.length() == 2:
			create_note(note[0], int(note[1]), leading_note)
		elif note.length() == 3: # Sharps
			create_note(note.substr(0, 2), int(note[2]), leading_note)
		
		leading_note_id += 1
		# Progress
		if leading_note_id >= notes_holder.get_child_count():
			leading_note_id = 0
			
		leading_note = notes_holder.get_child(leading_note_id)
	
func fix_notes_movement(beat: int):
	notes_holder.position = Vector2(-note_distance * beat, notes_holder.position.y)

func note_node_id(note: Node) -> int:
	var i: int = 0
	for n in notes_holder.get_children():
		if n == note:
			return i
		i += 1
			
	return -1
	
func set_notes_position(beats: int):
	var pos: float = note_distance * (beats + 1)
	notes_holder.position = Vector2(-pos, 0)
	
func set_check_area_beat_offset(beats: int):
	var pos: float = note_distance * beats
	var area_w: float = check_area.size.x / 2
	check_area.position = Vector2(-pos - area_w, check_area.position.y)

func can_create_new_sequence() -> bool:
	#var last_note = notes_holder.get_child(notes_holder.get_child_count() - 1)
	#if last_note == null:
	#	return false
		
	#return last_note.global_position.x < new_sequence_position
	return false

func tested_note_feedback(success: bool):
	# update tested note
	if tested_note == null:
		tested_note = notes_holder.get_child(0)
			
	# Color note
	if tested_note != null:
		if success:
			tested_note.modulate = Color.AQUAMARINE
			tested_note = notes_holder.get_child(note_node_id(tested_note) + 1)
			#print("Hit with offset: " + str(check_area.global_position.x - tested_note.global_position.x))
		else:
			tested_note.modulate = Color.FIREBRICK
