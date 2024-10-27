extends AreaAmbienceVisual

@onready var sprite : Squirrel = $Squirrel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func transition(_animate: bool, shown: bool) -> void:
	sprite.visible = shown
	
	if shown:
		# Make the squirrel eat faster =p
		sprite.eating_start_time = Time.get_ticks_msec() - 4500
		sprite.reset_anim_to_right()
