class_name HudGui
extends Control

@onready var _body_name_label: FadingLabel = %BodyNameLabel
@onready var _movement_speed_label: FadingLabel = %MovementSpeedLabel


func display_body_name(body_name: String) -> void:
	_body_name_label.display(body_name)


func display_movement_speed(speed: float) -> void:
	var formatted_speed: String = "Movement speed: %.1fx" % speed
	_movement_speed_label.display(formatted_speed)
