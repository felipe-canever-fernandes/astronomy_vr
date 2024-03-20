extends Node3D

@onready var _menu := $XROrigin3D/LeftController/Menu
@onready var _pointer := $XROrigin3D/RightController/FunctionPointer


var _menu_enabled: bool:
	get:
		return _menu.visible
	set(value):
		_menu.visible = value
		_menu.enabled = value
		
		_pointer.visible = value
		_pointer.enabled = value


func _ready() -> void:
	var xr_interface := XRServer.find_interface("OpenXR")
	
	if xr_interface != null and xr_interface.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
	else:
		printerr("OpenXR not initialized.")
	
	
	
	_menu_enabled = false


func _on_left_controller_button_pressed(button_name: String) -> void:
	if button_name == "ax_button":
		_menu_enabled = not _menu_enabled
