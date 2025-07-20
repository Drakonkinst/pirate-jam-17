extends Node3D

class_name InputState

signal mouse_looked(look_dir: Vector2)

var is_pressing_primary: bool
var is_pressing_secondary: bool
var movement_input: Vector3
var roll_input: float
var mouse_captured: bool

func _ready() -> void:
    capture_mouse()

# Don't know if we need this part yet
func _input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("pause"): 
        if mouse_captured:
            release_mouse() 
        else:
            capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if mouse_captured:
            var look_dir: Vector2 = event.relative * 0.001
            mouse_looked.emit(look_dir)

func _process(_delta: float) -> void:
    var horizontal_movement := Input.get_axis("move_left", "move_right")
    var forwards_movement := Input.get_axis("move_backward", "move_forward")
#    var vertical_movement := Input.get_axis("move_down", "move_up")
    var vertical_movement := 0 # Disabling this since it's not used anymore
    movement_input = Vector3(horizontal_movement, vertical_movement, forwards_movement)
    movement_input = movement_input.normalized()

    is_pressing_primary = Input.is_action_pressed("action_primary")
    is_pressing_secondary = Input.is_action_pressed("action_secondary")
    roll_input = Input.get_axis("roll_left", "roll_right")

func capture_mouse() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    mouse_captured = true

func release_mouse() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    mouse_captured = false
