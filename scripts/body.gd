@tool
extends MeshInstance3D
class_name Body

## The name of this body that will be displayed on its label.
@export var body_name: String
## The body around which this body orbits.
@export var parent: Node3D
## The time it takes for this body to orbit around its parent, in seconds.
@export var orbital_period: float = 30

@onready var _label := $Label

var _distance: float = 0
var _angle: float = 0

var _angular_speed: float:
	get:
		return 2 * PI / orbital_period


func _ready() -> void:
	_set_up_label()
	_set_up_orbiting()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if parent == null:
		return
	
	_angle += _angular_speed * delta * Game.simulation_speed_factor
	
	if _angle >= 2 * PI:
		_angle = 0

	global_position.x = parent.global_position.x + _distance * cos(_angle)
	global_position.z = parent.global_position.z + _distance * sin(_angle)


func _set_up_label() -> void:
	_label.text = body_name
	
	var y_diameter := get_aabb().size.y
	_label.position.y = y_diameter / 2 + 0.05
	
	
func _set_up_orbiting() -> void:
	if parent == null:
		return

	_distance = parent.global_position.distance_to(global_position)
	_angle = acos(global_position.x / _distance)
