class_name MenuGui
extends Control

signal simulation_speed_slider_changed(value: int)
signal labels_check_button_toggled(toggled_on: bool)
signal passthrough_check_button_toggled(toggled_on: bool)

@onready var _simulation_speed_slider: HSlider = %SimulationSpeedSlider
@onready var _simulation_speed_value_label: Label = %SimulationSpeedValueLabel
@onready var _passthrough_check_button: CheckButton = %PassthroughCheckButton

var _simulation_speeds: Array[float]


func set_up_simulation_speed_slider(
	values: Array[float],
	initial_index: int
) -> void:
	_simulation_speeds = values
	_simulation_speed_slider.max_value = len(values) - 1
	_simulation_speed_slider.value = initial_index


func set_simulation_speed_slider_value(value: int) -> void:
	_simulation_speed_slider.value = value


func set_passthrough_check_button(toggled_on: bool) -> void:
	_passthrough_check_button.button_pressed = toggled_on


func _on_simulation_speed_slider_value_changed(value: float) -> void:
	var simulation_speed: float = _simulation_speeds[value]
	
	_simulation_speed_value_label.text = "{speed}x".format({
		"speed": simulation_speed
	})
	
	simulation_speed_slider_changed.emit(value)


func _on_labels_check_button_toggled(toggled_on: bool) -> void:
	labels_check_button_toggled.emit(toggled_on)


func _on_passthrough_check_button_toggled(toggled_on: bool) -> void:
	passthrough_check_button_toggled.emit(toggled_on)
