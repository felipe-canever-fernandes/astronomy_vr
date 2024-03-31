extends XRCamera3D

var _initial_far: float = 0

func _ready() -> void:
	_initial_far = far
	Game.connect("simulation_scale_changed", _on_game_simulation_scale_changed)


func _on_game_simulation_scale_changed(new_scale: float) -> void:
	if new_scale < 1:
		new_scale = 1

	far = _initial_far * new_scale
