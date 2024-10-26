extends TileMapLayer
class_name GroundTileMap

@onready var pileable_tile := preload('res://scenes/pileable_tile.tscn')

# Map of Vector2i => PileableTile
var pileable_tiles := {}

func get_pileable_tile_at(pos: Vector2i) -> PileableTile:
	if pos in pileable_tiles:
		return pileable_tiles[pos]
	
	return null

func _enter_tree() -> void:
	Config.ground_2d = self

func _ready() -> void:
	for cell in self.get_used_cells():
		var tile_data := self.get_cell_tile_data(cell)
		var spawner_type : String = tile_data.get_custom_data("spawner")
		var area : int = tile_data.get_custom_data('area')
		
		if spawner_type == null or spawner_type == '':
			continue
		
		if spawner_type in ['pile']:
			var tile : PileableTile = pileable_tile.instantiate()
			tile.global_position = to_global(map_to_local(cell))
			tile.tilemap_cell = cell
			# Buildings can be placed on the area only its the house area (0)
			# and no other buildings are placed on top
			var is_building_placed := Config.root_2d.get_cell_source_id(cell) >= 0
			tile.buildable = area == 0 and not is_building_placed
			pileable_tiles[cell] = tile
			add_child(tile)
