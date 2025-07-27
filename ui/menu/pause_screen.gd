extends Control

@export var main_pause_menu: Control
@export var options_menu: Control

@onready var music_slider: HSlider = %MusicSlider
@onready var environment_slider: HSlider = %EnvironmentSlider
@onready var interface_slider: HSlider = %InterfaceSlider

func _ready() -> void:
    hide()
    Global.game.pause_control.unpaused.connect(_on_pause_control_unpaused)
    Global.game.pause_control.paused.connect(_on_pause_control_paused)

func _on_pause_control_unpaused() -> void:
    hide()

func _on_pause_control_paused() -> void:
    show()
    options_menu.hide()
    main_pause_menu.show()

func _on_options_screen_on_return_pressed() -> void:
    options_menu.hide()
    main_pause_menu.show()

func _on_resume_button_pressed() -> void:
    Global.game.pause_control.unpause()
