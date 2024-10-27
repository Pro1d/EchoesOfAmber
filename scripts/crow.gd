extends AreaAmbienceVisual
class_name Crow

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var start_pos : Vector2 = self.global_position

var anim_duration := 2.0
var high_position_px := -12.0
var x_amplitude := 256.0
var y_amplitude := 256.0

func _ready() -> void:
	await fly_in()
	await get_tree().create_timer(2).timeout
	await fly_away()

func _process(_delta: float) -> void:
	pass
	
	
func transition(_a: bool, _s: bool) -> void:
	pass

func fly_in() -> void:
	visible = true
	print("fly in")
	sprite.play('move')
	var start_y : float = min(start_pos.y - y_amplitude, get_viewport().get_camera_2d().global_position.y - y_amplitude)
	global_position = Vector2(start_pos.x + randf_range(-x_amplitude, 0), start_y)
	sprite.position = Vector2()
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, 'global_position', start_pos, anim_duration)
	tween.tween_property(sprite, 'position', Vector2(0, 0), 0.5)
	await tween.finished
	sprite.play('default')
	

func fly_away() -> void:
	sprite.play('move')
	var end_y : float = min(start_pos.y - y_amplitude, get_viewport().get_camera_2d().global_position.y - y_amplitude)
	var end_x := global_position.x + randf_range(0, x_amplitude)

	var tween := get_tree().create_tween()
	tween.tween_property(sprite, 'position', Vector2(0, high_position_px), 0.5)
	tween.tween_property(self, 'global_position', Vector2(end_x, end_y), anim_duration)
	await tween.finished
	visible = false
