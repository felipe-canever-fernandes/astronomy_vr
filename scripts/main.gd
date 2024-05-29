extends Node3D

const _SYSTEM_HEIGHT_OFFSET: float = -0.3
const _SIMULATION_SPEED_INDICES_PER_METER: int = 100
const _GO_TO_MINIMUM_OFFSET: float = 1

const _SIMULATION_SPEEDS: Array[float] = [
	-5000,
	-2500,
	-1000,
	-500,
	-250,
	-100,
	-50,
	-25,
	-10,
	-5,
	-1,
	-0.75,
	-0.5,
	-0.25,
	-0.1,
	-0.05,
	-0.01,
	0,
	0.01,
	0.05,
	0.1,
	0.25,
	0.5,
	0.75,
	1,
	5,
	10,
	25,
	50,
	100,
	250,
	500,
	1000,
	2500,
	5000,
]

@onready var _world_environment: WorldEnvironment = $WorldEnvironment
@onready var _origin: XROrigin3D = %XROrigin3D
@onready var _camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var _console: Node3D = $XROrigin3D/XRCamera3D/Console
@onready var _left_controller: XRController3D = $XROrigin3D/LeftController
@onready var _left_hand: XRToolsHand = $XROrigin3D/LeftController/LeftHand
@onready var _right_controller: XRController3D = $XROrigin3D/RightController
@onready var _right_hand: XRToolsHand = $XROrigin3D/RightController/RightHand
@onready var _pointer: XRToolsFunctionPointer = $XROrigin3D/RightController/FunctionPointer
@onready var _hud: Node3D = %Hud
@onready var _system: XRToolsPickable = %System
@onready var _menu: Node3D = %Menu
@onready var _menu_screen: Node3D = %MenuScreen
@onready var _info_panel: Node3D = $InfoPanel
@onready var _info_panel_screen: Node3D = $InfoPanel/Screen

@onready var _environment: Environment = _world_environment.environment
@onready var _initial_sky_energy_multiplier: float = \
		_environment.background_energy_multiplier
@onready var _initial_pointer_distance: float = _pointer.distance
@onready var _hud_gui: HudGui = _hud.scene_node
@onready var _menu_gui: MenuGui = _menu_screen.scene_node
@onready var _info_panel_gui: InfoPanelGui = _info_panel_screen.scene_node

var __movement_speed: float = 0

@onready var _movement_speed: float:
	get:
		return __movement_speed
	set(value):
		__movement_speed = value
		_hud_gui.display_movement_speed(__movement_speed)

@export var simulation_accelaration: float = 1
@export var simulation_speed_accelaration: float = 2

@export var initial_movement_speed: float = 0
@export var movement_acceleration: float = 0

var _xr_interface: XRInterface
var _is_game_paused: bool = false
var _old_simulation_speed_index: int


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


var _is_menu_enabled: bool:
	get:
		return _menu_screen.visible
	set(value):
		if value == true:
			_is_info_panel_enabled = false
			
			_menu.position = Vector3(
				_camera.global_position.x,
				
				clamp(
					_camera.global_position.y,
					_menu_screen.screen_size.y / 2,
					_camera.global_position.y
				),
				
				_camera.global_position.z
			)
			
			_initial_menu_body_following_direction = \
					_position_following - _menu.global_position
			
			_menu.global_rotation = _camera.global_rotation
		
		_menu_screen.visible = value
		_menu_screen.enabled = value
		
		_update_pointer_enabled()



var _is_info_panel_enabled: bool:
	get:
		return _info_panel_screen.visible
	set(value):
		if value == true:
			_is_menu_enabled = false
			
			_info_panel.position = Vector3(
				_camera.global_position.x,
				
				clamp(
					_camera.global_position.y,
					_info_panel_screen.screen_size.y / 2,
					_camera.global_position.y
				),
				
				_camera.global_position.z
			)
			
			_initial_info_panel_body_following_direction = \
					_position_following - _info_panel.global_position
			
			_info_panel.global_rotation = _camera.global_rotation
			
			_info_panel_gui.body = _selected_body
		
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

var _is_movement_speed_button_pressed: bool = false

var _previous_right_direction_x: int = 0
var _previous_left_direction_x: int = 0

var _position_following: Vector3:
	get:
		return Vector3.ZERO \
				if _body_following == null \
				else _body_following.global_position


var __body_following: Body = null


var _body_following: Body:
	get:
		return __body_following
	set(value):
		__body_following = value
		
		_initial_player_body_following_direction = \
					_position_following - _origin.global_position
		
		_initial_menu_body_following_direction = \
					_position_following - _menu.global_position
		
		_initial_info_panel_body_following_direction = \
					_position_following - _info_panel.global_position
		
		if value == null:
			_hud_gui.hide_following_body_name()
		else:
			_hud_gui.display_following_body_name(__body_following.body_name)


