extends StaticBody3D
class_name SmallButton

signal pressed
enum State { ENABLED, PRESSED, DISABLED }
@export var presser: MeshInstance3D
@export var stay_pressed := false
@export var pressed_offset := Vector3(0, -0.1, 0)
@export var initial_state: State
@export var press_speed := 4.0
@export var enable_timer: Timer
@export var enabled_material: Material
@export var disabled_material: Material
@export var pressed_material: Material

var _state: State = State.ENABLED
var _origin: Vector3 = Vector3.ZERO

func _ready() -> void:
    _set_state(initial_state)
    _origin = presser.position
    enable_timer.timeout.connect(_on_enable_timer_timeout)

func press() -> void:
    if _state == State.DISABLED:
        return
    if _state == State.ENABLED:
        pressed.emit()
        _set_state(State.PRESSED)


func _set_state(state: State) -> void:
    _state = state
    if _state == State.PRESSED:
        presser.set_surface_override_material(0, pressed_material)
    elif _state == State.ENABLED:
        presser.set_surface_override_material(0, enabled_material)
    elif _state == State.DISABLED:
        presser.set_surface_override_material(0, disabled_material)


func _process(delta: float) -> void:
    var target_pos := _origin + pressed_offset if _state != State.ENABLED else _origin
    presser.position = lerp(presser.position, target_pos, press_speed * delta)

    if _state == State.PRESSED and Global.game.get_hook_target() != self and not stay_pressed and enable_timer.time_left <= 0:
        enable_timer.start()

func _on_enable_timer_timeout() -> void:
    _set_state(State.ENABLED)
