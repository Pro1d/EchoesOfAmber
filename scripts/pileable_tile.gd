extends Node2D
class_name PileableTile

@onready var leave_pile_resource := preload("res://scenes/leave_pile.tscn")
@onready var sprite : Polygon2D = $Polygon2D

var spawned_piles : Array[LeavePile] = []
static var offsets : Array[Vector2] = [
									  Vector2(-6, -6), 
									  Vector2(6, 0), 
									  Vector2(-6, 6)]
static func get_parent_pileable_tile(area: Area2D) -> PileableTile:
	var parent := area.get_parent()
	
	if parent is PileableTile:
		return parent
	
	return null

func _ready() -> void:
	set_highlight(false)	

func can_spawn_leave() -> bool:
	return len(spawned_piles) < 3

func set_highlight(enabled: bool) -> void:
	sprite.modulate.a = 1.0 if enabled else 0.2 

func spawn(leave_type: Leave.LeaveType) -> void:
	var pile : LeavePile = leave_pile_resource.instantiate()
	pile.pile_type = leave_type
	pile.global_position = global_position + offsets[len(spawned_piles)]
	spawned_piles.append(pile)
	Config.root_2d.add_child(pile)
