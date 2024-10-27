class_name Menu
extends Control

signal play_clicked

@onready var _play_button := %PlayButton as Button
@onready var _quest_label : RichTextLabel = %QuestLabel
@onready var _writing_sfx : AudioStreamPlayer = %WritingFX

var is_shown := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	_play_button.pressed.connect(play_clicked.emit)

func display_current_quest_text(txt: String) -> void:
	_quest_label.text = txt
	_quest_label.visible_characters = 0
	_writing_sfx.play()
	
	for i in range(0, _quest_label.get_total_character_count(), 1):
		_quest_label.visible_characters = i

		for _f in range(2):
			await get_tree().process_frame
	
	_writing_sfx.stop()

var _tween : Tween

func is_animating() -> bool:
	return _tween != null and _tween.is_running()

func animate_show() -> void:
	if is_shown:
		return

	if is_animating():
		_tween.kill()
	
	Config.sfx.play_page_turn_fx()
	
	is_shown = true
	_tween = create_tween()
	_tween.tween_property(self, "position:y", 0, 0.7).from(-size.y) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.parallel().tween_callback(show)
	
	await _tween.finished

func animate_hide() -> void:
	if not is_shown:
		return
	
	if is_animating():
		_tween.kill()
	
	Config.sfx.play_page_turn_fx()
	
	is_shown = false
	_tween = create_tween()
	_tween.tween_property(self, "position:y", -size.y, 0.5).from_current() \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_callback(hide)
	
	await _tween.finished
