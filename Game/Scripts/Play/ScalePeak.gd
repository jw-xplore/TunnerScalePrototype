extends ScaleMountain
class_name ScalePeak

@export var left_list: Array[PackedScene]
@export var right_list: Array[PackedScene]

var left_mountain: ScaleMountain
var rigth_mountain: ScaleMountain

func _ready() -> void:
	# Create mountains
	left_mountain = create_mountain(true)
	rigth_mountain = create_mountain(false)
	
	# Listen
	points.clear()
	left_mountain.on_get_points.connect(on_mountain_get_points)
	rigth_mountain.on_get_points.connect(on_mountain_get_points)

func on_mountain_get_points(mountain_points):
	points.append_array(mountain_points)

func create_mountain(left: bool):
	var mountain
	if left:
		var rnd = randi_range(0, left_list.size() - 1)
		mountain = left_list[rnd].instantiate() as ScaleMountain
		add_child(mountain)
		mountain.position = Vector2(-mountain.sprite.texture.get_width() / 2, 0)
	else:
		var rnd = randi_range(0, right_list.size() - 1)
		mountain = right_list[rnd].instantiate() as ScaleMountain
		add_child(mountain)
		mountain.position = Vector2(mountain.sprite.texture.get_width() / 2, 0)
		
	mountain.set_reverted(not left)
	return mountain
