extends Label3D


func _physics_process(_delta: float) -> void:
	var distance_to_player: float = \
			global_position.distance_to(Game.player_camera_position)
			
	scale = distance_to_player * Vector3.ONE
