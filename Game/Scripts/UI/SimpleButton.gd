@tool
extends Button
class_name SimpleButton

@export var icon_texture: Texture2D
@export var icon_node: TextureRect

func _ready() -> void:
	icon_node.texture = icon_texture
