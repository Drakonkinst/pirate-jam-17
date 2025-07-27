extends Control

class_name StartMenu

signal start_game
signal open_settings
signal open_credits

@onready var lone_text: ScrollingText = %Lone
@onready var transmission_text: ScrollingText = %Transmission

@onready var play_button: Button = %PlayButton
@onready var credits_button: Button = %CreditsButton
@onready var settings_button: Button = %SettingsButton

func _ready() -> void:
    lone_text.display_text("LONE")
    transmission_text.display_text("TRANSMISSION")
    play_button.pressed.connect(_on_play_button_pressed)
    credits_button.pressed.connect(_on_credits_button_pressed)
    settings_button.pressed.connect(_on_settings_button_pressed)
    
func _on_play_button_pressed() -> void:
    start_game.emit()

func _on_credits_button_pressed() -> void:
    open_credits.emit()

func _on_settings_button_pressed() -> void:
    open_settings.emit()