extends ColorRect

class_name FadeInOut

@export var fade_in_speed := 0.025
@export var fade_out_speed := 0.025

var _target_color: Color

func _ready() -> void:
    _target_color = color
    
func _process(_delta: float) -> void:
    set_color(lerp(color, _target_color, fade_in_speed))
    
func fade_in() -> void:
    _target_color = Color(0, 0, 0, 0)
    
func fade_out() -> void:
    _target_color = Color(0, 0, 0, 1)