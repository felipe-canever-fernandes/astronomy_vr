extends Node3D

const _SYSTEM_HEIGHT_OFFSET := -0.3

@onready var _camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var _menu: Node3D = $XROrigin3D/LeftController/Menu
@onready var _pointer: XRToolsFunctionPointer = $XROrigin3D/RightController/FunctionPointer
@onready var _system: Node3D = $System


@export var simulation_speed: float:
	get:
		return Game.simulation_speed
	set(value):
		Game.simulation_speed = value


@export var simulation_scale: float:
	get:
		return Game.simulation_scale
	set(value):
		Game.simulation_scale = value


var _is_game_paused: bool = false
var _old_simulation_speed_factor: float


var _menu_enabled: bool:
	get:
		return _menu.visible
	set(value):
		_menu.visible = value
		_menu.enabled = value
		
		_pointer.visible = value
		_pointer.enabled = value


func _ready() -> void:
	_set_up_xr()
	_set_up_controls()
	_set_up_system()
	_menu_enabled = false


func _process(_delta: float) -> void:
	Game.player_camera_position = _camera.global_position


func _set_up_xr() -> void:
	var xr_interface := XRServer.find_interface("OpenXR")
	
	if xr_interface != null and xr_interface.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	else:
		printerr("OpenXR not initialized.")


func _set_up_controls() -> void:
	_menu.connect_scene_signal("play_up", _on_menu_gui_play_button_up)
	_menu.connect_scene_signal("normal_speed_up", _on_menu_gui_normal_speed_button_up)
	_menu.connect_scene_signal("increase_simulation_speed_up", _on_menu_gui_increase_simulation_speed_up)
	_menu.connect_scene_signal("decrease_simulation_speed_up", _on_menu_gui_decrease_simulation_speed_up)
	_menu.connect_scene_signal("normal_scale_up", _on_menu_gui_normal_scale_button_up)
	_menu.connect_scene_signal("increase_scale_up", _on_menu_gui_increase_scale_up)
	_menu.connect_scene_signal("decrease_scale_up", _on_menu_gui_decrease_scale_up)
	_menu.connect_scene_signal("quit_button_up", _on_menu_gui_quit_button_up)


func _set_up_system() -> void:
	_system.position.y = _camera.global_position.y + _SYSTEM_HEIGHT_OFFSET


func _on_left_controller_button_pressed(button_name: String) -> void:
	if button_name == "ax_button":
		_menu_enabled = not _menu_enabled


func _on_menu_gui_play_button_up() -> void:
	_is_game_paused = not _is_game_paused

	if _is_game_paused:
		_old_simulation_speed_factor = Game.simulation_speed
		Game.simulation_speed = 0
	else:
		Game.simulation_speed = _old_simulation_speed_factor


func _on_menu_gui_normal_speed_button_up() -> void:
	if not _is_game_paused:
		Game.simulation_speed = 1


func _on_menu_gui_increase_simulation_speed_up() -> void:
	if not _is_game_paused:
		Game.simulation_speed *= 2


func _on_menu_gui_decrease_simulation_speed_up() -> void:
	if not _is_game_paused:
		Game.simulation_speed /= 2


func _on_menu_gui_normal_scale_button_up() -> void:
	Game.simulation_scale = 1


func _on_menu_gui_increase_scale_up() -> void:
	Game.simulation_scale *= 2


func _on_menu_gui_decrease_scale_up() -> void:
	Game.simulation_scale /= 2


func _on_menu_gui_quit_button_up() -> void:
	get_tree().quit()
