extends Node3D
class_name Door

@export var door_model: Node3D
@export var collider: CollisionShape3D
@export var open_offset := Vector3.ZERO
@export var open_speed := 4.0
@export var initial_open := false
@export var opening_button: SmallButton
@export var closing_button: SmallButton
@export var toggling_buttons: Array[SmallButton]
@export var closes_after := 5.0
@export var closing_timer: Timer

var _is_open := false
var _origin: Vector3 = Vector3.ZERO

func _ready():
    _origin = door_model.global_position
    if initial_open:
        open()
        door_model.global_position = _origin + open_offset
    if opening_button != null:
        opening_button.pressed.connect(_on_open_button_pressed)
    if closing_button != null:
        closing_button.pressed.connect(_on_close_button_pressed)
    for toggling_button in toggling_buttons:   
        toggling_button.pressed.connect(_on_toggle_button_pressed)
    if closing_timer != null:
        closing_timer.timeout.connect(_on_close_button_pressed)

func open():
    _is_open = true
    collider.disabled = true
    if closing_timer != null:
        closing_timer.start(closes_after)
    
func close():
    _is_open = false
    collider.disabled = false

func _process(delta: float) -> void:
    var target_pos := (_origin + open_offset) if _is_open else _origin
    door_model.global_position = lerp(door_model.global_position, target_pos,  open_speed * delta)

# Can connect doors to buttons to make them open
func _on_open_button_pressed() -> void:
    open()

func _on_close_button_pressed() -> void:
    close()

func _on_toggle_button_pressed() -> void:
    # This was originally going to be a toggle, but now it's just an open too
    open()
