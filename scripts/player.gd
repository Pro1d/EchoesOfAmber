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

# list of PileableTile to which the player currently has contact
var contacted_pile_tiles : Array[PileableTile] = []

func _ready() -> void:
	leaves_attraction_area.body_entered.connect(_on_leave_entered_area)
	leaves_attraction_area.body_exited.connect(_on_leave_exited_area)
	pile_contact_area.area_entered.connect(_on_enter_pile_area)
	pile_contact_area.area_exited.connect(_on_exit_pile_area)

func _physics_process(_delta: float) -> void:
	
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

	move_and_slide()

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

	body.on_attraction_point_reached.connect(_on_leave_in_backpack)
	body.set_attraction_point(attraction_point)
	
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

func _on_leave_exited_area(body: Leave) -> void:
	if not body is Leave:
		return 

	body.set_attraction_point(null)

func _on_leave_in_backpack(leave_type: Leave.LeaveType) -> void:
	on_leave_in_backpack.emit(leave_type)

func play_pile_desposit_animation(_leave_type: Leave.LeaveType, _success: bool) -> void:
	# TODO
	pass
