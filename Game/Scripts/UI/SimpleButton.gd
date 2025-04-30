@tool
extends Button
class_name SimpleButton

@export var icon_texture: Texture2D
@export var icon_node: TextureRect
@export var highlight_color: Color

func _ready() -> void:
	icon_node.texture = icon_texture

func display_highligh(highlight: bool):
	if highlight:
		modulate = highlight_color
	else:
		modulate = Color.WHITE
