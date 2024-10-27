extends AreaAmbienceVisual
class_name Bird

@onready var sprite: Sprite2D = $Sprite
@onready var anim : AnimationPlayer = $AnimationPlayer

enum State {
	FlyingIn,
	BeingIdle,
	FlyinOutCyle,
	FlyingOut
}

enum SubState {
	Away,
	Grounded,
	Transitioning
}

class Target:
	var pos: Vector2
	var is_high: bool
	
	func _init(p: Vector2, high: bool) -> void:
		self.pos = p
		self.is_high = high


# Parameters
var anim_duration := 4
@export_range(0.5, 10) var cycle_grounded_duration : float = 7
@export_range(0.5, 10) var cycle_away_duration : float = 4
@export_range(0.0, 1,0) var cycle_random_percentage : float = 0.4

var high_position_px := -24.0
var x_amplitude := 256.0
var y_amplitude := 512.0

var time_since_last_change := 2.0
var state: State = State.BeingIdle
var prev_state: State = State.BeingIdle
var sub_state: SubState = SubState.Grounded
var target_positions : Array[Target] = []

func _ready() -> void:
	target_positions.append(Target.new(global_position, name.to_lower().contains("high")))

	for c: Variant in get_children():
		if c is Marker2D:
			var n : Node2D = c
			var is_high := n.name.to_lower().contains("high")
			target_positions.append(Target.new(n.global_position, is_high))
	
	state = State.FlyinOutCyle
	

func _process(delta: float) -> void:
	if prev_state == state:
		if state == State.FlyinOutCyle:
			update_cycle(delta)

		return

	# State change!
	if state == State.FlyingIn:
		fly_in()
	elif state == State.FlyingOut:
		fly_away()
	elif state == State.BeingIdle:
		be_idle()
	elif state == State.FlyinOutCyle:
		start_cycle()

	prev_state = state

func transition(animate: bool, shown: bool) -> void:
	if animate:
		if shown:
			state = State.FlyinOutCyle
			sub_state = SubState.Away
		else:
			state = State.FlyingOut
	else:
		visible = shown
		if shown:
			state = State.FlyinOutCyle
			sub_state = SubState.Grounded
		else:
			state = State.BeingIdle

# Starts the fly in / fly out cycle
func start_cycle() -> void:
	time_since_last_change = randf_range(0, 4.5)
	pass

func update_cycle(delta: float) -> void:
	time_since_last_change += delta

	if sub_state == SubState.Transitioning:
		return
	
	if sub_state == SubState.Grounded and time_since_last_change >= cycle_grounded_duration:
		await fly_away()
		time_since_last_change = randf_range(-cycle_away_duration * cycle_random_percentage, cycle_away_duration * cycle_random_percentage)
	elif sub_state == SubState.Away and time_since_last_change >= cycle_away_duration:
		await fly_in()
		time_since_last_change = randf_range(-cycle_grounded_duration * cycle_random_percentage, cycle_grounded_duration * cycle_random_percentage)
		
		

func be_idle() -> void:
	pass


func fly_in() -> void:
	sub_state = SubState.Transitioning
	visible = true
	anim.play('Fly')
	
	var target : Target = target_positions.pick_random()
	var high_pos_offset := Vector2(0, -48) if target.is_high else Vector2(0, 0)
	var arrival_offset := Vector2(0, high_position_px) + high_pos_offset
	var start_y : float = -y_amplitude
	global_position = target.pos - high_pos_offset

	sprite.position = Vector2(randf_range(-x_amplitude, 0), start_y)

	var tween := get_tree().create_tween()
	
	tween.tween_property(sprite, 'position', arrival_offset, anim_duration)
	tween.tween_property(sprite, 'position', high_pos_offset, 0.5)

	await tween.finished
	anim.play('Idle')
	sub_state = SubState.Grounded
	

func fly_away() -> void:
	sub_state = SubState.Transitioning
	anim.play('Fly')
	var end_y : float = -y_amplitude
	var end_x : float = randf_range(0, x_amplitude)

	var tween := get_tree().create_tween()
	# Décollage
	tween.tween_property(sprite, 'position', Vector2(0, high_position_px), 0.5)
	tween.tween_property(sprite, 'position', Vector2(end_x, end_y), anim_duration)

	await tween.finished

	visible = false
	sub_state = SubState.Away
