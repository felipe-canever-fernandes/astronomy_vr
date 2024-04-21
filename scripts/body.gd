extends Node3D
class_name Body

enum Type {
	STAR,
	PLANET,
	DWARF_PLANET,
	MOON
}

const _PIVOT_NAME_SUFFIX: String = "Orbit"
const _SELECTION_THICKNESS: float = 0.003

@export_group("Info")
@export var picture: Texture2D
@export var body_name: String
@export var type: Type
@export_multiline var description: String
@export var average_orbital_distance: float
@export var info_orbital_period: float
@export var info_rotation_period: float
@export var radius: float
@export var mass: float
@export var surface_gravity: float
@export var average_surface_temperature: float

@export_group("Simulation")
## The body around which this body orbits.
@export var parent: Node3D = null
## The time it takes for this body to orbit around its parent, in seconds.
@export var orbital_distance: float = 0
@export var orbital_period: float
@export var initial_orbital_angle: float = 0
## The time it takes for this body to rotate around its own axis.
@export var rotation_period: float

var _meshes: Array
var _meshes_initial_scales: Array

var _selections: Array
var _selections_initial_scales: Array

var _area: BodyArea


var _orbital_angular_speed: float:
	get:
		return 2 * PI / orbital_period


var _rotation_angular_speed: float:
	get:
		return 2 * PI / rotation_period


var selected: bool:
	get:
		return _selections[0].visible
	set(value):
		for selection in _selections:
			selection.visible = value


var longest_axis_size: float:
	get:
		var longest_size: float = 0
		
		for mesh in _meshes:
			var size: float = mesh.get_aabb().get_longest_axis_size()
			
			if size > longest_size:
				longest_size = size
		
		return longest_size * Game.simulation_scale


var _pivot: Node3D = null


func _ready() -> void:
	Game.connect("simulation_scale_changed", _on_simulation_scale_changed)
	
	_set_position()
	_find_nodes()
	_set_up_selection()
	_set_up_orbit()


func _physics_process(delta: float) -> void:
	await get_tree().create_timer(0.1).timeout
	_scale_nodes()
	_rotate(delta)
	_orbit(delta)


func _set_up_selection() -> void:
	for selection in _selections:
		selection.mesh.flip_faces = true
		selection.mesh.material = _create_selection_material()
	
	selected = false


func _create_selection_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.grow = true
	
	return material


func _set_position() -> void:
	_on_simulation_scale_changed(Game.simulation_scale)


func _find_nodes():
	for node in get_children():
		if node is BodySelection:
			_selections.append(node)
			_selections_initial_scales.append(node.scale)
		elif node is MeshInstance3D:
			_meshes.append(node)
			_meshes_initial_scales.append(node.scale)
		elif node is BodyArea:
			_area = node
	
	
func _set_up_orbit() -> void:
	if parent == null:
		return

	_pivot = Node3D.new()
	_pivot.name = name + _PIVOT_NAME_SUFFIX
	
	var system: Node3D = get_parent()
	system.add_child.call_deferred(_pivot)
	
	_pivot.position = parent.position
	
	position = parent.position + orbital_distance * Vector3.BACK
	reparent.call_deferred(_pivot)
	
	_pivot.rotate.call_deferred(Vector3.UP, initial_orbital_angle)
	


func _scale_nodes() -> void:
	var new_scale: Vector3 = Game.simulation_scale * Vector3.ONE
	
	for i in len(_meshes):
		_meshes[i].scale = _meshes_initial_scales[i] * new_scale

	for i in len(_selections):
		_selections[i].scale = _selections_initial_scales[i] * new_scale

	_area.scale = new_scale
	
	var distance_to_player = \
			global_position.distance_to(Game.player_camera_position)
			
	var selection_tickness: float = \
			_SELECTION_THICKNESS * distance_to_player / Game.simulation_scale
	
	for selection in _selections:
		selection.mesh.material.grow_amount = -selection_tickness
	


func _rotate(delta: float) -> void:
	var delta_rotation: float = \
			_rotation_angular_speed * delta * Game.simulation_speed

	for mesh in _meshes:
		mesh.rotate(mesh.basis.y.normalized(), delta_rotation)
	
	for selection in _selections:
		selection.rotate(selection.basis.y.normalized(), delta_rotation)

	_area.rotate(_area.basis.y, delta_rotation)


func _orbit(delta: float) -> void:
	if parent == null:
		return
		
	_pivot.global_position = parent.global_position
	
	var final_angle_speed: float = \
			_orbital_angular_speed * delta * Game.simulation_speed
	
	_pivot.rotate(Vector3.UP, final_angle_speed)
	rotate(Vector3.UP, -final_angle_speed)


func _on_simulation_scale_changed(new_scale: float) -> void:
	position = orbital_distance * Vector3.BACK * new_scale
