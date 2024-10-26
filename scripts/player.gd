extends CharacterBody2D
class_name Player

# Called when a leave arrives in the backpack
signal on_leave_in_backpack(leave_type: Leave.LeaveType)
signal on_try_spawn_leaves(leave_type: Leave.LeaveType, tile: PileableTile)

const SPEED := 64.0
const ACCEL := SPEED / 0.2

@onready var attraction_point : Node2D = %AttractionPoint
@onready var leaves_attraction_area : Area2D = %LeavesAttractionArea
@onready var pile_contact_area : Area2D = %PileContactArea
@onready var leaves_sound : AudioStreamPlayer2D = %LocalLeavesSound
@onready var strong_wind_sound : AudioStreamPlayer2D = %StrongWindSound
@onready var wind_particles : CPUParticles2D = %WindParticles

@onready var footstep_players : Array[AudioStreamPlayer2D] = [%FootstepL, %FootstepR]


# list of PileableTile to which the player currently has contact
var contacted_pile_tiles : Array[PileableTile] = []
var leaves_hooked_count := 0

# Footsteps
var foot_step_period : float    =  0.5
var foot_step_countdown : float =  0
var last_foot                   := 0 # 0 = left, 1 = right

func _ready() -> void:
	leaves_attraction_area.body_entered.connect(_on_leave_entered_area)
	leaves_attraction_area.body_exited.connect(_on_leave_exited_area)
	pile_contact_area.area_entered.connect(_on_enter_pile_area)
	pile_contact_area.area_exited.connect(_on_exit_pile_area)

func _physics_process(delta: float) -> void:
	var command := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"),
	)
	
	var attract_leaves := Input.is_action_pressed('attract_leaves')
	
	if not attract_leaves: # dont move while attracting leaves
		velocity = velocity.move_toward(command.normalized() * SPEED, ACCEL)
	else:
		velocity = Vector2()
		

	leaves_attraction_area.monitoring = attract_leaves
	
	_handle_pile_deposit_input()
	_handle_footstep_sound(delta)
	_handle_leave_sound(attract_leaves, delta)
	
	wind_particles.emitting = attract_leaves
	
	move_and_slide()

func _handle_footstep_sound(delta: float) -> void:
	if velocity.length_squared() == 0:
		foot_step_countdown = 0
		return
	
	foot_step_countdown -= delta
	
	if foot_step_countdown <= 0:
		footstep_players[last_foot].play()
		foot_step_countdown = foot_step_period
		last_foot = (last_foot + 1) % len(footstep_players)
		
func _handle_leave_sound(attract_leaves: bool, delta: float) -> void:
	var max_volume : float = 0
	var min_volume : float = -28
	var leaves_for_full_volume : float = 40
	var target_volume := lerpf(min_volume, max_volume, clampf(leaves_hooked_count / leaves_for_full_volume, 0, 1))
	leaves_sound.volume_db = lerp(leaves_sound.volume_db, target_volume, 1.2 * delta)
	
	var wind_min_volume : float = -64
	var wind_max_volume : float = 0
	var wind_target_volume := wind_max_volume if attract_leaves else (wind_min_volume - 1.0) 
	var interp_speed : float = 0.5 if attract_leaves else 0.8
	strong_wind_sound.volume_db = lerp(strong_wind_sound.volume_db, wind_target_volume, interp_speed * delta)
	
	# Play / pause to save CPU while pausing.
	if strong_wind_sound.volume_db <= wind_min_volume and strong_wind_sound.playing:
		strong_wind_sound.stop()
	elif strong_wind_sound.volume_db > wind_min_volume and not strong_wind_sound.playing:
		strong_wind_sound.play()


func _handle_pile_deposit_input() -> void:
	var contacted_tile := get_contacted_pileable_tile()
	
	if contacted_tile == null:
		return
	
	for t in contacted_pile_tiles:
		t.set_highlight(false)
	
	contacted_tile.set_highlight(true)
		
	if Input.is_action_just_pressed("put_red"):
		on_try_spawn_leaves.emit(Leave.LeaveType.RED, contacted_tile)

	if Input.is_action_just_pressed("put_green"):
		on_try_spawn_leaves.emit(Leave.LeaveType.GREEN, contacted_tile)

	if Input.is_action_just_pressed("put_yellow"):
		on_try_spawn_leaves.emit(Leave.LeaveType.YELLOW, contacted_tile)

func _on_leave_entered_area(body: Leave) -> void:
	if not body is Leave:
		return
	
	leaves_hooked_count += 1
	body.on_attraction_point_reached.connect(_on_leave_in_backpack)
	body.set_attraction_point(attraction_point)
	
func _on_leave_exited_area(body: Leave) -> void:
	if not body is Leave:
		return 

	leaves_hooked_count -= 1
	body.set_attraction_point(null)


func _on_enter_pile_area(area: Area2D) -> void:
	var tile := PileableTile.get_parent_pileable_tile(area)
	
	if tile != null:
		contacted_pile_tiles.append(tile)

func _on_exit_pile_area(area: Area2D) -> void:
	var tile := PileableTile.get_parent_pileable_tile(area)

	if tile != null:
		tile.set_highlight(false)
		contacted_pile_tiles.remove_at(contacted_pile_tiles.find(tile))

func _dist_to(t: PileableTile) -> float:
	return (t.global_position - global_position).length_squared()

func get_contacted_pileable_tile() -> PileableTile:
	# Sort tiles by distance to player, from closer to farther
	contacted_pile_tiles.sort_custom(func (a: PileableTile, b: PileableTile) -> bool: return _dist_to(a) < _dist_to(b))
	
	if contacted_pile_tiles.is_empty():
		return null;
	
	return contacted_pile_tiles[0]

func _on_leave_in_backpack(leave_type: Leave.LeaveType) -> void:
	on_leave_in_backpack.emit(leave_type)

func play_pile_desposit_animation(_leave_type: Leave.LeaveType, _success: bool) -> void:
	# TODO
	pass
