class_name HudGui
extends Control

@onready var _body_name_label: FadingLabel = %BodyNameLabel
@onready var _speed_label: FadingLabel = %SpeedLabel


func display_body_name(body_name: String) -> void:
	_body_name_label.display(body_name)


func display_speed(speed: float) -> void:
	var formatted_speed: String = "Speed: %.1fx" % speed
	_speed_label.display(formatted_speed)
