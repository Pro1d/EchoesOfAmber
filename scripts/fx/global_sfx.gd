extends Node2D
class_name GlobalSFX

@onready var area_cleared_sfx : AudioStreamPlayer = $AreaCleared
@onready var build_sfx : AudioStreamPlayer = $BuildFx
@onready var grass_sfx : AudioStreamPlayer = $GrassFx

func _enter_tree() -> void:
	Config.sfx = self

func play_area_cleared() -> void:
	area_cleared_sfx.play()

func play_build_fx() -> void:
	build_sfx.pitch_scale = randf_range(0.9, 1.1)
	build_sfx.play()

func play_grass_fx() -> void:
	grass_sfx.pitch_scale = randf_range(0.7, 1.0)
	grass_sfx.play()
