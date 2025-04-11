@tool
extends Control
class_name SheetRenderer

@export_group("Properties")
@export var line_space: float = 25
@export var fade_size: float = 250

@export_group("Sheet assets")
@export var line_scene: PackedScene
@export var note_quarter_scene: PackedScene

@export_group("Node references")
@export var lines_holder: Control
@export var notes_holder: Control

var note_names = ['C', 'D', 'E', 'F', 'G', 'A', 'B']
var lowest_position_treble_c4 = 10
const OCTAVE_DISTANCE = 7
var half_step = line_space * 0.5
var note_distance = 100

func _ready() -> void:
	# Create line base
	for i in range(0, 5):
		var line: Control = line_scene.instantiate()
		lines_holder.add_child(line)
		
		line.position = Vector2(0, i * line_space)

		
func _process(delta: float) -> void:
	# Process note visibility
	for note in notes_holder.get_children():
		#note_visibility(note)
		pass
		
func create_sequece(notes: Array[String]):
	clear_sheet()
	
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
	var x = note_distance * (notes_holder.get_child_count() - 1)
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
		
func clear_sheet():
	for note in notes_holder.get_children():
		notes_holder.remove_child(note)
		note.queue_free()

func note_visibility(note: Control):
	if note.position.x > fade_size:
		note.modulate.a = (fade_size - (note.position.x - fade_size)) / fade_size
