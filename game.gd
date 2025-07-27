extends Node3D

class_name Game

signal game_over
signal game_won

@export var player: Player
@export var grappling_hook_controller: GrapplingHookController
@export var hud: HUD
@export var win_button: SmallButton
@export var mission_tracker: MissionTracker
@export var pause_control: PauseControl
@export var audio: AudioManager

func _ready() -> void:
    win_button.pressed.connect(_on_win_button_pressed)

func get_hook_target() -> Node3D:
    return grappling_hook_controller.hook_target
    
func set_game_over() -> void:
    game_over.emit()

func _on_win_button_pressed() -> void:
    game_won.emit()
