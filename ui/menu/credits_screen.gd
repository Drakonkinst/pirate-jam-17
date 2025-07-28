extends Control

class_name CreditsMenu

signal on_return_pressed

func _on_return_button_pressed() -> void:
    on_return_pressed.emit()