var _initial_player_body_following_direction: Vector3 = Vector3.ZERO
var _initial_menu_body_following_direction: Vector3 = Vector3.ZERO
var _initial_info_panel_body_following_direction: Vector3 = Vector3.ZERO

var __simulation_speed_index: int = 0

var _simulation_speed_index: int:
	get:
		return __simulation_speed_index
	set(value):
		__simulation_speed_index = value
		Game.simulation_speed = _SIMULATION_SPEEDS[__simulation_speed_index]


var _paused_simulation_speed_index: int = 0
var _normal_simulation_speed_index: int = 0

var _simulation_scales: Array
var _normal_simulation_scale_index: int = 0

var __simulation_scale_index: int = 0


var _simulation_scale_index: int:
	get:
		return __simulation_scale_index
	set(value):
		__simulation_scale_index = value
		Game.simulation_scale = _simulation_scales[__simulation_scale_index]


var _initial_simulation_scale_index: int = 0

var _locales: Array[String] = [
	"en",
	"pt"
]

var _locale_labels: Dictionary = {
	"en": "English",
	"pt": "Português"
}


func _ready() -> void:
	TranslationServer.set_locale(OS.get_locale_language())
	Game.console = _console.scene_node
	Game.connect("simulation_scale_changed", _on_game_simulation_scale_changed)
	Game.connect("simulation_speed_changed", _on_game_simulation_speed_changed)
	_set_up_simulation_speed()
	_set_up_simulation_scale()
	_set_up_xr()
	_set_up_controls()
	_set_up_system()
	Game.labels_enabled = false
	_is_menu_enabled = false
	_is_info_panel_enabled = false
	_body_following = null


func _physics_process(delta: float) -> void:
	var original_origin_position: Vector3 = _origin.position
	
	Game.player_camera_position = _camera.global_position
	_pointer.distance = _initial_pointer_distance * Game.simulation_scale
	_scale_system()
	_follow_body()
	_move(delta)
	
	var new_origin_position: Vector3 = _origin.position
	
	var origin_displacement: Vector3 = \
			new_origin_position - original_origin_position
	
	_sync_hands(origin_displacement)
	_environment.sky_rotation = _system.global_rotation


func _set_up_simulation_speed() -> void:
	_paused_simulation_speed_index = _SIMULATION_SPEEDS.find(0)
	_normal_simulation_speed_index = _SIMULATION_SPEEDS.find(1)
	_simulation_speed_index = _normal_simulation_speed_index


func _set_up_simulation_scale() -> void:
	_simulation_scales.append_array(range(2, 10, 1))
	_simulation_scales.append_array(range(10, 1000, 10))
	
	_simulation_scales = _simulation_scales\
			.map(func(scale_): return scale_ / 100.0)
	
	_simulation_scales.append_array(range(10, 251, 1))
	
	for i in len(_simulation_scales):
		if is_equal_approx(_simulation_scales[i], 1):
			_normal_simulation_scale_index = i
			break

	_simulation_scale_index = _normal_simulation_scale_index


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
	_menu_gui.set_up_language_option_button(_locale_labels)
	
	_menu_gui.set_up_simulation_scale_slider(
		_simulation_scales,
		_normal_simulation_scale_index,
	)
	
	_menu_gui.set_up_simulation_speed_slider(
		_SIMULATION_SPEEDS,
		_normal_simulation_speed_index,
	)
	
	_menu_screen.connect_scene_signal("close_button_up", _on_menu_close_button_up)
	_menu_screen.connect_scene_signal("restart_button_up", _on_menu_restart_button_up)
	_menu_screen.connect_scene_signal("language_item_selected", _on_menu_language_item_selected)
	_menu_screen.connect_scene_signal("simulation_scale_slider_changed", _on_menu_simulation_scale_slider_changed)
	_menu_screen.connect_scene_signal("simulation_speed_slider_changed", _on_menu_simulation_speed_slider_changed)
	_menu_screen.connect_scene_signal("labels_check_button_toggled", _on_menu_labels_check_button_toggled)
	_menu_screen.connect_scene_signal("passthrough_check_button_toggled", _on_menu_passthrough_check_button_toggled)
	
	_info_panel_screen.connect_scene_signal("close_button_up", _on_info_panel_close_button_up)
	_info_panel_screen.connect_scene_signal("go_to_button_up", _on_info_panel_go_to_button_up)
	_info_panel_screen.connect_scene_signal("follow_button_up", _on_info_panel_follow_button_up)
	_info_panel_screen.connect_scene_signal("go_to_follow_button_up", _on_info_panel_go_to_follow_button_up)


