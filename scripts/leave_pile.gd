extends Node2D
class_name LeavePile

# Initialization variable
var pile_type : Leave.LeaveType = Leave.LeaveType.RED

@onready var sprite : AnimatedSprite2D = %Sprite

func _ready() -> void:
	sprite.animation = str(int(pile_type))
	
func animate_build() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, 'modulate', Color(1, 1, 1, 0), 0.3)
	await tween.finished
	queue_free()
