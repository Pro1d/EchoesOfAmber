extends Control

@onready var _leave_textures : Array[Control] = [
	%TextureRect1, %TextureRect2, %TextureRect3
]
@onready var _leave_labels : Array[Label] = [
	%Leave1Label, %Leave2Label, %Leave3Label
]
var _leave_tweens : Array[Tween] = [null, null, null]
var _displayed_leaves : Array[int] = [0, 0, 0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_leave_count(_displayed_leaves, false)

func update_leave_count(leaves: Array[int], animate: bool) -> void:
	for i in range(_leave_labels.size()):
		_leave_labels[i].text = str(leaves[i])
		
		# Animation
		if _displayed_leaves[i] != leaves[i] and animate:
			if _leave_tweens[i] != null:
				_leave_tweens[i].kill()
			_leave_tweens[i] = create_tween()
			_leave_tweens[i].tween_property(_leave_textures[i], "position:y", 0, 0.5) \
				.from(-12.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
