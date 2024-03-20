extends Node3D

func _ready() -> void:
	var xr_interface := XRServer.find_interface("OpenXR")
	
	if xr_interface != null and xr_interface.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	else:
		printerr("OpenXR not initialized.")


func _on_menu_gui_quit_button_up() -> void:
	get_tree().quit()
