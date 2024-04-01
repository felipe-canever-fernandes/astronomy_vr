extends MeshInstance3D

@onready var _mesh: PlaneMesh = mesh
@onready var _initial_mesh_size: Vector2 = _mesh.size


func _ready() -> void:
	Game.connect("simulation_scale_changed", _on_game_simulation_scale_changed)


func _on_game_simulation_scale_changed(new_scale: float) -> void:
	if new_scale < 1:
		new_scale = 1

	_mesh.size = _initial_mesh_size * new_scale * Vector2.ONE
