@tool
extends Control
class_name SheetRenderer

@export var tone_game: ToneGameManager

@export_group("Properties")
@export var line_space: float = 25
@export var note_distance = 100
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
	for note in notes_holder.get_children():
		if note.global_position.x < remove_note_position:
			notes_holder.remove_child(note)
			note.queue_free()
			break;
	#move_notes(delta)
		
func create_sequece(notes: Array[String]):
	for note in notes:
		if note.length() == 2:
			create_note(note[0], int(note[1]))
		elif note.length() == 3: # Sharps
			create_note(note.substr(0, 2), int(note[2]))
		
func create_note(note: String, octave: int):
	var pos = note_names.find(note[0])
	if pos == -1:
		return
		
	# Create note
	var note_obj: Control = note_quarter_scene.instantiate()
	notes_holder.add_child(note_obj)
	
	# Position and scale
	var prev_note: Control = notes_holder.get_child(notes_holder.get_child_count() - 2)
	var prev_pos_x = 0
	if prev_note != null:
		prev_pos_x = prev_note.position.x
		
	var x = note_distance + prev_pos_x
	var octave_position = (octave - 4) * half_step * OCTAVE_DISTANCE
	var y = lowest_position_treble_c4 * half_step - pos * half_step - octave_position
	note_obj.position = Vector2(x, y)
	
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
		
func clear_sheet():
	for note in notes_holder.get_children():
		notes_holder.remove_child(note)
		note.queue_free()
		
var move_track: float = 0
var time_track: float = 0

func move_notes(delta: float):
	var bpm = tone_game.bpm
	var move_per_sec = (tone_game.bpm / 60) * note_distance
	var move = move_per_sec * delta
	
	#move_track += move
	#time_track += delta
	notes_holder.position -= Vector2(move, 0)
	
func fix_notes_movement(beat: int):
	notes_holder.position = Vector2(-note_distance * beat, notes_holder.position.y)

func note_node_id(note: Node) -> int:
	var i: int = 0
	for n in notes_holder.get_children():
		i += 1
		if n == note:
			return i
			
	return -1
	
func set_notes_position(beats: int):
	var pos = note_distance * (beats - sign(beats) * 1)
	notes_holder.position = Vector2(-pos, 0)
	
func set_check_area_beat_offset(beats: int):
	var pos = note_distance * beats
	var area_w = check_area.size.x / 2
	check_area.position = Vector2(-pos - area_w, check_area.position.y)

func can_create_new_sequence() -> bool:
	var last_note = notes_holder.get_child(notes_holder.get_child_count() - 1)
	if last_note == null:
		return false
		
	return last_note.global_position.x < new_sequence_position

func tested_note_feedback(success: bool):
	# update tested note
	if tested_note == null:
		tested_note = notes_holder.get_child(0)
	else:
		if notes_holder.global_position.x - tested_note.global_position.x < note_distance:
			tested_note = notes_holder.get_child(note_node_id(tested_note))
			
	# Color note
	if tested_note != null:
		if success:
			tested_note.modulate = Color.AQUAMARINE
			#print("Hit with offset: " + str(check_area.global_position.x - tested_note.global_position.x))
		else:
			tested_note.modulate = Color.FIREBRICK
