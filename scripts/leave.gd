extends RigidBody2D
class_name Leave

signal on_attraction_point_reached();

@onready var sprite : Node2D =  $Polygon2D
@onready var anim : AnimationPlayer = $Anim

var attraction_point_reached : bool = false
var attraction_point: Node2D =  null
var elevation_z              : float = 16 # 0 = ground
var leave_gravity  := 10 # px/s
var type: String   =  'red' # red, green, yellow

# Leave dying on ground mechanic
var current_time_on_ground := 0.0 # seconds
var max_time_on_ground := 2.0 # seconds

# Into bag mechanic
# total amount of time the leave stayed close to the player
var total_time_close_to_attraction_point := 0.0 
var max_time_close_to_attaction_point := 1.0
var attraction_point_close_distance := 8.0

# Offsets to break homogeneity
var lateral_offset : float = 0 # random offset
var lateral_movement_speed_factor : float = 1
var lateral_movement_amplitude_factor : float = 1

func _ready() -> void:
	lateral_offset = randf_range(0, 3.14)
	lateral_movement_speed_factor = randf_range(0.7, 1.3)
	lateral_movement_amplitude_factor = randf_range(0.8, 1.5)
	self.anim.play("spawn")

func _process(delta: float) -> void:
	sprite.position.y = -elevation_z
	
	if attraction_point_reached:
		return

	if elevation_z != 0:
		var speed := Time.get_ticks_msec() * 0.005 * lateral_movement_speed_factor
		var amplitude := 0.1 * lateral_movement_amplitude_factor
		sprite.position.x += sin( speed + lateral_offset) * amplitude
	
	# Leave dying on ground mechanic
	if elevation_z == 0 and attraction_point == null:
		current_time_on_ground += delta
		
	# Leave into player bag mechanic
	if attraction_point != null:
		var distance := (global_position - attraction_point.global_position).length()
		if distance <= attraction_point_close_distance:
			total_time_close_to_attraction_point += delta

	else:
		total_time_close_to_attraction_point = 0.0
	
	if total_time_close_to_attraction_point >= max_time_close_to_attaction_point:
		on_attraction_point_reached.emit()
		attraction_point_reached = true

	if current_time_on_ground >= max_time_on_ground:
		# TODO: animation de mort de la feuille
		self.anim.play("despawn")
		await self.anim.animation_finished
		print("queue free!")
		queue_free()
		

func _physics_process(delta: float) -> void:
	if attraction_point != null:
		# TODO : faire varier la hauteur de manière un peu aléatoire
		var target := attraction_point.global_position
		var pull_vector := (target - global_position).normalized()
		var tangent := Vector2(-pull_vector.y, pull_vector.x)
		var max_dist := 96.0
		var distance_ratio := clampf((target - global_position).length() / max_dist, 0.0, 1.0)
		
		var pull_force := 300.0 * (1.0 - distance_ratio)
		var tangential_force := 150.0 * distance_ratio
		apply_central_force(pull_vector * pull_force)
		apply_central_force(tangent * tangential_force)
	else:
		self.elevation_z = maxf(0, self.elevation_z - (delta * leave_gravity))
		pass

func set_attraction_point(obj: Node2D) -> void:
	attraction_point = obj
