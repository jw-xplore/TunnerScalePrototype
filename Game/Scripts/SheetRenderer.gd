@tool
extends Control

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
var lowest_position_treble = 10
var half_step = line_space * 0.5
var note_distance = 100

func _ready() -> void:
	# Create line base
	for i in range(0, 5):
		var line: Control = line_scene.instantiate()
		lines_holder.add_child(line)
		
		line.position = Vector2(0, i * line_space)
		
	# Test notes
	create_note('C')
	create_note('C#')
	create_note('D')
	create_note('D#')
	create_note('E')
	create_note('F')
	create_note('F#')
	create_note('G')
	create_note('G#')
	create_note('A')
	create_note('A#')
	create_note('B')
		
func _process(delta: float) -> void:
	# Process note visibility
	for note in notes_holder.get_children():
		note_visibility(note)
		
func create_note(note: String):
	var pos = note_names.find(note[0])
	if pos == -1:
		return
		
	# Create note
	var note_obj: Control = note_quarter_scene.instantiate()
	notes_holder.add_child(note_obj)
	
	# Position and scale
	var x = note_distance * (notes_holder.get_child_count() - 1)
	var y = lowest_position_treble * half_step - pos * half_step
	note_obj.position = Vector2(x, y)
	
	if pos > lowest_position_treble / 2:
		note_obj.get_node("NoteParts").scale = -note_obj.get_node("NoteParts").scale
		
	# Sharp
	if note.length() > 1 and note[1] == "#":
		note_obj.get_node("Sharp").visible = true
	else:
		note_obj.get_node("Sharp").visible = false

func note_visibility(note: Control):
	if note.position.x > fade_size:
		note.modulate.a = (fade_size - (note.position.x - fade_size)) / fade_size
