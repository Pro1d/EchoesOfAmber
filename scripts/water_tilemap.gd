extends TileMapLayer
class_name WaterTileMap

func _enter_tree() -> void:
	Config.water_2d = self

func _place_tile(p: Vector2i, atlas: Vector2i, alternative: int) -> void:
	set_cell(p, 0, atlas, alternative)


func build_north_bridge() -> void:
	await get_tree().create_timer(0.5).timeout
	_place_tile(Vector2i(18, 6), Vector2i(13, 2), 2)
	await get_tree().create_timer(0.5).timeout
	_place_tile(Vector2i(18, 7), Vector2i(13, 2), 3)
	await get_tree().create_timer(0.5).timeout

func build_west_bridge() -> void:
	await get_tree().create_timer(0.5).timeout
	_place_tile(Vector2i(16, 4), Vector2i(13, 2), 1)
	await get_tree().create_timer(0.5).timeout
	_place_tile(Vector2i(15, 4), Vector2i(13, 2), 0)
	await get_tree().create_timer(0.5).timeout
