extends Control


signal play_up
signal increase_simulation_speed_up
signal decrease_simulation_speed_up
signal quit_button_up


func _on_play_button_up() -> void:
	play_up.emit()


func _on_increase_simulation_speed_button_up() -> void:
	increase_simulation_speed_up.emit()


func _on_decrease_simulation_speed_button_up() -> void:
	decrease_simulation_speed_up.emit()


func _on_quit_button_up() -> void:
	quit_button_up.emit()
