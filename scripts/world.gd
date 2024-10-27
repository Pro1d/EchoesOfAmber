extends Node2D
class_name World

@onready var player : Player = %Player
@onready var hud : HUD = %HUD
@onready var menu : Menu = %Menu
@onready var area_manager : AreaManager = %AreaManager
@onready var blackbars : BlackBars = %BlackBars
@onready var camera : Camera2D = %Camera2D

static var SKIP_INTRO := false

var leaves_count := {
	Leave.LeaveType.RED: 0,
	Leave.LeaveType.YELLOW: 0,
	Leave.LeaveType.GREEN: 0
}

enum Quests {
	Q1_GET_LEAVES,
	Q2_CLEAR_AREA_1,
	Q3_CLEAR_AREA_2,
	Q3_CLEAR_AREA_3,
	Q3_CLEAR_HOUSE
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
	hud.visible = not v
	if v:
		menu.animate_show()
	else:
		menu.animate_hide()

func _on_player_try_spawn_leaves(leave_type: Leave.LeaveType, pileable_tile: PileableTile) -> void:
	var cost := 10
	
	var has_enough_leaves : bool = leaves_count[leave_type] >= cost
	
	if has_enough_leaves and pileable_tile.can_spawn_leave():
		leaves_count[leave_type] -= cost
		pileable_tile.spread_leaves(leave_type, true)
		_update_leaves_hud(true)
	elif not has_enough_leaves and pileable_tile.can_spawn_leave():
		Config.sfx.play_beep()
		hud.ui_fuzz_fx(leave_type)

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
@onready var q2_bridge_marker : Marker2D = %CinematicMarkers/Q2Bridge
@onready var q3_house_marker : Marker2D = %CinematicMarkers/Q3House
@onready var q3_area2_marker : Marker2D = %CinematicMarkers/Q3Area2
@onready var q3_area3_marker : Marker2D = %CinematicMarkers/Q3Area3

var current_quests : Array[Quests] = [Quests.Q1_GET_LEAVES]
var q1_piles_count := 8

var _q1_text : String = """
It seems this summer hit hard on my beautiful forest.

I must gather leaves to restore its colors.

[color="#26262699"]
[img=26x26,center,center]res://resources/sprite/keys/E.atlastex[/img] Harvest Leaves
[/color]"""

var _q2_text : String = """
Hmm, I believe I have gathered enough leaves to work my magic.

I should head North and expand the beauty of automn with my leaves.

[color="#26262699"]
[img=26x26,center,center]res://resources/sprite/keys/J.atlastex[/img] Spread [img=36x30,center,center]res://resources/sprite/red.atlastex[/img] red leaves
[img=26x26,center,center]res://resources/sprite/keys/K.atlastex[/img] Spread [img=36x30,center,center]res://resources/sprite/yellow.atlastex[/img] orange leaves
[img=26x26,center,center]res://resources/sprite/keys/L.atlastex[/img] Spread [img=36x30,center,center]res://resources/sprite/green.atlastex[/img] green leaves
[/color]"""

var _q3_text : String = """
These lands need a breath of life again. Perhaps my old spellbook holds the right formulas...

And then, I could liven up the forest around my home too.

[color="#26262699"]
Use [img=26x26,center,center]res://resources/sprite/keys/J.atlastex[/img]|[img=26x26,center,center]res://resources/sprite/keys/K.atlastex[/img]|[img=26x26,center,center]res://resources/sprite/keys/L.atlastex[/img] to scatter leaves around the house.
After coloring the ground, place leaf piles. Combine 3 leaf piles to grow vegetation.
[/color]
"""

var _q4_text : String = """
At last, my forest is restored.

I think I'll stay and relax for a bit... maybe plant a few more pumpkins around my home.
"""

func _cinematic_move_start(target_pos: Vector2, duration: float) -> void:
	player.set_listening(false) # move listen to camera
	var tween := get_tree().create_tween()
	tween.tween_property(camera, "global_position", target_pos, duration)
	await tween.finished
	tween.kill()

func _cinematic_move_end(duration: float) -> void:
	var tween := get_tree().create_tween()
	tween = get_tree().create_tween()
	tween.tween_property(camera, "position", Vector2(), duration)
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
	
	# Transition "leaves" area.
	var leaves_area : AreaManager.AreaData = area_manager.area_data[AreaManager.AREA_ID_LEAVES]
	leaves_area.force_mark_cleared = true
	area_manager.refresh_area_state(AreaManager.AREA_ID_LEAVES, true)
	
