extends Node3D

const _SYSTEM_HEIGHT_OFFSET: float = -0.3

@onready var _world_environment: WorldEnvironment = $WorldEnvironment
@onready var _camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var _console: Node3D = $XROrigin3D/XRCamera3D/Console
@onready var _left_controller: XRController3D = $XROrigin3D/LeftController
@onready var _right_controller: XRController3D = $XROrigin3D/RightController
@onready var _pointer: XRToolsFunctionPointer = $XROrigin3D/RightController/FunctionPointer
@onready var _movement_direct: XRToolsMovementDirect = $XROrigin3D/RightController/MovementDirect
@onready var _tooltip: Node3D = $XROrigin3D/XRCamera3D/Tooltip
@onready var _system: Node3D = $System
@onready var _floor: StaticBody3D = $Floor
@onready var _menu: Node3D = $Menu
@onready var _menu_screen: Node3D = $Menu/Screen
@onready var _info_panel: Node3D = $InfoPanel
@onready var _info_panel_screen: Node3D = $InfoPanel/Screen

@onready var _environment: Environment = _world_environment.environment
@onready var _initial_pointer_distance: float = _pointer.distance
@onready var _initial_movement_speed: float = _movement_direct.max_speed
@onready var _tooltip_gui: TooltipGui = _tooltip.scene_node
@onready var _info_panel_gui: InfoPanelGui = _info_panel_screen.scene_node


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

var _xr_interface: XRInterface
var _is_game_paused: bool = false
var _old_simulation_speed_factor: float


var _passthrough_enabled: bool:
	get:
		return _xr_interface.is_passthrough_enabled()
	set(value):
		_floor.visible = not value
		
		if value:
			_environment.background_color.a = 0
			_xr_interface.start_passthrough()
		else:
			_environment.background_color.a = 1
			_xr_interface.stop_passthrough()


var _is_menu_enabled: bool:
	get:
		return _menu_screen.visible
	set(value):
		if value == true:
			_menu.position = Vector3(
				_camera.global_position.x,
				
				clamp(
					_camera.global_position.y,
					_menu_screen.screen_size.y / 2,
					_camera.global_position.y
				),
				
				_camera.global_position.z
			)
			
			_menu.global_rotation.y = _camera.global_rotation.y
			_is_info_panel_enabled = false
		
		_menu_screen.visible = value
		_menu_screen.enabled = value
		
		_update_pointer_enabled()


var _is_info_panel_enabled: bool:
	get:
		return _info_panel_screen.visible
	set(value):
		if value == true:
			_info_panel.position = Vector3(
				_camera.global_position.x,
				
				clamp(
					_camera.global_position.y,
					_info_panel_screen.screen_size.y / 2,
					_camera.global_position.y
				),
				
				_camera.global_position.z
			)
			
			_info_panel.global_rotation.y = _camera.global_rotation.y
			
			_info_panel_gui.body_name = _selected_body.body_name
			_info_panel_gui.description = _selected_body.description
			
			_is_menu_enabled = false
		
		_info_panel_screen.visible = value
		_info_panel_screen.enabled = value
		
		_update_pointer_enabled()


var _is_pointer_button_pressed: bool = false

var _is_body_selected: bool = false
var _selected_body: Body

var _is_displacing_system: bool = false
var _right_controller_initial_position: Vector3
var _system_initial_position: Vector3


func _ready() -> void:
	Game.console = _console.scene_node
	_set_up_xr()
	_set_up_controls()
	_set_up_system()
	_is_menu_enabled = false
	_is_info_panel_enabled = false
	_tooltip.visible = false


func _process(_delta: float) -> void:
	Game.player_camera_position = _camera.global_position
	_pointer.distance = _initial_pointer_distance * Game.simulation_scale
	_set_movement_speed()
	_displace_system()


