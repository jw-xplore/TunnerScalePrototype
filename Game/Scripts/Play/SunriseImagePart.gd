extends Sprite2D
class_name SunriseImagePart

@export var colors: Array[Color]

var pos: float = 0
var max: int = 0
var start: Color
var target: Color
var col: Color
var perc: float

func coloring(progress: float):
	pos = floori(progress)
	max = colors.size() - 1
	
	if (pos + 1) < max:
		start = colors[pos]
		target = colors[pos + 1]
	else:
		pos = max - 1
		start = colors[pos]
		target = colors[max]
	
	perc = progress - pos
	
	col.r = (target.r - start.r) * perc + start.r
	col.g = (target.g - start.g) * perc + start.g
	col.b = (target.b - start.b) * perc + start.b

	modulate = col
