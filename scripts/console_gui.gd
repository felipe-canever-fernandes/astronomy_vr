class_name ConsoleGui
extends Control

const _MAXIMUM_LINE_COUNT: int = 25

@onready var _text_label: Label = $TextLabel


var _line_count: int:
	get:
		return _text_label.text.count("\n")


func _ready() -> void:
	_text_label.text = ""


func write(text: String = "") -> void:
	_text_label.text += text + "\n"

	if _line_count > _MAXIMUM_LINE_COUNT:
		var second_line_index: int = _text_label.text.find("\n") + 1
		_text_label.text = _text_label.text.substr(second_line_index)
