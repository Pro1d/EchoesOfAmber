extends CharacterBody2D


const SPEED := 64.0
const ACCEL := SPEED / 0.2


func _physics_process(_delta: float) -> void:
	var command := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"),
	)
	
	velocity = velocity.move_toward(command.normalized() * SPEED, ACCEL)

	move_and_slide()
