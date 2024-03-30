extends Node

signal simulation_scale_changed(new_scale: float)

var console: ConsoleGui

var player_camera_position: Vector3

var simulation_speed: float = 1

var _simulation_scale: float = 1

var simulation_scale: float:
	get:
		return _simulation_scale
	set(value):
		_simulation_scale = value
		simulation_scale_changed.emit(value)
