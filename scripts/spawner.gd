extends Node2D
class_name Spawner


@onready var leave_resource := preload('res://scenes/leave.tscn')

var spawn_period := 1.5 # leaves / second
var max_alive_leaves := 10 # max alive entities
var type : String = 'red'
var elapsed : float = 0.0
var spawned_entities := []
var spawn_period_offset : float = 0.0

var spawn_offset_range : float = 16

func _ready() -> void:
	spawn_period_offset = randf_range(-0.3, 0.3)

func _process(delta: float) -> void:
	elapsed += delta
	
	var real_period := spawn_period + spawn_period_offset

	if elapsed >= real_period and len(spawned_entities) < max_alive_leaves:
		var leave : Leave = leave_resource.instantiate()
		leave.type = self.type
		leave.elevation_z = 32
		leave.global_position = self.global_position + Vector2(
			randf_range(-spawn_offset_range, spawn_offset_range),
			randf_range(-spawn_offset_range, spawn_offset_range)
		)
		Config.root_2d.add_child(leave)
		spawned_entities.append(leave)
		elapsed = 0
	
	# Remove dead entities from the list
	self.spawned_entities = self.spawned_entities.filter(func(e: Leave) -> bool: return is_instance_valid(e));
