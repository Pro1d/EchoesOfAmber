extends CharacterBody2D


const SPEED := 64.0
const ACCEL := SPEED / 0.2

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
	
	move_and_slide()
	
func _on_leave_entered_area(body: Leave) -> void:
	if not body is Leave:
		return
		
	body.set_attraction_point(self)
	
	
func _on_leave_exited_area(body: Leave) -> void:
	if not body is Leave:
		return 

	body.set_attraction_point(null)
	print("leave exited " + body.name)
