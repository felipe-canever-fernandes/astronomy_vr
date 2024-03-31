extends CollisionShape3D


func _ready() -> void:
	Game.connect("simulation_scale_changed", _on_game_simulation_scale_changed)


func _on_game_simulation_scale_changed(new_scale: float) -> void:
	scale = new_scale * Vector3.ONE
