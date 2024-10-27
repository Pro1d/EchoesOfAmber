class_name BridgeBuildFx
extends Node2D

signal burst
signal finished

@onready var particles := $CPUParticles2D as CPUParticles2D
@onready var anim := $AnimationPlayer as AnimationPlayer

# Called wen the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("geiser")
	anim.animation_finished.connect(finished.emit.unbind(1))
	anim.animation_finished.connect(queue_free.unbind(1))

func _emit_burst() -> void:
	burst.emit()

func is_finished() -> bool:
	return not anim.is_playing()
