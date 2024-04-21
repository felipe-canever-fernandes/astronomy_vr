class_name MenuGui
extends Control

signal labels_check_button_toggled(toggled_on: bool)
signal passthrough_check_button_toggled(toggled_on: bool)

@onready var _passthrough_check_button: CheckButton = %PassthroughCheckButton


func set_passthrough_check_button(toggled_on: bool):
	_passthrough_check_button.button_pressed = toggled_on


func _on_labels_check_button_toggled(toggled_on: bool) -> void:
	labels_check_button_toggled.emit(toggled_on)


func _on_passthrough_check_button_toggled(toggled_on: bool) -> void:
	passthrough_check_button_toggled.emit(toggled_on)
