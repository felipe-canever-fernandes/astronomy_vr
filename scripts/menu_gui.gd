class_name MenuGui
extends PanelContainer

signal close_button_up
signal restart_button_up
signal language_item_selected(index: int)
signal simulation_scale_slider_changed(value: int)
signal simulation_speed_slider_changed(value: int)
signal labels_check_button_toggled(toggled_on: bool)
signal passthrough_check_button_toggled(toggled_on: bool)

@onready var _tab_container: TabContainer = %TabContainer
@onready var _language_option_button: OptionButton = %LanguageOptionButton
@onready var _simulation_scale_slider: HSlider = %SimulationScaleSlider
@onready var _simulation_scale_value_label: Label = %SimulationScaleValueLabel
@onready var _simulation_speed_slider: HSlider = %SimulationSpeedSlider
@onready var _simulation_speed_value_label: Label = %SimulationSpeedValueLabel
@onready var _passthrough_check_button: CheckButton = %PassthroughCheckButton

var _simulation_scales: Array
var _simulation_speeds: Array[float]


func _ready() -> void:
	_tab_container.set_tab_title(0, "MENU_OPTIONS_TAB")
	_tab_container.set_tab_title(1, "MENU_HELP_TAB")
	
	var language_option_button_popup: PopupMenu = \
			_language_option_button.get_popup()
	
	language_option_button_popup.transparent_bg = true


func set_up_language_option_button(locale_labels: Dictionary) -> void:
	_language_option_button.clear()
	
	var current_locale: String = TranslationServer.get_locale()
	var current_locale_index: int = -1
	
	for locale in locale_labels:
		_language_option_button.add_item(locale_labels[locale])
		
		if locale == current_locale:
			current_locale_index = _language_option_button.item_count - 1
	
	if current_locale_index >= 0:
		_language_option_button.select(current_locale_index)
	


func set_up_simulation_scale_slider(
	values: Array,
	initial_index: int
) -> void:
	_simulation_scales = values
	_simulation_scale_slider.max_value = len(values) - 1
	_simulation_scale_slider.value = initial_index


func set_up_simulation_speed_slider(
	values: Array[float],
	initial_index: int
) -> void:
	_simulation_speeds = values
	_simulation_speed_slider.max_value = len(values) - 1
	_simulation_speed_slider.value = initial_index


func _on_restart_button_button_up() -> void:
	restart_button_up.emit()



func _on_language_option_button_item_selected(index: int) -> void:
	language_item_selected.emit(index)
	_language_option_button.release_focus()


func set_simulation_scale_slider_value(value: int) -> void:
	_simulation_scale_slider.value = value


func set_simulation_speed_slider_value(value: int) -> void:
	_simulation_speed_slider.value = value


func set_passthrough_check_button(toggled_on: bool) -> void:
	_passthrough_check_button.button_pressed = toggled_on


func _on_simulation_scale_slider_value_changed(value: float) -> void:
	var simulation_scale: float = _simulation_scales[value]
	
	_simulation_scale_value_label.text = "{scale}x".format({
		"scale": simulation_scale
	})
	
	simulation_scale_slider_changed.emit(value)


func _on_simulation_speed_slider_value_changed(value: float) -> void:
	var simulation_speed: float = _simulation_speeds[value]
	
	_simulation_speed_value_label.text = "{speed}x".format({
		"speed": simulation_speed
	})
	
	simulation_speed_slider_changed.emit(value)


func _on_labels_check_button_toggled(toggled_on: bool) -> void:
	labels_check_button_toggled.emit(toggled_on)


func _on_passthrough_check_button_toggled(toggled_on: bool) -> void:
	passthrough_check_button_toggled.emit(toggled_on)


func _on_close_button_button_up() -> void:
	close_button_up.emit()
