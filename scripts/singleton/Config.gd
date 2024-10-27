extends Node

#const CursorArrowIcon := preload("res://assets/resources/ui/cursor_arrow.atlastex")

var root_2d : WorldTileMap  # parent node of all y-sorted 2D nodes
var ground_2d: GroundTileMap
var water_2d: WaterTileMap
var sfx : GlobalSFX

const leaf_colors : Array[Color] = [
	Color(0.871, 0.329, 0.243),
	Color(0.82, 0.596, 0.153),
	Color(0.612, 0.686, 0.227)
]

func _enter_tree() -> void:
#	Input.set_custom_mouse_cursor(
#		CursorArrowIcon, Input.CURSOR_ARROW, Vector2(2, 2)
#	)
	pass
