extends Node2D
class_name World

@onready var player : Player = %Player

var leaves_count := {
	Leave.LeaveType.RED: 0,
	Leave.LeaveType.YELLOW: 0,
	Leave.LeaveType.GREEN: 0
}

func _ready() -> void:
	player.on_leave_in_backpack.connect(_on_leave_in_backpack)

func _on_leave_in_backpack(leave_type: Leave.LeaveType) -> void:
	leaves_count[leave_type] += 1
