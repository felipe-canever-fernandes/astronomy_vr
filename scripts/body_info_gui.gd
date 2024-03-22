extends Control
class_name  BodyInfoGUI

@export var text: String:
    get:
        return _info_label.text
    set(value):
        _info_label.text = value

@onready var _info_label := $MarginContainer/Info
