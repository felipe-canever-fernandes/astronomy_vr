extends Node3D

const _SYSTEM_HEIGHT_OFFSET: float = -0.3

@onready var _world_environment: WorldEnvironment = $WorldEnvironment
@onready var _origin: XROrigin3D = %XROrigin3D
@onready var _camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var _console: Node3D = $XROrigin3D/XRCamera3D/Console
@onready var _left_controller: XRController3D = $XROrigin3D/LeftController
@onready var _right_controller: XRController3D = $XROrigin3D/RightController
@onready var _pointer: XRToolsFunctionPointer = $XROrigin3D/RightController/FunctionPointer
@onready var _hud: Node3D = %Hud
@onready var _system: XRToolsPickable = %System
@onready var _info_panel: Node3D = $InfoPanel
@onready var _info_panel_screen: Node3D = $InfoPanel/Screen

@onready var _environment: Environment = _world_environment.environment
@onready var _initial_sky_energy_multiplier: float = \
		_environment.background_energy_multiplier
@onready var _initial_pointer_distance: float = _pointer.distance
@onready var _hud_gui: HudGui = _hud.scene_node
@onready var _info_panel_gui: InfoPanelGui = _info_panel_screen.scene_node

@onready var _movement_speed: float = 0


@export var simulation_speed: float:
	get:
		return Game.simulation_speed
	set(value):
		Game.simulation_speed = value


@export var simulation_accelaration: float = 1
@export var simulation_speed_accelaration: float = 2


@export var simulation_scale: float:
	get:
		return Game.simulation_scale
	set(value):
		Game.simulation_scale = value


@export var initial_movement_speed: float = 0
@export var movement_acceleration: float = 0

var _xr_interface: XRInterface
var _is_game_paused: bool = false
var _old_simulation_speed_factor: float


var _passthrough_enabled: bool:
	get:
		return _xr_interface.is_passthrough_enabled()
	set(value):
		if value:
			_environment.background_energy_multiplier = 0
			_environment.background_color.a = 0
			_xr_interface.start_passthrough()
		else:
			_environment.background_energy_multiplier = \
					_initial_sky_energy_multiplier
			_environment.background_color.a = 1
			_xr_interface.stop_passthrough()


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
		
		_info_panel_screen.visible = value
		_info_panel_screen.enabled = value
		
		_update_pointer_enabled()


var _is_pointer_button_pressed: bool = false

var _is_body_selected: bool = false
var _selected_body: Body

var _is_pickup_button_pressed: bool = false
var _right_controller_initial_position: Vector3 = Vector3.ZERO

var _is_scale_button_pressed: bool = false
var _left_controller_initial_position: Vector3 = Vector3.ZERO
var _system_initial_scale: float = 0

var _simulation_speed_input_direction: float = 0
var _previous_simulation_speed_input_direction: float = 0

var _is_movement_speed_button_pressed: bool = false
var _previous_direction_x: int = 0


func _ready() -> void:
	Game.console = _console.scene_node
	Game.connect("simulation_scale_changed", _on_game_simulation_scale_changed)
	Game.connect("simulation_speed_changed", _on_game_simulation_speed_changed)
	_set_up_xr()
	_set_up_controls()
	_set_up_system()
	_is_info_panel_enabled = false


func _process(delta: float) -> void:
	Game.player_camera_position = _camera.global_position
	_pointer.distance = _initial_pointer_distance * Game.simulation_scale
	_set_simulation_speed(delta)
	_scale_system()
	_move(delta)


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
	_info_panel_screen.connect_scene_signal("close_button_up", _on_info_panel_close_button_up)


func _set_up_system() -> void:
	_system.position.y = _camera.global_position.y + _SYSTEM_HEIGHT_OFFSET


func _set_simulation_speed(delta: float) -> void:
	if _simulation_speed_input_direction \
			!= _previous_simulation_speed_input_direction:
		Game.simulation_speed += \
				simulation_speed_accelaration \
				* _simulation_speed_input_direction * delta
	
	_previous_simulation_speed_input_direction = \
			_simulation_speed_input_direction


