extends Control

@onready var _speed_label: Label = $VBoxContainer/Scales/SpeedContainer/Label
@onready var _scale_label: Label = $VBoxContainer/Scales/ScaleContainer/Label

signal play_up
signal normal_speed_up
signal increase_simulation_speed_up
signal decrease_simulation_speed_up
signal normal_scale_up
signal increase_scale_up
signal decrease_scale_up
signal passthrough_toggled(toggled_on: bool)
signal quit_button_up


func _process(_delta: float) -> void:
	_speed_label.text = "Speed: %sx" % \
			[_format_scale_value(Game.simulation_speed)]
	
	_scale_label.text = "Scale: %sx" % \
			[_format_scale_value(Game.simulation_scale)]


func _format_scale_value(value: float) -> String:
	if value >= 1:
		return str(value)
	else:
		return "1/%s" % [1 / value]


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


func _on_passthrough_check_button_toggled(toggled_on: bool) -> void:
	passthrough_toggled.emit(toggled_on)
