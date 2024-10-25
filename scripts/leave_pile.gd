extends Node2D
class_name LeavePile

# Initialization variable
var pile_type : Leave.LeaveType = Leave.LeaveType.RED

@onready var sprite : AnimatedSprite2D = %Sprite

func _ready() -> void:
	sprite.animation = str(int(pile_type))