func _set_up_xr() -> void:
	_xr_interface = XRServer.find_interface("OpenXR")
	
	if _xr_interface != null and _xr_interface.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	else:
		printerr("OpenXR not initialized.")
	
	_xr_interface.environment_blend_mode = _xr_interface.XR_ENV_BLEND_MODE_ALPHA_BLEND
	get_viewport().transparent_bg = true


func _set_up_controls() -> void:
	_menu_screen.connect_scene_signal("play_up", _on_menu_gui_play_button_up)
	_menu_screen.connect_scene_signal("normal_speed_up", _on_menu_gui_normal_speed_button_up)
	_menu_screen.connect_scene_signal("increase_simulation_speed_up", _on_menu_gui_increase_simulation_speed_up)
	_menu_screen.connect_scene_signal("decrease_simulation_speed_up", _on_menu_gui_decrease_simulation_speed_up)
	_menu_screen.connect_scene_signal("normal_scale_up", _on_menu_gui_normal_scale_button_up)
	_menu_screen.connect_scene_signal("increase_scale_up", _on_menu_gui_increase_scale_up)
	_menu_screen.connect_scene_signal("decrease_scale_up", _on_menu_gui_decrease_scale_up)
	_menu_screen.connect_scene_signal("passthrough_toggled", _on_menu_gui_passthrough_toggled)
	_menu_screen.connect_scene_signal("quit_button_up", _on_menu_gui_quit_button_up)
	
	_info_panel_screen.connect_scene_signal("close_button_up", _on_info_panel_close_button_up)


func _set_up_system() -> void:
	_system.position.y = _camera.global_position.y + _SYSTEM_HEIGHT_OFFSET


func _set_movement_speed() -> void:
	if not _left_controller.is_button_pressed("grip_click"):
		_movement_direct.max_speed = _initial_movement_speed
	else:
		_movement_direct.max_speed = \
				_initial_movement_speed * Game.simulation_scale


func _displace_system() -> void:
	if not _is_displacing_system:
		return
	
	var displacement: Vector3 = \
			_right_controller.global_position - _right_controller_initial_position
	
	_system.global_position = _system_initial_position + displacement
	

func _update_pointer_enabled() -> void:
	var is_enabled: bool = \
			_is_pointer_button_pressed \
			or _is_menu_enabled \
			or _is_info_panel_enabled
	
	_pointer.enabled = is_enabled
	_pointer.visible = is_enabled


func _on_left_controller_button_pressed(button_name: String) -> void:
	if button_name == "ax_button":
		_is_menu_enabled = not _is_menu_enabled


func _on_right_controller_button_pressed(button_name: String) -> void:
	match button_name:
		"trigger_click":
			_is_pointer_button_pressed = true
			_update_pointer_enabled()
		"grip_click":
			_is_displacing_system = true
			_right_controller_initial_position = \
					_right_controller.global_position
			_system_initial_position = _system.global_position


func _on_right_controller_button_released(button_name: String) -> void:
	match button_name:
		"ax_button":
			if _is_body_selected:
				_is_info_panel_enabled = true
		"trigger_click":
			_is_pointer_button_pressed = false
			_update_pointer_enabled()
		"grip_click":
			_is_displacing_system = false


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


func _on_menu_gui_passthrough_toggled(toggled_on: bool) -> void:
	_passthrough_enabled = toggled_on


func _on_menu_gui_decrease_scale_up() -> void:
	Game.simulation_scale /= 2


func _on_menu_gui_quit_button_up() -> void:
	get_tree().quit()


func _on_info_panel_close_button_up() -> void:
	_is_info_panel_enabled = false


func _on_body_area_pointer_event(event: XRToolsPointerEvent) -> void:
	_selected_body = event.target.get_parent()
	
	match event.event_type:
		XRToolsPointerEvent.Type.ENTERED:
			_selected_body.selected = true
			
			_tooltip_gui.text = _selected_body.body_name
			_tooltip.visible = true
			
			_is_body_selected = true
		XRToolsPointerEvent.Type.EXITED:
			_selected_body.selected = false
			_tooltip.visible = false
			_is_body_selected = false
