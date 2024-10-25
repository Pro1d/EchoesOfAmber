extends Node2D
class_name PileableTile

@onready var leave_pile_resource := preload("res://scenes/leave_pile.tscn")
@onready var sprite : Polygon2D = $Polygon2D

var tilemap_cell : Vector2i # initialized when spawned
var is_built := false
var spawned_piles : Array[LeavePile] = []
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

var buildings_map := {
	BuildingType.RedTree: Vector2i(1, 3),
	BuildingType.YellowTree: Vector2i(5, 3),
	BuildingType.GreenTree: Vector2i(3, 3),
	BuildingType.RedStuff: Vector2i(0, 7),
	BuildingType.YellowStuff: Vector2i(1, 7),
	BuildingType.GreenStuff: Vector2i(2, 7),
 	BuildingType.AllStarStuff: Vector2i(4, 7),
}

static func get_parent_pileable_tile(area: Area2D) -> PileableTile:
	var parent := area.get_parent()
	
	if parent is PileableTile:
		return parent
	
	return null

func _ready() -> void:
	set_highlight(false)

func can_spawn_leave() -> bool:
	return len(spawned_piles) < 3 and not is_built

func set_highlight(enabled: bool) -> void:
	sprite.modulate.a = 1.0 if enabled else 0.2 

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

func spawn(leave_type: Leave.LeaveType) -> void:
	var pile : LeavePile = leave_pile_resource.instantiate()
	pile.pile_type = leave_type
	pile.global_position = global_position + offsets[len(spawned_piles)]
	spawned_piles.append(pile)
	Config.root_2d.add_child(pile)
	
	if len(spawned_piles) == 3:
		is_built = true

		var coords : Vector2i = buildings_map[get_building_type()]

		for p in spawned_piles:
			await p.animate_build()
		
		var tilemap: TileMapLayer = Config.root_2d
		tilemap.set_cell(tilemap_cell, tilemap.get_cell_source_id(tilemap_cell), coords)
