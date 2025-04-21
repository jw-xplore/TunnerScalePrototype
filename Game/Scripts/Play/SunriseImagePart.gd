extends Sprite2D
class_name SunriseImagePart

@export var colors: Array[Color]

func coloring(progress: float):
	var pos = floori(progress)
	var max = colors.size() - 1
	var start: Color
	var target: Color
	
	if (pos + 1) < max:
		start = colors[pos]
		target = colors[pos + 1]
	else:
		pos = max - 1
		start = colors[pos]
		target = colors[max]
	
	var perc = progress - pos
	
	var r = (target.r - start.r) * perc + start.r
	var g = (target.g - start.g) * perc + start.g
	var b = (target.b - start.b) * perc + start.b
	modulate = Color(r, g, b, 1)
