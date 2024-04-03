class_name HudGui
extends Control

@onready var _body_name_label: FadingLabel = %BodyNameLabel
@onready var _movement_speed_label: FadingLabel = %MovementSpeedLabel
@onready var _simulation_scale_label: FadingLabel = %SimulationScaleLabel
@onready var _simulation_speed_label: FadingLabel = %SimulationSpeedLabel


func display_body_name(body_name: String) -> void:
	_body_name_label.display(body_name)


func display_movement_speed(speed: float) -> void:
	var formatted_speed: String = "Movement speed: %.1fx" % speed
	_movement_speed_label.display(formatted_speed)

func display_simulation_scale(simulation_scale: float) -> void:
	var formatted_simulation_scale: String = "Simulation scale: %.1fx" % simulation_scale
	_simulation_scale_label.display(formatted_simulation_scale)

func display_simulation_speed(simulation_speed: float) -> void:
	var formatted_simulation_speed: String = "Simulation speed: %.1fx" % simulation_speed
	_simulation_speed_label.display(formatted_simulation_speed)
