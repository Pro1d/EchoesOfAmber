extends Node2D
class_name AreaManager

class AreaData:
	var tiles_to_clear : Array[Vector2i] = []
	var trees_to_clear : Array[Vector2i] = []
	var dead_area_ambiance : Array[AreaAmbienceNode] = []
	var alive_area_ambiance : Array[AreaAmbienceNode] = []
	
	# True when the transition from dead to alive has been done on the area
	var is_in_cleared_state : bool = false
	
	func is_cleared() -> bool:
		return trees_to_clear.is_empty()

@onready var map_audio := %MapAudio
@onready var global_sfx : GlobalSFX = %GlobalSFX

# map of: area ID => area data
var area_data := {}

func _get_area_data(area_id: int) -> AreaData:
	if not area_id in area_data:
		area_data[area_id] = AreaData.new()
	
	return area_data[area_id]

func _register_tiles_to_clear() -> void:
	var layer := Config.ground_2d
	for cell in layer.get_used_cells():
		var ground_tile_data := layer.get_cell_tile_data(cell)
		var ground_spawner_type : String = ground_tile_data.get_custom_data("spawner")
		var area : int =  ground_tile_data.get_custom_data('area')
		
		# Not a tileable
		if ground_spawner_type != 'pile':
			continue
		
		# Not a dead forest area
		if area <= 0:
			continue
		
		# We are on a pile tile on a dead forest
		# Add this tile to the list of tiles to clear
		var data : AreaData = _get_area_data(area)
		data.tiles_to_clear.append(cell)
		
		var world_tile_data := Config.root_2d.get_cell_tile_data(cell)
		
		# No building on the tile, certainly not a dead tree =p
		if world_tile_data == null:
			continue
		
		var world_spawner_type : String = world_tile_data.get_custom_data("spawner")

		if world_spawner_type != 'dead':
			continue
		
		# From now we are on a pile tile with a dead tree.
		data.trees_to_clear.append(cell)


func _register_audio_ambience_nodes() -> void:
	for node in map_audio.get_children():
		if not node is AreaAmbienceNode:
			continue

		var amb : AreaAmbienceNode = node
		var data : AreaData = _get_area_data(amb.area_id)
		
		if amb.is_desolated:
			data.dead_area_ambiance.append(amb)
		else:
			data.alive_area_ambiance.append(amb)


func _ready() -> void:
	_register_tiles_to_clear()
	_register_audio_ambience_nodes()	
	
	for area_id: int in area_data:
		var data : AreaData = area_data[area_id]
		refresh_area_state(data, false)

	for tile_id: Vector2i in Config.ground_2d.pileable_tiles:
		var tile : PileableTile = Config.ground_2d.pileable_tiles[tile_id]
		tile.on_tile_state_changed.connect(_on_tile_state_changed)


func _on_tile_state_changed(tile: PileableTile) -> void:
	if tile.is_colored:
		on_tile_cleared(tile.tilemap_cell)
	
# Called when a tile has been cleared in an area
func _on_area_tile_cleared(_area_id: int, _tile: Vector2i) -> void:
	pass

# Called when a tree has been cleared in an area
func _on_area_tree_cleared(area_id: int, tile: Vector2i) -> void:
	var data : AreaData = area_data[area_id]
	_propagate_leaves(tile)
	refresh_area_state(data, true)

func _propagate_leaves(tile: Vector2i) -> void:
	var center_tile := Config.ground_2d.get_pileable_tile_at(tile)
	
	if center_tile == null:
		# This should never happen
		printerr("We shouldn't be here! tree area with no pileable tile cleared")
		return
	
	center_tile.build_tree(center_tile.get_color_type())
	
	for x_offset in range(-1, 2):
		for y_offset in range(-1, 2):
			# Don't process the center tile
			if x_offset == 0 and y_offset == 0:
				continue
					
			var propagation_pos := tile + Vector2i(x_offset, y_offset)
			var propagated_tile := Config.ground_2d.get_pileable_tile_at(propagation_pos)
			
			if propagated_tile == null:
				continue
			
			propagated_tile.spread_leaves(center_tile.get_color_type())
			await get_tree().create_timer(0.1).timeout


# Refreshes the whole area state
func refresh_area_state(data: AreaData, animate: bool) -> void:
	var is_cleared := data.is_cleared()
	
	# Avoid multiple refreshes when animating
	if animate and data.is_in_cleared_state == is_cleared:
		return
	
	data.is_in_cleared_state = is_cleared
	
	var min_volume : float = -64
	var all_audios := []
	all_audios.append_array(data.dead_area_ambiance)
	all_audios.append_array(data.alive_area_ambiance)
	var tween := get_tree().create_tween()
	var tween_duration := 3
	
	# Audio transition
	for audio: AreaAmbienceNode in all_audios:
		var play := is_cleared != audio.is_desolated 
		
		if animate:
			if play:
				tween.parallel().tween_property(audio, 'volume_db', audio.nominal_volume_db, tween_duration)
			else:
				tween.parallel().tween_property(audio, 'volume_db', min_volume, tween_duration)
		else:
			if play:
				audio.volume_db = audio.nominal_volume_db
			else:
				audio.volume_db = min_volume

		if play:
			audio.play()
	
	if animate:
		await tween.finished
		
		# Play sound effect when area is cleared.q
		if is_cleared:
			global_sfx.play_area_cleared()
	
	for audio: AreaAmbienceNode in all_audios:
		var play := is_cleared != audio.is_desolated 
		
		if not play:
			audio.stop()
	
	tween.kill()


# Notifies to the area manager that a tile has been cleared (de-desolated).
func on_tile_cleared(tile: Vector2i) -> void:
	print("tile cleared!")
	for area_id: int in area_data:
		var data : AreaData = area_data[area_id]
		var index := data.tiles_to_clear.find(tile)
		
		if index >= 0:
			data.tiles_to_clear.remove_at(index)
			_on_area_tile_cleared(area_id, tile)
		
		index = data.trees_to_clear.find(tile)
		if index >= 0:
			data.trees_to_clear.remove_at(index)
			_on_area_tree_cleared(area_id, tile)
	
		if area_id != 0:
			print("area " + str(area_id) + " trees left to clear: " + str(len(data.trees_to_clear)))
