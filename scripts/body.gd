@tool
extends MeshInstance3D
class_name Body

## The name of this body that will be displayed on its label.
@export var body_name: String
## Information about this body.
@export_multiline var info: String
## The body around which this body orbits.
@export var parent: Node3D
## The time it takes for this body to orbit around its parent, in seconds.
@export var orbital_period: float = 30

@onready var _label := $Label
@onready var _info := $Info
@onready var _info_panel := $Info/Node3D

var radius: float:
	get:
		return get_aabb().size.x / 2

var _distance: float = 0
var _angle: float = 0

var _angular_speed: float:
	get:
		return 2 * PI / orbital_period


func _ready() -> void:
	_set_up_gui()
	_set_up_orbiting()


func _process(delta: float) -> void:
	_set_info_rotation()
	_orbit(delta)


func _set_info_rotation() -> void:
	if Engine.is_editor_hint():
		return

	var player_horizontal_position := Vector3(
		Game.player_camera_position.x,
		_info.global_position.y,
		Game.player_camera_position.z
	)

	_info.look_at(player_horizontal_position)
	_info.global_rotation.y += -1 / (exp(radius) - log(PI / 2)) + PI / 2


func _orbit(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if parent == null:
		return
	
	_angle += _angular_speed * delta * Game.simulation_speed_factor
	
	if _angle >= 2 * PI:
		_angle = 0

	global_position.x = parent.global_position.x + _distance * cos(_angle)
	global_position.z = parent.global_position.z + _distance * sin(_angle)


func _set_up_gui() -> void:
	_label.text = body_name
	_label.position.y = radius + 0.05

	var info_gui: BodyInfoGUI = _info_panel.scene_node
	info_gui.text = info
	_info_panel.position.x = radius + _info_panel.screen_size.x / 2 + 0.05
	
	
func _set_up_orbiting() -> void:
	if parent == null:
		return

	_distance = parent.global_position.distance_to(global_position)
	_angle = acos(global_position.x / _distance)
