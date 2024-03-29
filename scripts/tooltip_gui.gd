class_name TooltipGui
extends Control

@onready var _label: Label = $Label


var text: String:
	get:
		return _label.text
	set(value):
		_label.text = value
