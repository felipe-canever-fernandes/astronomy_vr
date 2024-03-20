extends Control

signal quit_button_up


func _on_quit_button_up() -> void:
	quit_button_up.emit()
