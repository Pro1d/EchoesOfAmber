extends TileMapLayer
class_name WaterTileMap

const BridgeBuildFxPackedScene := preload("res://scenes/fx/BridgeBuildFx.tscn")

func _enter_tree() -> void:
	Config.water_2d = self

func _place_tile(p: Vector2i, atlas: Vector2i, alternative: int) -> void:
	set_cell(p, 0, atlas, alternative)

func build_north_bridge() -> void:
	await _build_briges(
		[Vector2i(18, 6), Vector2i(18, 7)],
		[Vector2i(13, 2), Vector2i(13, 2)],
		[2, 3]
	)

func build_west_bridge() -> void:
	await _build_briges(
		[Vector2i(16, 4), Vector2i(15, 4)],
		[Vector2i(13, 2), Vector2i(13, 2)],
		[1, 0]
	)

func _build_briges(coords: Array[Vector2i], tile_ids: Array[Vector2i], tile_alt: Array[int]) -> void:
	var last_build_bridge_fx : BridgeBuildFx
	for i in range(tile_ids.size()):
		var coord := coords[i]
		var id := tile_ids[i]
		var alt := tile_alt[i]
		var gpos := to_global(map_to_local(coord))
		var build_bridge_fx := BridgeBuildFxPackedScene.instantiate() as BridgeBuildFx
		Config.root_2d.add_child(build_bridge_fx)
		build_bridge_fx.global_position = gpos
		build_bridge_fx.burst.connect(_place_tile.bind(coord, id, alt))
		
		#await get_tree().create_timer(0.5).timeout
		last_build_bridge_fx = build_bridge_fx
	
	if not last_build_bridge_fx.is_finished():
		await last_build_bridge_fx.finished
