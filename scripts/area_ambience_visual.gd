extends Node2D
class_name AreaAmbienceVisual

# The ID of the area to which this player corresponds
@export var area_id : int = 0

# True if this audio corresponds to a desolated area.
@export var is_desolated: bool = false

var items : Array[CanvasItem] = []
@export var fade_duration: float = 1

func _ready() -> void:
	items.append_array(get_children())

func transition(animate: bool, shown: bool) -> void:
	if animate:
		var tween := get_tree().create_tween()

		var ease_type := Tween.EASE_OUT if shown else Tween.EASE_IN
		var final_val := Color(1, 1, 1, 1) if shown else Color(1, 1, 1, 0)
		var start_val := Color(1, 1, 1, 1) if not shown else Color(1, 1, 1, 0)
		for item in items:
			if not item.visible:
				item.visible = true
				item.modulate = start_val

			tween.parallel().tween_property(item, 'modulate', final_val, fade_duration). \
				set_ease(ease_type).set_trans(Tween.TRANS_QUAD)
			
		await tween.finished
		
		tween.kill()
	
	for item in items:
		item.visible = shown
