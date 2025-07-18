extends RigidBody3D

class_name Player

@onready var input_state: InputState = %InputState
@onready var nearby_surface_detection: NearbySurfaceDetection = %NearbySurfaceDetection
var movement_speed := 100
var look_sensitivity := 50.0
var roll_speed := 80
var surface_align_speed_when_still := 1.5
var surface_align_speed_when_moving := 0.25
var touching_surface := false

func _ready() -> void:
    input_state.mouse_looked.connect(_on_input_state_mouse_looked)
    angular_damp = 1.0
    angular_damp_mode = DAMP_MODE_COMBINE

func _on_input_state_mouse_looked(look_dir: Vector2):
    var right := -global_transform.basis.x
    var down := -global_transform.basis.y
    var delta_x := look_dir.y * look_sensitivity
    var delta_y := look_dir.x * look_sensitivity
    rotate(down, deg_to_rad(delta_y))
    rotate(right, deg_to_rad(delta_x))

func _physics_process(delta: float) -> void:
    var input_vector: Vector3 = input_state.movement_input
    var forward := -global_transform.basis.z
    var left := global_transform.basis.x
    var up := global_transform.basis.y
    var nearby_surface_vector := nearby_surface_detection.nearby_surface_vector
    var is_still := input_vector.is_zero_approx() && input_state.roll_input == 0
    
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
        var surface_align_speed := surface_align_speed_when_still if is_still else surface_align_speed_when_moving
        global_transform.basis = global_transform.basis.slerp(target_basis, surface_align_speed * delta)
