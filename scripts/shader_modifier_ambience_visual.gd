extends AreaAmbienceVisual

@export var shader: ShaderMaterial
@export var param_from := 0.8
@export var param_to := 0.0

# All house + barrier tiles
var tiles := [
	Vector2i(0, 5),
	Vector2i(1, 5),
	Vector2i(2, 5),
	Vector2i(3, 5),
	Vector2i(4, 5),
	Vector2i(5, 5),
	Vector2i(6, 5),
	Vector2i(7, 5),
	Vector2i(3, 6),
	Vector2i(4, 6),
	Vector2i(5, 6),
]

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
	for tile: Vector2i in tiles:
		var tileset := Config.ground_2d.tile_set
		var ts_source : TileSetAtlasSource = tileset.get_source(0)
		var tile_data := ts_source.get_tile_data(tile, 0)
		if not tile_data.material is ShaderMaterial:
			continue
		
		var mat : ShaderMaterial = tile_data.material
		mat.set_shader_parameter('factor', p)
