extends Control
class_name HUD

signal open_menu_clicked

@onready var _open_menu_button := %OpenMenuButton as TextureButton
@onready var _leave_textures : Array[Control] = [
	%Control1, %Control2, %Control3
]
@onready var _leave_labels : Array[Label] = [
	%Leave1Label, %Leave2Label, %Leave3Label
]
@onready var _leave_progress : Array[Range] = [
	%TextureProgressBar1, %TextureProgressBar2, %TextureProgressBar3
]
var _leave_tweens : Array[Tween] = [null, null, null]
var _displayed_leave_counts : Array[int] = [0, 0, 0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_leave_count(_displayed_leave_counts, false)
	_open_menu_button.pressed.connect(open_menu_clicked.emit)

func update_leave_count(leaves: Array[int], animate: bool) -> void:
	for i in range(_leave_labels.size()):
		_leave_labels[i].text = str(leaves[i] / Config.LEAVES_PER_PILE)
		_leave_progress[i].value = leaves[i] % Config.LEAVES_PER_PILE
		# Animation
		if _displayed_leave_counts[i] != leaves[i] and animate:
			_displayed_leave_counts[i] = leaves[i]
			_ui_fuzz_fx(i)

func ui_fuzz_fx(leave_type: Leave.LeaveType) -> void:
	_ui_fuzz_fx(int(leave_type))

func _ui_fuzz_fx(i: int) -> void:
	if _leave_tweens[i] != null:
		_leave_tweens[i].kill()

	_leave_tweens[i] = create_tween()
	_leave_tweens[i].tween_property(_leave_textures[i], "position:y", 0, 0.5) \
		.from(-10.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
