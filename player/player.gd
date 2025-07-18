extends RigidBody3D

class_name Player

@onready var input_state: InputState = %InputState
@onready var nearby_surface_detection: NearbySurfaceDetection = %NearbySurfaceDetection
var movement_speed := 100
var look_sensitivity := 2.0
var roll_speed := 20
var surface_align_speed := 1.0
var touching_surface := false

func _ready() -> void:
    input_state.mouse_looked.connect(_on_input_state_mouse_looked)
    angular_damp = 1.0
    angular_damp_mode = DAMP_MODE_COMBINE

func _on_input_state_mouse_looked(look_dir: Vector2):
    rotation.y -= look_dir.x * look_sensitivity
    # Cannot look further than directly down or up
    rotation.x = clamp(rotation.x - look_dir.y * look_sensitivity, -1.5, 1.5)

func _physics_process(delta: float) -> void:
    var input_vector: Vector3 = input_state.movement_input
    var forward := -global_transform.basis.z
    var left := global_transform.basis.x
    var up := global_transform.basis.y
    var nearby_surface_vector := nearby_surface_detection.nearby_surface_vector
    
    var move_dir := ((left * input_vector.x) + (up * input_vector.y) + (forward * input_vector.z)).normalized()
    apply_central_force(movement_speed * move_dir * delta)
    apply_torque(forward * input_state.roll_input * delta * roll_speed)
    
    # Find the nearest surface and slowly rotate towards it
    if nearby_surface_vector != Vector3.ZERO:
        var up_normalized := up.normalized()
        var cosa := up_normalized.dot(nearby_surface_vector)
        var alpha := acos(cosa)
        var axis := up_normalized.cross(nearby_surface_vector)
        axis = axis.normalized()
        
        var target_basis := global_transform.basis.rotated(axis, alpha)
        global_transform.basis = global_transform.basis.slerp(target_basis, surface_align_speed * delta)
