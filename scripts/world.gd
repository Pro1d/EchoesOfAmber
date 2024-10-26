extends Node2D
class_name World

@onready var player : Player = %Player
@onready var hud : HUD = %HUD
@onready var menu : Menu = %Menu
@onready var area_manager : AreaManager = %AreaManager

var leaves_count := {
	Leave.LeaveType.RED: 500,
	Leave.LeaveType.YELLOW: 500,
	Leave.LeaveType.GREEN: 500
}

func _ready() -> void:
	player.on_leave_in_backpack.connect(_on_leave_in_backpack)
	player.on_try_spawn_leaves.connect(_on_player_try_spawn_leaves)
	area_manager.on_area_cleared.connect(_on_area_cleared)
	_update_leaves_hud(false)
	_pause_game()
	menu.play_clicked.connect(_resume_game)
	hud.open_menu_clicked.connect(_pause_game)

func _resume_game() -> void:
	player.lock_player = false
	menu.hide()
	hud.show()

func _pause_game() -> void:
	player.lock_player = true
	menu.show()
	hud.hide()

func _on_area_cleared(area: AreaManager.AreaData) -> void:
	print("Cleared area: " + str(area.area_id))

func _on_player_try_spawn_leaves(leave_type: Leave.LeaveType, pileable_tile: PileableTile) -> void:
	var cost := 10
	
	var has_enough_leaves : bool = leaves_count[leave_type] >= cost
	
	if has_enough_leaves and pileable_tile.can_spawn_leave():
		leaves_count[leave_type] -= cost
		pileable_tile.spread_leaves(leave_type)
		_update_leaves_hud(true)

	player.play_pile_desposit_animation(leave_type, has_enough_leaves)

func _on_leave_in_backpack(leave_type: Leave.LeaveType) -> void:
	leaves_count[leave_type] += 1
	_update_leaves_hud(true)
	
func _update_leaves_hud(animate: bool) -> void:
	hud.update_leave_count([
		leaves_count[Leave.LeaveType.RED],
		leaves_count[Leave.LeaveType.YELLOW],
		leaves_count[Leave.LeaveType.GREEN]], animate)
