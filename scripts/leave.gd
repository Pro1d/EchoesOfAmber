extends RigidBody2D
class_name Leave

var attraction_point: Node2D = null

func _ready() -> void:
	pass 


func _process(_delta: float) -> void:
	pass
	
	
func _physics_process(_delta: float) -> void:
	if attraction_point != null:
		# TODO : change the vector in function of the distance
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
		pass
	

func set_attraction_point(obj: Node2D) -> void:
	attraction_point = obj
