extends Control
class_name PianoHint

var show: bool = false
var last_key: int = 0

func _ready() -> void:
	modulate.a = 0

func _process(delta: float) -> void:
	if show == true:
		modulate.a = lerpf(modulate.a, 1, delta)
	else:
		modulate.a = lerpf(modulate.a, 0, delta * 10)

func show_hint(key: int) -> void:
	show = true
	get_child(key).visible = true
	last_key = key

func hide_hint() -> void:
	show = false
	get_child(last_key).visible = false
	
func show_hint_proggression(prog: Array[int]):
	for child in get_children():
		child.visible = false
	
	show = true
	for i in prog:
		get_child(i).visible = true
