class_name FadingLabel
extends Label

@onready var _timer: Timer = %Timer

## The time it takes for the label to fade out.
@export var fade_time: float = 2


func _ready() -> void:
	_timer.wait_time = fade_time
	visible = false


func display(new_text: String) -> void:
		text = new_text
		
		visible = true
		_timer.start()


func _on_timer_timeout() -> void:
	visible = false
