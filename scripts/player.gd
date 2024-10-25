extends CharacterBody2D
class_name Player

# Called when a leave arrives in the backpack
signal on_leave_in_backpack(leave_type: Leave.LeaveType)

const SPEED := 64.0
const ACCEL := SPEED / 0.2

@onready var attraction_point : Node2D = %AttractionPoint
@onready var leaves_attraction_area : Area2D = %LeavesAttractionArea

func _ready() -> void:
	leaves_attraction_area.connect("body_entered", _on_leave_entered_area)
	leaves_attraction_area.connect("body_exited", _on_leave_exited_area)

func _physics_process(_delta: float) -> void:
	var command := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"),
	)

	velocity = velocity.move_toward(command.normalized() * SPEED, ACCEL)
	leaves_attraction_area.monitoring = Input.is_action_pressed('attract_leaves')
	move_and_slide()
	
func _on_leave_entered_area(body: Leave) -> void:
	if not body is Leave:
		return

	body.on_attraction_point_reached.connect(_on_leave_in_backpack)
	body.set_attraction_point(attraction_point)
	
	
func _on_leave_exited_area(body: Leave) -> void:
	if not body is Leave:
		return 

	body.set_attraction_point(null)

func _on_leave_in_backpack(leave_type: Leave.LeaveType) -> void:
	on_leave_in_backpack.emit(leave_type)
