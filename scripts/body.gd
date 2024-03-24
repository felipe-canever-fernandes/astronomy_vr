extends Node3D
class_name Body

const _MAXIMUM_DESCRIPTION_PANEL_ROTATION_OFFSET := PI / 2
const _GUI_OFFSET := 0.05
const _AREA_OFFSET := 1

@onready var _name_label: Label3D = $NameLabel
@onready var _description_panel: Node3D = $DescriptionPanel
@onready var _description_panel_panel: Node3D = $DescriptionPanel/Panel
@onready var _description_panel_gui: BodyInfoGUI = _description_panel_panel.scene_node
@onready var _area_collision_shape: CollisionShape3D = $Area/CollisionShape


## The name of this body that will be displayed on its label.
@export var body_name: String
## A description that will be shown on the description panel.
@export_multiline var description: String
## The body around which this body orbits.
@export var parent: Node3D
## The time it takes for this body to orbit around its parent, in seconds.
@export var orbital_period: float = 30

var _mesh: MeshInstance3D

var _size: Vector3:
	get:
		return _mesh.get_aabb().size


var _orbital_distance: float = 0
var _orbital_angle: float = 0


var _angular_speed: float:
	get:
		return 2 * PI / orbital_period


func _ready() -> void:
	_find_mesh()
	_create_area_shape()
	_set_up_gui()
	_set_up_orbit()


func _process(delta: float) -> void:
	_set_description_panel_rotation()
	_orbit(delta)


func _find_mesh():
	for node in get_children():
		if node is MeshInstance3D:
			print("Found!")
			_mesh = node
			break


func _create_area_shape() -> void:
	var shape := SphereShape3D.new()
	shape.radius = _size.x / 2 + _AREA_OFFSET

	_area_collision_shape.shape = shape


func _set_up_gui() -> void:
	_name_label.text = body_name
	_name_label.position.y = _size.y / 2 + _GUI_OFFSET
	
	_description_panel.visible = false
	_description_panel_gui.text = description

	_description_panel_panel.position.x = \
			_size.x / 2 + _description_panel_panel.screen_size.x / 2 + _GUI_OFFSET
	
	
func _set_up_orbit() -> void:
	if parent == null:
		return

	_orbital_distance = parent.global_position.distance_to(global_position)
	_orbital_angle = acos(global_position.x / _orbital_distance)


func _set_description_panel_rotation() -> void:
	var player_horizontal_position := Vector3(
		Game.player_camera_position.x,
		_description_panel.global_position.y,
		Game.player_camera_position.z
	)

	_description_panel.look_at(player_horizontal_position)

	var offset := _MAXIMUM_DESCRIPTION_PANEL_ROTATION_OFFSET

	_description_panel.global_rotation.y += \
			-1 / exp(_size.x / 2 - log(offset)) + offset


func _orbit(delta: float) -> void:
	if parent == null:
		return
	
	_orbital_angle += _angular_speed * delta * Game.simulation_speed_factor
	
	if _orbital_angle >= 2 * PI:
		_orbital_angle = 0

	global_position.x = \
			parent.global_position.x + _orbital_distance * cos(_orbital_angle)

	global_position.z = \
			parent.global_position.z + _orbital_distance * sin(_orbital_angle)


func _on_area_body_entered(_body: Node3D) -> void:
	_description_panel.visible = true


func _on_area_body_exited(_body: Node3D) -> void:
	_description_panel.visible = false
