extends AreaAmbienceVisual

@onready var sprite : Sprite2D = $Squirrel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func transition(_animate: bool, shown: bool) -> void:
	if shown:
		sprite.visible = true
		
