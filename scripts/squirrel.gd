extends Sprite2D
class_name Squirrel

# Squirel state machine types
enum State {IDLE, LOOKING_FOR_FOOD_LEFT, EATING_LEFT, LOOKING_FOR_FOOD_RIGHT, EATING_RIGHT}

# Squirel vars
const SPEED := 64.0
const DISTANCE_THRESHOLD := 0.01
const EAT_TIME_MS := 5000

@onready var animation : AnimationPlayer = $Animation


var state := State.LOOKING_FOR_FOOD_LEFT
@onready var spawn_position := position
@onready var food_left_position := position - Vector2(24, 0)
@onready var food_right_position := position + Vector2(24, 0)
var eating_start_time := Time.get_ticks_msec()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func reset_anim_to_right() -> void:
	state = State.EATING_RIGHT
	position = food_right_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if (state == State.IDLE):		
		if (visible):
			state = State.LOOKING_FOR_FOOD_LEFT
			animation.play(("walk_right"))
	
	# Animation loop
	if (state == State.LOOKING_FOR_FOOD_LEFT):
		position = position.move_toward(food_left_position, SPEED * delta)
		if (position.distance_squared_to(food_left_position) < DISTANCE_THRESHOLD):
			state = State.EATING_LEFT
			eating_start_time = Time.get_ticks_msec()
			animation.play("idle_eat")
		
	if (state == State.EATING_LEFT):
		if ((Time.get_ticks_msec() - eating_start_time) > EAT_TIME_MS):
			state = State.LOOKING_FOR_FOOD_RIGHT
			animation.play(("walk_right"))
			flip_h = 0
			scale.x = 1
			
	if (state == State.LOOKING_FOR_FOOD_RIGHT):
		position = position.move_toward(food_right_position, SPEED * delta)
		if (position.distance_squared_to(food_right_position) < DISTANCE_THRESHOLD):
			state = State.EATING_RIGHT
			eating_start_time = Time.get_ticks_msec()
			animation.play("idle_eat")
			
	if (state == State.EATING_RIGHT):
		if ((Time.get_ticks_msec() - eating_start_time) > EAT_TIME_MS):
			state = State.LOOKING_FOR_FOOD_LEFT
			animation.play(("walk_right"))
			scale.x = -1
		
