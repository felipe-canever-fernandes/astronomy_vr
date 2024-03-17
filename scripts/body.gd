@tool
extends Node3D
class_name Body

@onready var _mesh := $Mesh
@onready var _mesh_instance := _mesh.mesh as SphereMesh

@export var radius: float:
	get:
		return _mesh_instance.radius
	set(value):
		_mesh_instance.radius = value
		_mesh_instance.height = value * 2

@export var material: Material:
	get:
		return _mesh_instance.material
	set(value):
		_mesh_instance.material = value

## The body around which this body orbits.
@export var parent: Body
## The time it takes for this body to orbit around its parent, in seconds.
@export var orbital_period: float = 0.1

var _distance: float = 0
var _angle: float = 0

var _angular_speed: float:
	get:
		return 2 * PI / orbital_period


func _ready() -> void:
	if parent == null:
		return

	_distance = parent.global_position.distance_to(global_position)
	_angle = acos(global_position.x / _distance)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if parent == null:
		return
	
	_angle += _angular_speed * delta
	
	if _angle >= 2 * PI:
		_angle = 0

	global_position.x = parent.global_position.x + _distance * cos(_angle)
	global_position.z = parent.global_position.y + _distance * sin(_angle)
