extends Control
class_name BlackBars

@onready var top_rect : ColorRect = $TopRect
@onready var bottom_rect : ColorRect = $BottomRect

func set_enabled(enabled: bool) -> void:
	var tween := get_tree().create_tween()
	
	var start_value := 1 if not enabled else 0
	var end_value := 1 if enabled else 0
	
	var rects : Array[ColorRect] = [top_rect, bottom_rect]
	
	for rect in rects:
		rect.visible = true
		rect.scale = Vector2(1, start_value)

		tween.parallel().tween_property(rect, "scale", Vector2(1, end_value), 1.0)
	
	await tween.finished
	
	if not enabled:
		for rect in rects:
			rect.visible = false
	
	tween.kill()
