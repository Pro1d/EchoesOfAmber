extends AreaAmbienceVisual

@export var shader: ShaderMaterial
@export var param_from := 0.8
@export var param_to := 0.0

func transition(animate: bool, shown: bool) -> void:
	super(animate, shown)
	
	var final_value := param_to if shown else param_from
	var start_value := param_to if not shown else param_from

	if animate:
		set_shader_param(start_value)
		var tween := get_tree().create_tween()
		tween.tween_method(set_shader_param, start_value, final_value, fade_duration)
		await tween.finished
	
	set_shader_param(final_value)

func set_shader_param(p: float) -> void:
	shader.set_shader_parameter('factor', p)
