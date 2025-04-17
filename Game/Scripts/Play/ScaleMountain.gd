@tool
extends Node2D
class_name ScaleMountain

@export var is_reverted = false
@export var points_holder: Node
@export var sprite: Sprite2D

var points: Array[Node2D]

signal on_get_points

func _ready() -> void:
	points.clear()
	if Engine.is_editor_hint():
		return
	
	# Get point
	if not is_reverted:
		for p in points_holder.get_children():
			points.append(p)
	else:
		var i = points_holder.get_children().size() - 1
		while i > 0:
			points.append(points_holder.get_child(i))
			i -= 1
			
		# Scale
		scale = Vector2(- abs(scale.x), scale.y)
		
	on_get_points.emit(points)
		
func _process(delta: float) -> void:
	# Swap in editor
	if Engine.is_editor_hint():
		if is_reverted:
			scale = Vector2(- abs(scale.x), scale.y)
		else:
			scale = Vector2(abs(scale.x), scale.y)

func get_point(id: int) -> Node2D:
	if id >= points.size() or id < 0:
		return null
	
	return points[id]
	
func is_end(point: Node2D) -> bool:
	return point == points[points.size() - 1]
	
func set_reverted(reverted: bool):
	is_reverted = reverted
	points.clear()
	
	if is_reverted:
		scale = Vector2(- abs(scale.x), scale.y)
		for i in range(points_holder.get_child_count() - 1, 0, -1):
			points.append(points_holder.get_child(i))
	else:
		scale = Vector2(abs(scale.x), scale.y)
		for p in points_holder.get_children():
			points.append(p)
