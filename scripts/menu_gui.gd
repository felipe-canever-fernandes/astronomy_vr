class_name MenuGui
extends Control

signal labels_check_button_toggled(toggled_on: bool)


func _on_labels_check_button_toggled(toggled_on: bool) -> void:
	labels_check_button_toggled.emit(toggled_on)
