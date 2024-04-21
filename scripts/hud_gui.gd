class_name HudGui
extends Control

@onready var _following_body_name_container: VBoxContainer = %FollowingBodyNameContainer
@onready var _following_body_name_label: Label = %FollowingBodyNameLabel
@onready var _body_name_label: FadingLabel = %BodyNameLabel
@onready var _movement_speed_label: FadingLabel = %MovementSpeedLabel
@onready var _simulation_scale_label: FadingLabel = %SimulationScaleLabel
@onready var _simulation_speed_label: FadingLabel = %SimulationSpeedLabel


func _ready() -> void:
	hide_following_body_name()


func display_following_body_name(body_name: String) -> void:
	_following_body_name_label.text = body_name
	_following_body_name_container.visible = true


func hide_following_body_name() -> void:
	_following_body_name_container.visible = false


func display_body_name(body_name: String) -> void:
	_body_name_label.display(body_name)


func display_movement_speed(speed: float) -> void:
	var formatted_speed: String = "Movement speed: %dx" % speed
	
	_movement_speed_label.display(formatted_speed)


func display_simulation_scale(simulation_scale: float) -> void:
	var formatted_simulation_scale: String =  \
			"Simulation Scale: {scale}x".format({"scale": simulation_scale})
	
	_simulation_scale_label.display(formatted_simulation_scale)


func display_simulation_speed(simulation_speed: float) -> void:
	var formatted_simulation_speed: String = \
			"Simulation Speed: {speed}x".format({"speed": simulation_speed})

	_simulation_speed_label.display(formatted_simulation_speed)
