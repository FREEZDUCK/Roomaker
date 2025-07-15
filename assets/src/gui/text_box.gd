extends Control

@export var text : String
@export var back_trans : bool = false

var prev_text : String

func _ready():
	_set_text(text)
	if back_trans == true:
		$back.visible = false

func _process(delta):
	$back.size.x = $text.size.x * 0.5 + 11
	$back.size.y = $text.size.y * 0.5 + 11
	if text != prev_text:
		_set_text(text)

func _set_text(text : String):
	$text.text = text
	prev_text = text
