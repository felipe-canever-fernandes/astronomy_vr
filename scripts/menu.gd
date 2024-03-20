extends MeshInstance3D


func _ready() -> void:
	visible = false


func _on_left_controller_button_released(button_name: String) -> void:
	if button_name == "ax_button":
		visible = !visible
