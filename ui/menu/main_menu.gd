extends Node3D

class_name MainMenu

signal start_game

@export var camera_pan_speed := 50.0

@onready var start_menu: StartMenu = %StartMenu
@onready var settings_menu: OptionsScreen = %OptionsScreen
@onready var credits_menu: CreditsMenu = %CreditsScreen
@onready var camera: Camera3D = %Camera3D

func _ready() -> void:
    get_tree().paused = false
    start_menu.show()
    settings_menu.hide()
    credits_menu.hide()
    start_menu.open_settings.connect(_on_start_menu_open_settings)
    start_menu.open_credits.connect(_on_start_menu_open_credits)
    start_menu.start_game.connect(_on_start_menu_start_game)
    settings_menu.on_return_pressed.connect(_on_settings_menu_pressed_back)
    credits_menu.on_return_pressed.connect(_on_credits_menu_pressed_back)
    
func _process(delta: float) -> void:
    if camera.global_position.z >= -4000:
        camera.global_position.z -= camera_pan_speed * delta

func _on_start_menu_open_settings() -> void:
    Global.audio.click.play_random("MM1")
    start_menu.hide()
    settings_menu.show()

func _on_start_menu_open_credits() -> void:
    Global.audio.click.play_random("MM2")
    start_menu.hide()
    credits_menu.show()

func _on_start_menu_start_game() -> void:
    Global.audio.click_play.play()
    start_game.emit()

func _on_settings_menu_pressed_back() -> void:
    Global.audio.click.play_random("MM4")
    start_menu.show()
    settings_menu.hide()

func _on_credits_menu_pressed_back() -> void:
    Global.audio.click.play_random("MM5")
    start_menu.show()
    credits_menu.hide()
