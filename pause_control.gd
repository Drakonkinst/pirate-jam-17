extends Node3D

class_name PauseControl

const PAUSE_INPUT := "pause"

signal paused
signal unpaused

var disabled := false

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed(PAUSE_INPUT) and not disabled:
        _toggle_pause()

func is_paused() -> bool:
    return get_tree().paused
    
func _toggle_pause() -> void:
    var is_game_paused: bool = get_tree().paused
    get_tree().paused = not is_game_paused
    if is_game_paused:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        unpaused.emit()
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        paused.emit()

func disable() -> void:
    disabled = true

func enable() -> void:
    disabled = false

func pause() -> void:
    if get_tree().paused:
        return
    _toggle_pause()

func unpause() -> void:
    if not get_tree().paused:
        return
    _toggle_pause()
