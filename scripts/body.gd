extends Node3D
class_name Body

const _SELECTION_THICKNESS: float = 0.003

@export var body_name: String
@export_multiline var description: String
## The body around which this body orbits.
@export var parent: Node3D
## The time it takes for this body to orbit around its parent, in seconds.
@export var orbital_period: float
## The time it takes for this body to rotate around its own axis.
@export var rotation_period: float

var _mesh: MeshInstance3D
var _selection: BodySelection
var _area: BodyArea
var _initial_orbital_distance: float


var _orbital_distance: float:
	get:
		return _initial_orbital_distance * Game.simulation_scale


var _orbital_angle: float = 0


var _orbital_angular_speed: float:
	get:
		return 2 * PI / orbital_period


var _rotation_angular_speed: float:
	get:
		return 2 * PI / rotation_period


var selected: bool:
	get:
		return _selection.visible
	set(value):
		_selection.visible = value


func _ready() -> void:
	_set_initial_orbital_distance()
	_find_nodes()
	_set_up_selection()
	_set_up_orbit()


func _process(delta: float) -> void:
	_scale_nodes()
	_rotate(delta)
	_orbit(delta)


func _set_up_selection() -> void:
	_selection.mesh.flip_faces = true
	_selection.mesh.material = _create_selection_material()
	
	selected = false


func _create_selection_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.grow = true
	
	return material


func _set_initial_orbital_distance() -> void:
	if parent != null:
		_initial_orbital_distance = \
				parent.global_position.distance_to(global_position)


func _find_nodes():
	for node in get_children():
		if node is BodySelection:
			_selection = node
		elif node is MeshInstance3D:
			_mesh = node
		elif node is BodyArea:
			_area = node
	
	
func _set_up_orbit() -> void:
	if parent == null:
		return

	_orbital_angle = acos(global_position.x / _orbital_distance)


func _scale_nodes() -> void:
	var new_scale: Vector3 = Game.simulation_scale * Vector3.ONE
	
	_mesh.scale = new_scale
	_selection.scale = new_scale
	_area.scale = new_scale
	
	var distance_to_player = \
			global_position.distance_to(Game.player_camera_position)
			
	var selection_tickness: float = \
			_SELECTION_THICKNESS * distance_to_player / Game.simulation_scale
	
	_selection.mesh.material.grow_amount = -selection_tickness
	


func _rotate(delta: float) -> void:
	var delta_rotation: float = \
			_rotation_angular_speed * delta * Game.simulation_speed

	_mesh.rotate(Vector3.UP, delta_rotation)
	_selection.rotate(Vector3.UP, delta_rotation)
	_area.rotate(Vector3.UP, delta_rotation)


func _orbit(delta: float) -> void:
	if parent == null:
		return
			
	_orbital_angle += _orbital_angular_speed * delta * Game.simulation_speed
	
	if _orbital_angle >= 2 * PI:
		_orbital_angle = 0

	global_position.x = \
			parent.global_position.x + _orbital_distance * cos(_orbital_angle)

	global_position.z = \
			parent.global_position.z + _orbital_distance * sin(_orbital_angle)