	# Wait for the squirrel :)
	await get_tree().create_timer(0.5).timeout
	Config.sfx.play_area_cleared()
	await Config.water_2d.build_north_bridge()
	await _cinematic_move_end(3)

	await blackbars.set_enabled(false)

	# Add the new quest
	current_quests.append(Quests.Q2_CLEAR_AREA_1)
	_set_menu_visible(true)
	await menu.display_current_quest_text(_q2_text)
	
# Called when the first area (north east) quest is finished
func _on_q2_area_1_finished() -> void:
	current_quests.remove_at(current_quests.find(Quests.Q2_CLEAR_AREA_1))
	
	# Show black bars
	player.lock_player = true
	await blackbars.set_enabled(true)
	await _cinematic_move_start(q2_bridge_marker.global_position, 3)

	# Wait for the squirrel :)
	await get_tree().create_timer(1).timeout
	await Config.water_2d.build_west_bridge()
	await _cinematic_move_end(3)
	await blackbars.set_enabled(false)

	# Add the new quest
	current_quests.append_array([Quests.Q3_CLEAR_AREA_2, Quests.Q3_CLEAR_AREA_3, Quests.Q3_CLEAR_HOUSE])
	_set_menu_visible(true)
	await menu.display_current_quest_text(_q3_text)
	
	# Start music with a delay	
	await get_tree().create_timer(2).timeout
	Config.sfx.play_music_layer_1()
	

func _update_leaves_quest() -> void:
	if Quests.Q1_GET_LEAVES not in current_quests:
		return

	var all_piles := 0
	for c: int in leaves_count.values():
		all_piles += c / Config.LEAVES_PER_PILE
	
	if all_piles >= q1_piles_count:
		_on_q1_leaves_quest_finished()

func _on_q3_area_2_finished() -> void:
	if Quests.Q3_CLEAR_AREA_2 in current_quests:
		current_quests.remove_at(current_quests.find(Quests.Q3_CLEAR_AREA_2))
	
	await _generic_area_finished(q3_area2_marker)

	_check_q3_complete()

func _on_q3_area_3_finished() -> void:
	if Quests.Q3_CLEAR_AREA_3 in current_quests:
		current_quests.remove_at(current_quests.find(Quests.Q3_CLEAR_AREA_3))
	
	await _generic_area_finished(q3_area3_marker)
	
	_check_q3_complete()

func _on_q3_area_0_finished() -> void:
	if Quests.Q3_CLEAR_HOUSE in current_quests:
		current_quests.remove_at(current_quests.find(Quests.Q3_CLEAR_HOUSE))

	await _generic_area_finished(q3_house_marker)

	_check_q3_complete()

func _check_q3_complete() -> void:
	# Play second layer when 1 quest is remaning.
	if len(current_quests) == 1:
		Config.sfx.play_music_layer_2()

	if len(current_quests) == 0:
		_on_game_finished()

func _on_game_finished() -> void:
	await get_tree().create_timer(15.0).timeout

	player.lock_player = true
	await blackbars.set_enabled(true)
	await get_tree().create_timer(2.0).timeout
	await blackbars.set_enabled(false)

	_set_menu_visible(true)
	await menu.display_current_quest_text(_q4_text)

func _generic_area_finished(marker: Marker2D = null) -> void:
	# Default implementation
	player.lock_player = true
	await blackbars.set_enabled(true)
	
	if marker != null:
		await _cinematic_move_start(marker.global_position, 3.0)
		await get_tree().create_timer(2.0).timeout
		await _cinematic_move_end(3.0)
	else:
		# Let the transitions happen in the world
		await get_tree().create_timer(5).timeout
	
	await blackbars.set_enabled(false)
	player.lock_player = false

func _on_area_cleared(area: AreaManager.AreaData) -> void:
	print("Cleared area: " + str(area.area_id))

	if area.area_id >= AreaManager.AREA_ID_LEAVES:
		return
	
	if area.area_id == 1:
		_on_q2_area_1_finished()
	elif area.area_id == 2:
		_on_q3_area_2_finished()
	elif area.area_id == 3:
		_on_q3_area_3_finished()
	elif area.area_id == 0:
		_on_q3_area_0_finished()
	else:
		_generic_area_finished()
