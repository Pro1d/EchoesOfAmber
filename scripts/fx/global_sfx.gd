extends Node2D
class_name GlobalSFX

@onready var area_cleared_sfx : AudioStreamPlayer = $AreaCleared

func play_area_cleared() -> void:
	area_cleared_sfx.play()
