class_name Menu
extends Control

signal play_clicked

@onready var _play_button := %PlayButton as Button
@onready var _quest_label : RichTextLabel = %QuestLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_play_button.pressed.connect(play_clicked.emit)

func display_current_quest_text(txt: String) -> void:
	_quest_label.append_text(txt)
	_quest_label.visible_characters = 0
	
	for i in range(0, len(txt), 1):
		_quest_label.visible_characters = i

		for _f in range(3):
			await get_tree().process_frame
