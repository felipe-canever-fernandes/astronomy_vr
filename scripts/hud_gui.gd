class_name HudGui
extends Control

@onready var _menu_container: VBoxContainer = %MenuContainer
@onready var _following_body_name_container: VBoxContainer = %FollowingBodyNameContainer
@onready var _following_body_name_label: Label = %FollowingBodyNameLabel
@onready var _body_name_label: FadingLabel = %BodyNameLabel
@onready var _movement_speed_label: Label = %MovementSpeedLabel
@onready var _simulation_scale_label: Label = %SimulationScaleLabel
@onready var _simulation_speed_label: Label = %SimulationSpeedLabel

var _body_name: String = ""
var _movement_speed: float = 0
var _simulation_scale: float = 0
var _simulation_speed: float = 0


func _ready() -> void:
	hide_following_body_name()


func _notification(what: int) -> void:
	if what != Node.NOTIFICATION_TRANSLATION_CHANGED:
		return
	
	_update_body_name(_body_name, false)
	_update_movement_speed(_movement_speed)
	_update_simulation_scale(_simulation_scale)
	_update_simulation_speed(_simulation_speed)


func hide_menu_help() -> void:
	_menu_container.visible = false


func display_following_body_name(body_name: String) -> void:
	_following_body_name_label.text = body_name
	_following_body_name_container.visible = true


func hide_following_body_name() -> void:
	_following_body_name_container.visible = false


func display_body_name(body_name: String) -> void:
	_body_name = body_name
	_update_body_name(body_name, true)


func display_movement_speed(movement_speed: float) -> void:
	_movement_speed = movement_speed
	_update_movement_speed(_movement_speed)


func display_simulation_scale(simulation_scale: float) -> void:
	_simulation_scale = simulation_scale
	_update_simulation_scale(_simulation_scale)


func display_simulation_speed(simulation_speed: float) -> void:
	_simulation_speed = simulation_speed
	_update_simulation_speed(_simulation_speed)


func _update_body_name(body_name: String, should_reset: bool) -> void:
	_body_name_label.display(body_name, should_reset)


func _update_movement_speed(movement_speed: float) -> void:
	_movement_speed_label.text =  \
			tr("HUD_MOVEMENT_SPEED").format({
				"movement_speed": int(movement_speed)
			})


func _update_simulation_scale(simulation_scale: float) -> void:
	_simulation_scale_label.text =  \
			tr("HUD_SIMULATION_SCALE").format({
				"simulation_scale": simulation_scale
			})


func _update_simulation_speed(simulation_speed: float) -> void:
	_simulation_speed_label.text =  \
			tr("HUD_SIMULATION_SPEED").format({
				"simulation_speed": simulation_speed
			})
