extends Node2D
class_name GlobalSFX

@onready var area_cleared_sfx : AudioStreamPlayer = $AreaCleared
@onready var build_sfx : AudioStreamPlayer = $BuildFx
@onready var grass_sfx : AudioStreamPlayer = $GrassFx
@onready var page_turn_sfx : AudioStreamPlayer = $PageTurnFx
@onready var music_layer_1 : AudioStreamPlayer = $MusicLayer1
@onready var music_layer_2 : AudioStreamPlayer = $MusicLayer2
@onready var beep_sfx : AudioStreamPlayer = $Beep

func _enter_tree() -> void:
	Config.sfx = self

func play_beep() -> void:
	beep_sfx.play()

func play_area_cleared() -> void:
	var music_bus_id := AudioServer.get_bus_index("Music")
	var current_volume := AudioServer.get_bus_volume_db(music_bus_id)
	
	# Lower music volume when playing this SFX
	var tween := get_tree().create_tween()
	tween.tween_method(_set_music_bus_volume, current_volume, current_volume - 16.0, 0.5)
	await tween.finished
	tween.kill()
	
	area_cleared_sfx.play()
	
	await area_cleared_sfx.finished
	
	# Put back original volume
	tween = get_tree().create_tween()
	tween.tween_method(_set_music_bus_volume, AudioServer.get_bus_volume_db(music_bus_id), current_volume, 2)
	await tween.finished
	tween.kill()

func _set_music_bus_volume(volume: float) -> void:
	var music_bus_id := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus_id, volume)

func play_build_fx() -> void:
	build_sfx.pitch_scale = randf_range(0.9, 1.1)
	build_sfx.play()

func play_grass_fx() -> void:
	grass_sfx.pitch_scale = randf_range(0.7, 1.0)
	grass_sfx.play()

func play_page_turn_fx() -> void:
	page_turn_sfx.play()

func play_music_layer_1() -> void:
	fadein_track(music_layer_1, -6.0)

func play_music_layer_2() -> void:
	fadein_track(music_layer_2, -17.0)

func fadein_track(track: AudioStreamPlayer, volume: float, duration: float = 5.0) -> void:
	if track.playing:
		return
	
	print("playing track: ", track.name)

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
