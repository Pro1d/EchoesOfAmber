extends TileMapLayer
class_name GroundTileMap

@onready var pileable_tile := preload('res://scenes/pileable_tile.tscn')

func _enter_tree() -> void:
	Config.ground_2d = self

func _ready() -> void:
	for cell in self.get_used_cells():
		var tile_data := self.get_cell_tile_data(cell)
		var spawner_type : String = tile_data.get_custom_data("spawner")
		
		if spawner_type == null or spawner_type == '':
			continue
		
		if spawner_type in ['pile']:
			var tile : PileableTile = pileable_tile.instantiate()
			tile.global_position = to_global(map_to_local(cell))
			tile.tilemap_cell = cell
			add_child(tile)
