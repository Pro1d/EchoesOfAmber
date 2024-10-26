extends Node2D
class_name PileableTile

signal on_tile_state_changed(tile: PileableTile)

@onready var leave_pile_resource := preload("res://scenes/leave_pile.tscn")
@onready var sprite : Polygon2D = $Polygon2D
@onready var build_effect : CPUParticles2D = $BuildEffect

var tilemap_cell : Vector2i # initialized when spawned
var is_structure_built := false # true when a structure has been built on the tile
var is_colored := false # true when the tile has been colored
var spawned_piles : Array[LeavePile] =  []
var buildable := false # true if a structure can be built on the tile

var _color := Leave.LeaveType.RED

static var offsets : Array[Vector2] = [
									  Vector2(-6, -6), 
									  Vector2(6, 0), 
									  Vector2(-6, 6)]

enum BuildingType {
	RedTree,
	YellowTree,
	GreenTree,
	RedStuff,
	YellowStuff,
	GreenStuff,
	AllStarStuff
}

# Building type to coordinate of the tile with the given building. 
var buildings_map := {
	BuildingType.RedTree: Vector2i(1, 3),
	BuildingType.YellowTree: Vector2i(5, 3),
	BuildingType.GreenTree: Vector2i(3, 3),
	BuildingType.RedStuff: Vector2i(0, 7),
	BuildingType.YellowStuff: Vector2i(1, 7),
	BuildingType.GreenStuff: Vector2i(2, 7),
 	BuildingType.AllStarStuff: Vector2i(5, 7),
}

# Color to coordinate of the ground tile with the given color.
var colors_map := {
	Leave.LeaveType.RED: Vector2i(3, 0),
	Leave.LeaveType.YELLOW: Vector2i(6, 0),
	Leave.LeaveType.GREEN: Vector2i(9, 0)
}

var effects_modulate_map := {
	Leave.LeaveType.RED: Color(0.9, 0.35, 0.25),
	Leave.LeaveType.YELLOW: Color(0.8, 0.6, 0.2),
	Leave.LeaveType.GREEN: Color(0.55, 0.7, 0.4)
}

static func get_parent_pileable_tile(area: Area2D) -> PileableTile:
	var parent := area.get_parent()
	
	if parent is PileableTile:
		return parent
	
	return null


func _ready() -> void:
	set_highlight(false)


func can_spawn_leave() -> bool:
	if buildable:
		return len(spawned_piles) < 3 and not is_structure_built
	else:
		return not is_colored


func get_color_type() -> Leave.LeaveType:
	if is_colored:
		return _color
	
	printerr("get_color_type() called on an uncolored tile")
	return Leave.LeaveType.RED # default value


func set_highlight(enabled: bool) -> void:
	sprite.modulate.a = 0.8 if enabled else 0.1


func get_building_type() -> BuildingType:
	var red_piles := len(spawned_piles.filter(func (p: LeavePile) -> bool: return p.pile_type == Leave.LeaveType.RED))
	var green_piles := len(spawned_piles.filter(func (p: LeavePile) -> bool: return p.pile_type == Leave.LeaveType.GREEN))
	var yellow_piles := len(spawned_piles.filter(func (p: LeavePile) -> bool: return p.pile_type == Leave.LeaveType.YELLOW))
	
	if red_piles == 3:
		return BuildingType.RedTree
	
	if green_piles == 3:
		return BuildingType.GreenTree
		
	if yellow_piles == 3:
		return BuildingType.YellowTree
	
	if red_piles == 2:
		return BuildingType.RedStuff
		
	if green_piles == 2:
		return BuildingType.GreenStuff
		
	if yellow_piles == 2:
		return BuildingType.YellowStuff
	
	return BuildingType.AllStarStuff

# Force the building of a tree on this tile
func build_tree(leave_type: Leave.LeaveType) -> BuildingType:
	match leave_type:
		Leave.LeaveType.RED: return BuildingType.RedTree
		Leave.LeaveType.GREEN: return BuildingType.GreenTree
		Leave.LeaveType.YELLOW: return BuildingType.YellowTree
		_: return BuildingType.RedTree

func spread_leaves(leave_type: Leave.LeaveType) -> void:
	if can_spawn_leave():
		if is_colored:
			_spawn_pile(leave_type)
		else:
			_colorize_tile(leave_type)
	
	sprite.visible = can_spawn_leave()

func _colorize_tile(leave_type: Leave.LeaveType) -> void:
	var coords : Vector2i = colors_map[leave_type]
	Config.ground_2d.set_cell(tilemap_cell, 0, coords)
	build_effect.emitting = true
	build_effect.one_shot = true
	build_effect.self_modulate = effects_modulate_map[leave_type]
	is_colored = true
	_color = leave_type
	on_tile_state_changed.emit(self)

func _spawn_pile(leave_type: Leave.LeaveType) -> void:
	var pile : LeavePile = leave_pile_resource.instantiate()
	pile.pile_type = leave_type
	pile.global_position = global_position + offsets[len(spawned_piles)]
	spawned_piles.append(pile)
	Config.root_2d.add_child(pile)
	
	if len(spawned_piles) == 3:
		is_structure_built = true

		var building_type := get_building_type()

		for p in spawned_piles:
			await p.animate_build()

		_build(building_type)

		on_tile_state_changed.emit(self)

func _build(building_type: BuildingType) -> void:
	var coords : Vector2i = buildings_map[building_type]
	var tilemap: TileMapLayer = Config.root_2d
	tilemap.set_cell(tilemap_cell, 0, coords)
