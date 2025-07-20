extends Node3D
class_name Door

@export var door_model: Node3D
@export var collider: CollisionShape3D
@export var open_offset := Vector3.ZERO
@export var open_speed := 4.0
@export var initial_open := false
@export var opening_button: SmallButton

var _is_open := false
var _origin: Vector3 = Vector3.ZERO

func _ready():
    _origin = door_model.global_position
    if initial_open:
        open()
        door_model.global_position = _origin + open_offset
    if opening_button != null:
        opening_button.pressed.connect(_on_small_button_pressed)

func open():
    _is_open = true
    collider.disabled = true
    
func close():
    _is_open = false
    collider.disabled = false


func _process(delta: float) -> void:
    var target_pos := (_origin + open_offset) if _is_open else _origin
    door_model.global_position = lerp(door_model.global_position, target_pos,  open_speed * delta)

# Can connect doors to buttons to make them open
func _on_small_button_pressed() -> void:
    open()
