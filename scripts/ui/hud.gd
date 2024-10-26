extends Control
class_name HUD

signal open_menu_clicked

@onready var _open_menu_button := %OpenMenuButton as Button
@onready var _leave_textures : Array[Control] = [
	%TextureRect1, %TextureRect2, %TextureRect3
]
@onready var _leave_labels : Array[Label] = [
	%Leave1Label, %Leave2Label, %Leave3Label
]
var _leave_tweens : Array[Tween] = [null, null, null]
var _displayed_leave_counts : Array[int] = [0, 0, 0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_leave_count(_displayed_leave_counts, false)
	_open_menu_button.pressed.connect(open_menu_clicked.emit)

func update_leave_count(leaves: Array[int], animate: bool) -> void:
	for i in range(_leave_labels.size()):
		_leave_labels[i].text = str(leaves[i] / 10)
		
		# Animation
		if _displayed_leave_counts[i] != leaves[i] and animate:
			_displayed_leave_counts[i] = leaves[i]
			if _leave_tweens[i] != null:
				_leave_tweens[i].kill()
			_leave_tweens[i] = create_tween()
			_leave_tweens[i].tween_property(_leave_textures[i], "position:y", 0, 0.5) \
				.from(-12.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			
