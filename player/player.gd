extends RigidBody3D

class_name Player

enum MovementMode { THRUST, ROLL }
@export var movement_speed := 100
@export var look_sensitivity := 50.0
@export var roll_speed := 250
@onready var hook_origin: Marker3D = %HookOrigin
@onready var hook_raycast: RayCast3D = %HookRaycast
@onready var input_state: InputState = %InputState
@onready var head: Node3D = %Head
@onready var nearby_surface_detection: NearbySurfaceDetection = %NearbySurfaceDetection

var movement_mode: MovementMode = MovementMode.ROLL
var _head_x_rotation: float

func _ready() -> void:
    angular_damp = 10.0
    angular_damp_mode = DAMP_MODE_COMBINE

func _physics_process(delta: float) -> void:
    var input_vector: Vector3 = input_state.movement_input
    var forward := -head.global_transform.basis.z
    var left := head.global_transform.basis.x
    var up := head.global_transform.basis.y
    
    if movement_mode == MovementMode.THRUST:
        var move_dir := ((left * input_vector.x) + (up * input_vector.y) + (forward * input_vector.z)).normalized()
        apply_central_force(movement_speed * move_dir * delta)
    elif movement_mode == MovementMode.ROLL:
        # input_vector.y has no use here
        apply_torque(up * -input_vector.x * delta * roll_speed * .5) # I'm not sure why this one is faster but I'd like it to stop, please
        apply_torque(left * input_vector.z * delta * roll_speed)
    apply_torque(forward * input_state.roll_input * delta * roll_speed)

    _process_look_inputs(input_state.mouse_motion)
    
    nearby_surface_detection.update(self, delta)
    
    input_state.reset()

func _process_look_inputs(mouse_motion: Vector2) -> void:
    var delta_x := mouse_motion.y * look_sensitivity
    var delta_y := -mouse_motion.x * look_sensitivity
    
    rotate_object_local(Vector3.UP, deg_to_rad(delta_y))
    if _head_x_rotation + delta_x > -90.0 && _head_x_rotation + delta_x < 90.0:
        head.rotate_x(deg_to_rad(-delta_x));
        _head_x_rotation += delta_x

    
