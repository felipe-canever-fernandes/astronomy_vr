extends OmniLight3D

@onready var _initial_range: float = omni_range
@onready var _initial_energy: float = light_energy
@onready var _initial_size: float = light_size

func _physics_process(_delta: float) -> void:
	omni_range = _initial_range * Game.simulation_scale
	light_energy = _initial_energy * Game.simulation_scale
	light_size = _initial_size * Game.simulation_scale
