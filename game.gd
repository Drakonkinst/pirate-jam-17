extends Node3D

class_name Game

signal exit_game
signal restart_game

@export var player: Player
@export var grappling_hook_controller: GrapplingHookController
@export var hud: HUD
@export var end_screen: EndScreen
@export var win_button: SmallButton
@export var mission_tracker: MissionTracker
@export var pause_control: PauseControl
@export var speedrun_timer: SpeedrunTimer

@export var end_screen_timer: Timer

var _end_title: String
var _end_subtitle: String
var _end_win: bool
var triggered_end_screen := false

func _ready() -> void:
    win_button.pressed.connect(_on_win_button_pressed)
    end_screen_timer.timeout.connect(_on_end_screen_timer_timeout)

func get_hook_target() -> Node3D:
    return grappling_hook_controller.hook_target
    
func display_end_screen(title: String, subtitle: String, win: bool) -> void:
    if triggered_end_screen:
        return
    _end_title = title
    _end_subtitle = subtitle
    _end_win = win
    triggered_end_screen = true
    pause_control.disable()
    hud.fade_in_out.fade_out()
    end_screen_timer.start(3)

func _on_win_button_pressed() -> void:
    Global.audio.win_button.play()
    var text := "You win! Your time: " + speedrun_timer.get_time_str()
    display_end_screen("Distress Call Transmitted successfully", text, true)
    
func _on_end_screen_timer_timeout() -> void:
    pause_control.pause()
    end_screen.display(_end_title, _end_subtitle)
    
func do_exit_game() -> void:
    exit_game.emit()

func do_restart_game() -> void:
    restart_game.emit()
    
