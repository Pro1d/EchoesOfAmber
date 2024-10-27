extends Node2D
class_name GlobalSFX

@onready var area_cleared_sfx : AudioStreamPlayer = $AreaCleared
@onready var build_sfx : AudioStreamPlayer = $BuildFx
@onready var grass_sfx : AudioStreamPlayer = $GrassFx
@onready var page_turn_sfx : AudioStreamPlayer = $PageTurnFx
@onready var music_layer_1 : AudioStreamPlayer = $MusicLayer1
@onready var music_layer_2 : AudioStreamPlayer = $MusicLayer2

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

func play_page_turn_fx() -> void:
	page_turn_sfx.play()

func play_music_layer_1() -> void:
	fadein_track(music_layer_1, -2.0)

func play_music_layer_2() -> void:
	fadein_track(music_layer_2, -17.0)

func fadein_track(track: AudioStreamPlayer, volume: float, duration: float = 5.0) -> void:
	if track.playing:
		return
	
	print("playing")

	track.volume_db = -64
	
	if music_layer_1.playing:
		# Sync with previous track
		track.play(music_layer_1.get_playback_position())
	else:
		track.play()

	var tween := get_tree().create_tween()
	tween.tween_property(track, 'volume_db', volume, duration)
	await tween.finished
	tween.kill()
