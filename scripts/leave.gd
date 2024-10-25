extends RigidBody2D
class_name Leave

var atraction_point: Node2D = null

func _ready() -> void:
	pass 


func _process(_delta: float) -> void:
	pass
	
	
func _physics_process(_delta: float) -> void:
	if self.atraction_point != null:
		# TODO : change the vector in function of the distance
		var target := atraction_point.position
		var dir_to_target := self.position - target
		var direction_vector := dir_to_target.rotated(deg_to_rad(170))
		apply_central_force(direction_vector * 8)
	else:
		pass
	

func set_attraction_point(obj: Node2D) -> void:
	self.atraction_point = obj
