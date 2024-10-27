extends CharacterBody2D
class_name Leave

signal on_attraction_point_reached(leave_type: LeaveType);

enum LeaveType {
	RED = 0,
	YELLOW = 1,
	GREEN = 2,
}
enum State {
	FREE = 0, ATTRACTED, REACHED, DYING,
}

static func str_to_leave_type(leave_str: String) -> LeaveType:
	match leave_str:
		'red': return LeaveType.RED
		'yellow': return LeaveType.YELLOW
		'green': return LeaveType.GREEN
		_: return LeaveType.GREEN


@onready var anim : AnimationPlayer = $Anim
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var attraction_point: Node2D =  null
@export var elevation_z := 16.0 :
	set(z):
		elevation_z = z
		if sprite != null:
			sprite.position.y = -z
@onready var attracted_elevation_z := randf_range(20, 24)
var leave_gravity  := 10 # px/s
var type: LeaveType   = LeaveType.RED # red, green, yellow
var _state := State.FREE
var linear_velocity := Vector2.ZERO

# Leave dying on ground mechanic
var current_time_on_ground := 0.0 # seconds
var max_time_on_ground : float # seconds

# Into bag mechanic
# total amount of time the leave stayed close to the player
var total_time_close_to_attraction_point := 0.0 
var max_time_close_to_attaction_point := 0.7
var attraction_point_close_distance := 16.0

# Offsets to break homogeneity
var lateral_offset : float = 0 # random offset
var lateral_movement_speed_factor : float = 1
var lateral_movement_amplitude_factor : float = 1

func _ready() -> void:
	lateral_offset = randf_range(0, 3.14)
	lateral_movement_speed_factor = randf_range(0.7, 1.3)
	lateral_movement_amplitude_factor = randf_range(0.8, 1.5)
	
	match type:
		LeaveType.RED:
			sprite.modulate = Color(
				0.871 + randf_range(-.05, .05),
				0.329 + randf_range(-.05, .05),
				0.243 + randf_range(-.05, .05))
		LeaveType.GREEN:
			sprite.modulate = Color(
				0.612 + randf_range(-.05, .05),
				0.686 + randf_range(-.05, .05),
				0.227 + randf_range(-.05, .05))
		LeaveType.YELLOW:
			sprite.modulate = Color(
				0.82 + randf_range(-.05, .05),
				0.596 + randf_range(-.05, .05),
				0.153 + randf_range(-.05, .05))

	elevation_z = elevation_z  # ensure elevation initialization
	_animation_spawn()

func _process(delta: float) -> void:
	sprite.rotation = lerp_angle(sprite.rotation, linear_velocity.angle(), 0.3)
	match _state:
		State.FREE:
			if not is_zero_approx(elevation_z):
				var speed := Time.get_ticks_msec() * 0.005 * lateral_movement_speed_factor
				var amplitude := 0.1 * lateral_movement_amplitude_factor
				sprite.position.x += sin( speed + lateral_offset) * amplitude
			# Leave dying on ground mechanic
			else:
				current_time_on_ground += delta
				if current_time_on_ground >= max_time_on_ground:
					_state = State.DYING
					await _animation_despawn()
					queue_free()
		State.ATTRACTED:
			var distance := (global_position - attraction_point.global_position).length()
			if distance <= attraction_point_close_distance:
				total_time_close_to_attraction_point += delta
				if total_time_close_to_attraction_point >= max_time_close_to_attaction_point:
					_state = State.REACHED
					await _animation_reached()
					on_attraction_point_reached.emit(self.type)
					queue_free()
		State.REACHED:
			return
		State.DYING:
			return


func _physics_process(delta: float) -> void:
	if linear_velocity.length_squared() <  1.0:
		linear_velocity = Vector2.ZERO
	else:
		linear_velocity *= 1.0 - delta * 1.3
	match _state:
		State.ATTRACTED:
			var target := attraction_point.global_position
			var offset := target - global_position
			var distance := offset.length()
			var pull_vector := offset / distance
			var tangent := Vector2(-pull_vector.y, pull_vector.x)
			const max_dist := 70.0
			var distance_ratio := clampf(distance / max_dist, 0.0, 1.0)
			
			var pull_force := 300.0 * maxf((1.0 - distance_ratio), 0.4)
			var tangential_force := 150.0 * minf(distance_ratio, 0.95)
			linear_velocity += (pull_vector * pull_force + tangent * tangential_force) * delta
			global_position += linear_velocity * delta
			var target_elevation := lerpf(0.5, attracted_elevation_z, (1 - distance_ratio) ** 1.0)
			self.elevation_z = move_toward(elevation_z, target_elevation, delta * 20.0)
		State.FREE:
			if elevation_z > 0:
				elevation_z = move_toward(elevation_z, 0, delta * leave_gravity)

func set_attraction_point(obj: Node2D) -> void:
	match _state:
		State.FREE, State.ATTRACTED:
			_state = State.ATTRACTED if obj != null else State.FREE
			attraction_point = obj
			total_time_close_to_attraction_point = 0.0

# Animations
var _tween_reach : Tween
var _tween_alpha : Tween

func _reset_tween(t: Tween) -> Tween:
	if t != null:
		t.kill()
	return create_tween()
	
func _animation_spawn() -> void:
	_tween_alpha = _reset_tween(_tween_alpha)
	sprite.modulate.a = 0.0
	_tween_alpha.tween_property(sprite, "modulate:a", 1.0, 0.25).from_current() \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await _tween_alpha.finished
	
func _animation_despawn() -> void:
	_tween_alpha = _reset_tween(_tween_alpha)
	_tween_alpha.tween_property(sprite, "modulate:a", 0.0, 0.25).from_current() \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await _tween_alpha.finished

func _animation_reached() -> void:
	_tween_reach = _reset_tween(_tween_reach)
	_tween_reach.tween_property(self, 'elevation_z', 32, 0.45).from_current() \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_tween_reach.parallel().tween_property(self, 'global_position', attraction_point.global_position, 0.45) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_tween_reach.tween_property(self, 'elevation_z', 11, 0.35) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await _tween_reach.finished
