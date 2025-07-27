extends Control

class_name OptionsScreen

signal on_return_pressed

func _ready() -> void:
    pass
    
func _on_return_button_pressed() -> void:
    on_return_pressed.emit()
