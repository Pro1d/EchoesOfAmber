class_name WorldTileMap
extends TileMapLayer

@onready var leaves_spawner := preload('res://scenes/spawner.tscn')

func _enter_tree() -> void:
	Config.root_2d = self

func _ready() -> void:
	for cell in self.get_used_cells():
		var tile_data := self.get_cell_tile_data(cell)
		var spawner_type : String = tile_data.get_custom_data("spawner")
		
		if spawner_type == null or spawner_type == '':
			continue
		
		var spawner : Spawner = leaves_spawner.instantiate()
		spawner.type = spawner_type
		spawner.global_position = to_global(map_to_local(cell))
		add_child(spawner)
