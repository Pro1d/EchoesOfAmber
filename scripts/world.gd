extends Node2D
class_name World

@onready var player : Player = %Player
@onready var hud : HUD = %HUD
@onready var menu : Menu = %Menu
@onready var area_manager : AreaManager = %AreaManager
@onready var blackbars : BlackBars = %BlackBars
@onready var camera : Camera2D = %Camera2D

static var SKIP_INTRO := true

var leaves_count := {
	Leave.LeaveType.RED: 500,
	Leave.LeaveType.YELLOW: 500,
	Leave.LeaveType.GREEN: 500
}

enum Quests {
	Q1_GET_LEAVES,
	Q2_CLEAR_AREA_1
}

func _ready() -> void:
	player.on_leave_in_backpack.connect(_on_leave_in_backpack)
	player.on_try_spawn_leaves.connect(_on_player_try_spawn_leaves)
	area_manager.on_area_cleared.connect(_on_area_cleared)
	menu.play_clicked.connect(_resume_game)
	hud.open_menu_clicked.connect(_pause_game)
	
	_set_menu_visible(false)
	_update_leaves_hud(false)
	_start_introduction()

func _resume_game() -> void:
	player.lock_player = false
	_set_menu_visible(false)

func _pause_game() -> void:
	player.lock_player = true
	_set_menu_visible(true)

func _set_menu_visible(v: bool) -> void:
	menu.visible = v
	hud.visible = not v
	if v:
		Config.sfx.play_page_turn_fx()

func _on_player_try_spawn_leaves(leave_type: Leave.LeaveType, pileable_tile: PileableTile) -> void:
	var cost := 10
	
	var has_enough_leaves : bool = leaves_count[leave_type] >= cost
	
	if has_enough_leaves and pileable_tile.can_spawn_leave():
		leaves_count[leave_type] -= cost
		pileable_tile.spread_leaves(leave_type, true)
		_update_leaves_hud(true)

	player.play_pile_desposit_animation(leave_type, has_enough_leaves)

func _on_leave_in_backpack(leave_type: Leave.LeaveType) -> void:
	leaves_count[leave_type] += 1
	_update_leaves_hud(true)
	_update_leaves_quest()
	
func _update_leaves_hud(animate: bool) -> void:
	hud.update_leave_count([
		leaves_count[Leave.LeaveType.RED],
		leaves_count[Leave.LeaveType.YELLOW],
		leaves_count[Leave.LeaveType.GREEN]], animate)

# ================================================================================================
# Cinematic / QUEST stuff starts here
# ================================================================================================

@onready var intro_area_marker : Marker2D = %CinematicMarkers/Intro
@onready var open_bridge_marker : Marker2D = %CinematicMarkers/OpenBridge

var current_quests : Array[Quests] = [Quests.Q1_GET_LEAVES]
var q1_leaves_count := 0
var q1_target_leaves := 20

var _q1_text : String = """[color=black]
Hum it seems my beautiful automnal forest is dying. 

I should get some leaves to bring back its colors.

[color="red"]E: Harvest Leaves[/color]
[/color]"""

var _q2_text : String = """[color=black]
Mmm, I think I have enough leaves to work my magic.

I should head North and use my leaves to expand the beauty
of automn.

[color="#CC293C"]J: Spread RED leaves[/color]
[color="#D19827"]K: Spread ORANGE leaves[/color]
[color="#8A9335"]L: Spread GREEN leaves[/color]

[/color]
"""

func _cinematic_move_start(target_pos: Vector2, duration: float) -> void:
	player.set_listening(false) # move listen to camera
	var tween := get_tree().create_tween()
	var offset := target_pos - camera.global_position
	tween.tween_property(camera, "offset",  offset, duration)
	await tween.finished
	tween.kill()

func _cinematic_move_end(duration: float) -> void:
	var tween := get_tree().create_tween()
	tween = get_tree().create_tween()
	tween.tween_property(camera, "offset", Vector2(), duration)
	await tween.finished
	player.set_listening(true)
	tween.kill()
	
# Starts the game introduction
func _start_introduction() -> void:
	if SKIP_INTRO:
		return

	player.lock_player = true
	await blackbars.set_enabled(true)

	# Camera movement to the side
	await _cinematic_move_start(intro_area_marker.global_position, 3)
	await get_tree().create_timer(2).timeout
	await _cinematic_move_end(3)
	await get_tree().create_timer(1).timeout
	
	# Remove blackbars
	await blackbars.set_enabled(false)

	_pause_game()
	await menu.display_current_quest_text(_q1_text)

# Called when the first quest is finished
func _on_q1_leaves_quest_finished() -> void:
	current_quests.remove_at(current_quests.find(Quests.Q1_GET_LEAVES))
	
	# Show black bars
	player.lock_player = true
	await blackbars.set_enabled(true)
	await _cinematic_move_start(open_bridge_marker.global_position, 3)
	Config.sfx.play_area_cleared()
	
	# Transition "leaves" area.
	var leaves_area : AreaManager.AreaData = area_manager.area_data[AreaManager.AREA_ID_LEAVES]
	leaves_area.force_mark_cleared = true
	area_manager.refresh_area_state(AreaManager.AREA_ID_LEAVES, true)

	await get_tree().create_timer(1).timeout
	await _cinematic_move_end(3)

	await blackbars.set_enabled(false)

	# Add the new quest
	current_quests.append(Quests.Q2_CLEAR_AREA_1)
	_set_menu_visible(true)
	await menu.display_current_quest_text(_q2_text)
	


func _update_leaves_quest() -> void:
	if Quests.Q1_GET_LEAVES not in current_quests:
		return

	var all_leaves := 0
	for c: int in leaves_count.values():
		all_leaves += c
	
	if all_leaves >= q1_leaves_count:
		_on_q1_leaves_quest_finished()


func _on_area_cleared(area: AreaManager.AreaData) -> void:
	print("Cleared area: " + str(area.area_id))
	player.lock_player = true
	await blackbars.set_enabled(true)
	# Let the transitions happen in the world
	await get_tree().create_timer(5).timeout
	await blackbars.set_enabled(false)
	player.lock_player = false
	
