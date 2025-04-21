extends Node2D
class_name SunriseImage

@export var change_speed: float = 1
@export var progress: float = 0
@export var sun_progress: float = 25
@export var sun: SunriseImagePart

var progress_current: float = 0

var parts: Array[SunriseImagePart]
var sun_y: float

func _ready() -> void:
	for part in get_children():
		parts.append(part)
		
	sun_y = sun.global_position.y

func _process(delta: float) -> void:
	
	# Move progress
	progress_current = lerpf(progress_current, progress, change_speed * delta)
	
	# Apply progress
	for part in parts:
		part.coloring(progress_current)
		
	sun.global_position.y = sun_y + -sun_progress * progress_current
		
func set_progress(prog: float):
	progress = prog
