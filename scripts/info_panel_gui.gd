class_name InfoPanelGui
extends MarginContainer

signal close_button_up

@onready var _name_label: Label = $VBoxContainer/NameLabel
@onready var _description_text_label: RichTextLabel = \
		$VBoxContainer/DescriptionTextLabel


var body_name: String:
	get:
		return _name_label.text
	set(value):
		_name_label.text = value


var description: String:
	get:
		return _description_text_label.text
	set(value):
		_description_text_label.text = value


func _ready() -> void:
	body_name = ""
	description = ""


func _on_close_button_button_up() -> void:
	close_button_up.emit()
