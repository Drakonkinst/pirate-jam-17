extends Node3D

class_name InputState

var is_pressing_primary: bool
var is_pressing_secondary: bool
var movement_input: Vector3
var roll_input: float
var mouse_motion: Vector2
var go_upright: bool

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if not Global.game.pause_control.is_paused():
            mouse_motion += event.relative * 0.001
    if event.is_action_pressed("action_primary") || event.is_action_pressed("action_secondary"):
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    

func _process(_delta: float) -> void:
    var horizontal_movement := Input.get_axis("move_left", "move_right")
    var forwards_movement := Input.get_axis("move_backward", "move_forward")
#    var vertical_movement := Input.get_axis("move_down", "move_up")
    var vertical_movement := 0 # Disabling this since it's not used anymore
    movement_input = Vector3(horizontal_movement, vertical_movement, forwards_movement)
    movement_input = movement_input.normalized()

    is_pressing_primary = Input.is_action_pressed("action_primary")
    is_pressing_secondary = Input.is_action_pressed("action_secondary")
    go_upright = Input.is_action_pressed("go_upright")
    roll_input = Input.get_axis("roll_left", "roll_right")
    
func reset() -> void:
    mouse_motion = Vector2.ZERO
