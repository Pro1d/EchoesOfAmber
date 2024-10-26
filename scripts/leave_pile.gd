extends Node2D
class_name LeavePile

# Initialization variable
var pile_type : Leave.LeaveType = Leave.LeaveType.RED

@onready var sprite : AnimatedSprite2D = %Sprite

func _ready() -> void:
	sprite.animation = str(int(pile_type))
	
func animate_build() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, 'modulate:a', 0.0, 0.3).from(1.0) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	queue_free()