func _scale_system() -> void:
	if not (_is_pickup_button_pressed and _is_scale_button_pressed):
		_system.enabled = true
		return
	
	_system.enabled = false
	
	var initial_distance: float = _left_controller_initial_position\
			.distance_to(_right_controller_initial_position)
	
	var final_distance: float = _left_controller.global_position\
			.distance_to(_right_controller.global_position)
	
	if initial_distance <= 0:
		return
	
	var ratio: float = final_distance / initial_distance
	Game.simulation_scale = _system_initial_scale * ratio


func _move(delta: float) -> void:
	var movement_vector: Vector2 = _left_controller.get_vector2("primary")
	var direction_y: float = movement_vector.y
	
	if not is_zero_approx(direction_y):
		if _is_movement_speed_button_pressed:
			_movement_speed += movement_acceleration * delta
	else:
		_movement_speed = initial_movement_speed
		return
	
	var movement_direction: Vector3 = -_camera.global_basis.z
	
	_origin.position += \
			direction_y \
			* movement_direction \
			* _movement_speed \
			* delta
	
	_hud_gui.display_movement_speed(_movement_speed)


func _update_pointer_enabled() -> void:
	var is_enabled: bool = _is_pointer_button_pressed or _is_info_panel_enabled
	
	_pointer.enabled = is_enabled
	_pointer.visible = is_enabled


func _on_left_controller_button_pressed(button_name: String) -> void:
	match button_name:
		"ax_button":
			_passthrough_enabled = not _passthrough_enabled
		"trigger_click":
			_is_movement_speed_button_pressed = true
		"grip_click":
			_is_scale_button_pressed = true
			_left_controller_initial_position = \
					_left_controller.global_position
			_system_initial_scale = Game.simulation_scale


func _on_left_controller_button_released(button_name: String) -> void:
	match button_name:
		"trigger_click":
			_is_movement_speed_button_pressed = false
		"grip_click":
			_is_scale_button_pressed = false


func _on_left_controller_input_vector_2_changed(
	button_name: String,
	value: Vector2
) -> void:
	if button_name != "primary":
		return
	
	var direction_x: int = round(abs(value.x)) * sign(value.x)
	
	if direction_x == _previous_direction_x:
		return
	
	_origin.rotate_y(deg_to_rad(15) * -direction_x)
	_previous_direction_x = direction_x


func _on_right_controller_button_pressed(button_name: String) -> void:
	match button_name:
		"primary_click":
			_toggle_is_game_paused()
		"by_button":
			Game.simulation_speed = 1
		"trigger_click":
			_is_pointer_button_pressed = true
			_update_pointer_enabled()
		"grip_click":
			_is_pickup_button_pressed = true
			_right_controller_initial_position = \
					_right_controller.global_position


func _on_right_controller_button_released(button_name: String) -> void:
	match button_name:
		"ax_button":
			if _is_body_selected:
				_is_info_panel_enabled = true
		"trigger_click":
			_is_pointer_button_pressed = false
			_update_pointer_enabled()
		"grip_click":
			_is_pickup_button_pressed = false


func _on_right_controller_input_vector_2_changed(
	_button_name: String,
	value: Vector2
) -> void:
	_simulation_speed_input_direction = value.x


func _toggle_is_game_paused() -> void:
	_is_game_paused = not _is_game_paused

	if _is_game_paused:
		_old_simulation_speed_factor = Game.simulation_speed
		Game.simulation_speed = 0
	else:
		Game.simulation_speed = _old_simulation_speed_factor


func _on_info_panel_close_button_up() -> void:
	_is_info_panel_enabled = false
	

func _on_function_pointer_pointing_event(event: XRToolsPointerEvent) -> void:
	if not (event.target is BodyArea):
		return 
	
	_selected_body = event.target.get_parent()
	
	match event.event_type:
		XRToolsPointerEvent.Type.ENTERED:
			_selected_body.selected = true
			_hud_gui.display_body_name(_selected_body.body_name)
			_is_body_selected = true
		XRToolsPointerEvent.Type.EXITED:
			_selected_body.selected = false
			_is_body_selected = false


func _on_game_simulation_scale_changed(new_scale: float) -> void:
	_hud_gui.display_simulation_scale(new_scale)


func _on_game_simulation_speed_changed(new_speed: float) -> void:
	_hud_gui.display_simulation_speed(new_speed)
