extends Control


signal play_up
signal normal_speed_up
signal increase_simulation_speed_up
signal decrease_simulation_speed_up
signal normal_scale_up
signal increase_scale_up
signal decrease_scale_up
signal quit_button_up


func _on_play_button_up() -> void:
	play_up.emit()


func _on_normal_speed_button_up() -> void:
	normal_speed_up.emit()


func _on_increase_simulation_speed_button_up() -> void:
	increase_simulation_speed_up.emit()


func _on_decrease_simulation_speed_button_up() -> void:
	decrease_simulation_speed_up.emit()


func _on_quit_button_up() -> void:
	quit_button_up.emit()


func _on_normal_scale_button_up() -> void:
	normal_scale_up.emit()


func _on_increase_scale_button_up() -> void:
	increase_scale_up.emit()


func _on_decrease_scale_button_up() -> void:
	decrease_scale_up.emit()
