extends Node2D
class_name World

@onready var player : Player = %Player
@onready var hud : HUD = %HUD

var leaves_count := {
	Leave.LeaveType.RED: 0,
	Leave.LeaveType.YELLOW: 0,
	Leave.LeaveType.GREEN: 0
}

func _ready() -> void:
	player.on_leave_in_backpack.connect(_on_leave_in_backpack)

func _on_leave_in_backpack(leave_type: Leave.LeaveType) -> void:
	leaves_count[leave_type] += 1
	
	hud.update_leave_count([
		leaves_count[Leave.LeaveType.RED],
		leaves_count[Leave.LeaveType.YELLOW],
		leaves_count[Leave.LeaveType.GREEN]], true)
