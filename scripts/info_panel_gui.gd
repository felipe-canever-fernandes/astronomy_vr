class_name InfoPanelGui
extends MarginContainer

var _type_names: Dictionary = {
	Body.Type.STAR: "INFO_PANEL_BODY_TYPE_STAR",
	Body.Type.PLANET: "INFO_PANEL_BODY_TYPE_PLANET",
	Body.Type.DWARF_PLANET: "INFO_PANEL_BODY_TYPE_DWARF_PLANET",
	Body.Type.NATURAL_SATELLITE: "INFO_PANEL_BODY_TYPE_NATURAL_SATELLITE"
}

signal close_button_up
signal go_to_button_up(body: Body)
signal follow_button_up(body: Body)
signal go_to_follow_button_up(body: Body)

@onready var _picture_texture_rect: TextureRect = %PictureTextureRect
@onready var _name_label: Label = %NameLabel
@onready var _type_label: Label = %TypeLabel

@onready var _average_orbital_distance_value_label: Label = \
		%AverageOrbitalDistanceValueLabel

@onready var _orbital_period_value_label: Label = %OrbitalPeriodValueLabel
@onready var _rotation_period_value_label: Label = %RotationPeriodValueLabel
@onready var _radius_value_label: Label = %RadiusValueLabel
@onready var _mass_value_label: Label = %MassValueLabel
@onready var _surface_gravity_value_label: Label = %SurfaceGravityValueLabel

@onready var _average_surface_temperature_value_label: Label = \
		%AverageSurfaceTemperatureValueLabel

@onready var _description_text_label: RichTextLabel = %DescriptionTextLabel

var _body: Body


var body: Body:
	get:
		return _body
	set(value):
		
		_body = value
		
		if _body != null:
			_picture_texture_rect.texture = _body.picture
			_name_label.text = _body.body_name
			_type_label.text = _type_names[_body.type]
			
			_average_orbital_distance_value_label.text = \
					tr("INFO_PANEL_AVERAGE_ORBITAL_DISTANCE_VALUE").format({
						"average_orbital_distance":
								_format_number(_body.average_orbital_distance)
					})
					
			_orbital_period_value_label.text = \
					tr("INFO_PANEL_ORBITAL_PERIOD_VALUE").format({
						"orbital_period":
								_format_number(_body.orbital_period)
					})
					
			_rotation_period_value_label.text = \
					tr("INFO_PANEL_ROTATION_PERIOD_VALUE").format({
						"rotation_period":
								_format_number(_body.rotation_period)
					})
					
			_radius_value_label.text = \
					tr("INFO_PANEL_RADIUS_VALUE").format({
						"radius":
								_format_number(_body.radius)
					})
			
			_mass_value_label.text = \
					tr("INFO_PANEL_MASS_VALUE").format({
						"mass":
								_format_number(_body.mass)
					})
			
			_surface_gravity_value_label.text = \
					tr("INFO_PANEL_SURFACE_GRAVITY_VALUE").format({
						"surface_gravity":
								_format_number(_body.surface_gravity)
					})
					
			_average_surface_temperature_value_label.text = \
					tr("INFO_PANEL_AVERAGE_SURFACE_TEMPERATURE_VALUE").format({
						"average_surface_temperature":
								_format_number(_body.average_surface_temperature)
					})
					
			_description_text_label.text = _body.description
		else:
			_name_label.text = ""
			_description_text_label.text = ""


func _ready() -> void:
	body = null


func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_TRANSLATION_CHANGED:
		body = body

func _on_close_button_button_up() -> void:
	close_button_up.emit()


func _on_go_to_button_button_up() -> void:
	go_to_button_up.emit(body)


func _on_go_to_follow_button_button_up() -> void:
	go_to_follow_button_up.emit(body)


func _on_follow_button_button_up() -> void:
	follow_button_up.emit(body)


func _format_number(number: float) -> String:
	var absolute_number: float = abs(number)
	var sign_symbol: String = "-" if number < 0 else ""
	
	var representation: String = str(absolute_number)
	
	if absolute_number < 10000:
		return sign_symbol + representation
	
	var dot_index: int = representation.find(".")
	var dot_symbol: String = "."
	
	if dot_index < 0:
		dot_index = len(representation)
		dot_symbol = ""
	
	var before_dot: String = representation.substr(0, dot_index)
	var after_dot: String = representation.substr(dot_index + 1)
	
	var formatted_before_dot: String = ""
	var count: int = 0
	
	for i in range(len(before_dot) - 1, -1, -1):
		count += 1
		
		formatted_before_dot = before_dot[i] + formatted_before_dot
		
		if i > 0 and count % 3 == 0:
			formatted_before_dot = " " + formatted_before_dot
	
	return sign_symbol + formatted_before_dot + dot_symbol + after_dot

