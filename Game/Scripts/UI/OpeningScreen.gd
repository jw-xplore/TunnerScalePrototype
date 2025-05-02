extends Control
class_name OpeningScreen

@export var show: bool = true
@export var show_time: float = 3
@export var alive_time: float = 8
@export var fade_out_speed: float = 1

var timer: float = 0
	
func _ready() -> void:
	if show == false:
		queue_free()
	
func _process(delta: float) -> void:
	timer += delta
	
	# Show	
	if timer >=  show_time:
		# Fade out
		if modulate.a > 0:
			modulate.a = lerp(modulate.a, modulate.a - fade_out_speed, delta)
		else:
			visible = false
		
	# Remove
	if timer >= alive_time:
		queue_free()
