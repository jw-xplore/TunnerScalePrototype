extends ScaleMountain
class_name ScalePeak

@export var left_list: Array[PackedScene]
@export var right_list: Array[PackedScene]

var left_mountain: ScaleMountain
var rigth_mountain: ScaleMountain
var sprite_size = 0

var point_checks = 0

func _ready() -> void:
	# Create mountains
	left_mountain = create_mountain(true)
	rigth_mountain = create_mountain(false)
	
	# Check points
	points.clear()
	
	if left_mountain.points.size() == 0:
		left_mountain.on_get_points.connect(on_mountain_get_points)
	else:
		on_mountain_get_points(left_mountain.points)
		
	if rigth_mountain.points.size() == 0:
		rigth_mountain.on_get_points.connect(on_right_mountain_get_points)
	else:
		on_right_mountain_get_points(rigth_mountain.points)
		
	sprite_size = left_mountain.sprite.texture.get_width()

func on_mountain_get_points(mountain_points):
	points.append_array(mountain_points)
	point_checks += 1
	if point_checks > 1:
		on_get_points.emit(points)
		
func on_right_mountain_get_points(mountain_points: Array):
	mountain_points.remove_at(0)
	on_mountain_get_points(mountain_points)

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
		mountain.set_reverted(true)
		add_child(mountain)
		mountain.position = Vector2(mountain.sprite.texture.get_width() / 2, 0)
		
	return mountain
