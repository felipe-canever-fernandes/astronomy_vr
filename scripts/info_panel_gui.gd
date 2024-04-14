class_name InfoPanelGui
extends MarginContainer

signal close_button_up
signal follow_button_up(body: Body)

@onready var _name_label: Label = $VBoxContainer/NameLabel
@onready var _description_text_label: RichTextLabel = \
		$VBoxContainer/DescriptionTextLabel

var _body: Body


var body: Body:
	get:
		return _body
	set(value):
		
		_body = value
		
		if _body != null:
			_name_label.text = _body.body_name
			_description_text_label.text = _body.description
		else:
			_name_label.text = ""
			_description_text_label.text = ""


func _ready() -> void:
	body = null


func _on_close_button_button_up() -> void:
	close_button_up.emit()


func _on_follow_button_button_up() -> void:
	follow_button_up.emit(body)
