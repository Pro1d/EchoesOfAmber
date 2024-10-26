class_name Menu
extends Control

signal play_clicked

@onready var _play_button := %PlayButton as Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_play_button.pressed.connect(play_clicked.emit)
