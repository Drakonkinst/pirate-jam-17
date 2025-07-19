extends RigidBody3D

class_name Player

@export var movement_speed := 100
@export var look_sensitivity := 50.0
@export var roll_speed := 80
@onready var hook_origin: Marker3D = %HookOrigin
@onready var hook_raycast: RayCast3D = %HookRaycast
@onready var input_state: InputState = %InputState
@onready var nearby_surface_detection: NearbySurfaceDetection = %NearbySurfaceDetection

func _ready() -> void:
    input_state.mouse_looked.connect(_on_input_state_mouse_looked)
    angular_damp = 2.0
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
    
    var move_dir := ((left * input_vector.x) + (up * input_vector.y) + (forward * input_vector.z)).normalized()
    apply_central_force(movement_speed * move_dir * delta)
    apply_torque(forward * input_state.roll_input * delta * roll_speed)
    
    nearby_surface_detection.update(self, delta)
    

    
