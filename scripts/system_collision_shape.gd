extends CollisionShape3D


func _ready() -> void:
	Game.connect("simulation_scale_changed", _on_game_simulation_scale_changed)


func _on_game_simulation_scale_changed(new_scale: float) -> void:
	if new_scale < 1:
		new_scale = 1

	scale = new_scale * Vector3.ONE