func _set_up_system() -> void:
	_system.position.y = _camera.global_position.y + _SYSTEM_HEIGHT_OFFSET


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
	
	var difference: float = final_distance - initial_distance
	
	var index_difference: int = \
			int(difference * _SIMULATION_SPEED_INDICES_PER_METER)
	
	_menu_gui.set_simulation_scale_slider_value(
		_initial_simulation_scale_index + index_difference
	)


func _follow_body() -> void:
	_origin.global_position = \
			_position_following - _initial_player_body_following_direction
	
	if _is_menu_enabled:
		_menu.global_position = \
				_position_following \
				- _initial_menu_body_following_direction
	
	if _is_info_panel_enabled:
		_info_panel.global_position = \
				_position_following \
				- _initial_info_panel_body_following_direction


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
	
	var final_velocity: Vector3 = \
			direction_y \
			* movement_direction \
			* _movement_speed \
			* delta
	
	_initial_player_body_following_direction -= final_velocity


func _sync_hands(displacement: Vector3) -> void:
	_left_hand.position += displacement
	_right_hand.position += displacement


func _update_pointer_enabled() -> void:
	var is_enabled: bool = \
			_is_pointer_button_pressed \
			or _is_menu_enabled \
			or _is_info_panel_enabled
	
	_pointer.enabled = is_enabled
	_pointer.visible = is_enabled


func _on_left_controller_button_pressed(button_name: String) -> void:
	match button_name:
		"ax_button":
			_is_menu_enabled = not _is_menu_enabled
		"by_button":
			_menu_gui.set_passthrough_check_button(not _passthrough_enabled)
		"primary_click":
			_body_following = null
		"trigger_click":
			_is_movement_speed_button_pressed = true
		"grip_click":
			_is_scale_button_pressed = true
			_left_controller_initial_position = \
					_left_controller.global_position
			_initial_simulation_scale_index = _simulation_scale_index


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
	
	if direction_x == _previous_left_direction_x:
		return
	
	_origin.rotate_y(deg_to_rad(15) * -direction_x)
	_previous_left_direction_x = direction_x


func _on_right_controller_button_pressed(button_name: String) -> void:
	match button_name:
		"primary_click":
			_menu_gui.set_simulation_speed_slider_value(
				_normal_simulation_speed_index
			)
		"by_button":
			_toggle_is_game_paused()
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
	button_name: String,
	value: Vector2
) -> void:
	
	if button_name != "primary":
		return
	
	var direction_x: int = round(abs(value.x)) * sign(value.x)
	
	if direction_x == _previous_right_direction_x:
		return
	
	_menu_gui.set_simulation_speed_slider_value(
		_simulation_speed_index + direction_x
	)
	
	_previous_right_direction_x = direction_x


func _toggle_is_game_paused() -> void:
	_is_game_paused = not _is_game_paused

	if _is_game_paused:
		_old_simulation_speed_index = _simulation_speed_index
		
		_menu_gui.set_simulation_speed_slider_value(
			_paused_simulation_speed_index
		)
	else:
		_menu_gui.set_simulation_speed_slider_value(
			_old_simulation_speed_index
		)


func _on_menu_close_button_up() -> void:
	_is_menu_enabled = false
	_hud_gui.hide_menu_help()


func _on_menu_restart_button_up() -> void:
	get_tree().reload_current_scene()


func _on_menu_language_item_selected(index: int) -> void:
	TranslationServer.set_locale(_locales[index])


func _on_menu_simulation_scale_slider_changed(value: int) -> void:
	_simulation_scale_index = value


func _on_menu_simulation_speed_slider_changed(value: int) -> void:
	_simulation_speed_index = value


func _on_menu_labels_check_button_toggled(toggled_on: bool) -> void:
	Game.labels_enabled = toggled_on


func _on_menu_passthrough_check_button_toggled(toggled_on: bool) -> void:
	_passthrough_enabled = toggled_on


func _on_info_panel_close_button_up() -> void:
	_is_info_panel_enabled = false


func _on_info_panel_go_to_button_up(body: Body) -> void:
	_is_info_panel_enabled = false
	_go_to_body(body)


func _on_info_panel_follow_button_up(body: Body) -> void:
	_is_info_panel_enabled = false
	_body_following = body


func _on_info_panel_go_to_follow_button_up(body: Body) -> void:
	_is_info_panel_enabled = false
	_body_following = body
	_go_to_body(body)
	

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


func _go_to_body(body: Body) -> void:
	var direction: Vector3 = \
			_camera.global_position.direction_to(body.global_position)
	
	var distance: float = max(1, body.longest_axis_size)
	var offset: Vector3 = direction * distance
	
	var final_position: Vector3 = \
			body.global_position - _camera.position - offset
	
	_initial_player_body_following_direction = \
			_position_following - final_position
