extends Node3D


func _physics_process(_delta: float) -> void:
	look_at(Game.player_camera_position)
