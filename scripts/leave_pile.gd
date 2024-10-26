extends Node2D
class_name LeavePile

# Initialization variable
var pile_type : Leave.LeaveType = Leave.LeaveType.RED

@onready var sprite : AnimatedSprite2D = %Sprite
@onready var spawn_particles : CPUParticles2D = %CPUParticles2D
@onready var despawn_particles : CPUParticles2D = %CPUParticles2D2

func _ready() -> void:
	sprite.animation = str(int(pile_type))
	spawn_particles.color = Config.leaf_colors[pile_type].lightened(0.1)
	despawn_particles.color = Config.leaf_colors[pile_type].lightened(0.1)
	spawn_particles.emitting = true
	
func animate_build() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5).from(1.0) # \
		#.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	spawn_particles.emitting = false
	despawn_particles.emitting = true
	await despawn_particles.finished
	queue_free()
