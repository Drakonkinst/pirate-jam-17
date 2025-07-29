extends RigidBody3D

class_name Player

enum MovementMode { THRUST, ROLL }
@export var movement_speed := 100
@onready var hook_origin: Marker3D = %HookOrigin
@onready var hook_raycast: RayCast3D = %HookRaycast
@onready var input_state: InputState = %InputState
@onready var head: Node3D = %Head
@onready var nearby_surface_detection: NearbySurfaceDetection = %NearbySurfaceDetection
@onready var mesh: MeshInstance3D = %MeshInstance3D

var movement_mode: MovementMode = MovementMode.ROLL
var affected_fans: Dictionary[int, bool]

var _head_x_rotation: float
var _last_linear_velocity_sq := 0.0

const DRIFTED_AWAY_THRESHOLD := 275.0

func _ready() -> void:
    angular_damp = 10.0
    angular_damp_mode = DAMP_MODE_COMBINE
    mesh.hide()

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
        apply_torque(up * -input_vector.x * delta * Global.roll_speed * .5) # I'm not sure why this one is faster but I'd like it to stop, please
        apply_torque(left * input_vector.z * delta * Global.roll_speed)
    apply_torque(forward * input_state.roll_input * delta * Global.roll_speed)

    _process_look_inputs(input_state.mouse_motion)
    
    nearby_surface_detection.update(self, delta)

    var collisions := get_colliding_bodies()
    if collisions.size() > 0:
        var collider: Node3D = collisions[0]
        if collider is BreakableGlass:
            # TODO: Do stuff
            pass

    # Hardcoding this one because I can't be bothered to set up an area
    if global_position.x <= -30:
        Global.game.mission_tracker.finish_mission("leave_crew_quarters")
    
    if global_position.length_squared() >= DRIFTED_AWAY_THRESHOLD * DRIFTED_AWAY_THRESHOLD:
        Global.game.display_end_screen("You Drifted Away into the Endless Void of Space", "Better luck next time?", false)

    _last_linear_velocity_sq = linear_velocity.length_squared()
    input_state.reset()

func _process_look_inputs(mouse_motion: Vector2) -> void:
    var delta_x: float = mouse_motion.y * Global.look_sensitivity
    var delta_y: float = -mouse_motion.x * Global.look_sensitivity
    
    if Global.always_go_upright:
        rotate_object_local(Vector3.UP, deg_to_rad(delta_y * 0.5))
        if _head_x_rotation + delta_x > -90.0 && _head_x_rotation + delta_x < 90.0:
            head.rotate_x(deg_to_rad(-delta_x * 0.5));
            _head_x_rotation += delta_x
    else:
        var left := head.global_transform.basis.x
        var up := head.global_transform.basis.y
        apply_torque(up * delta_y)
        apply_torque(left * -delta_x)

func on_fan_count_change(prev: int, next: int) -> void:
    if prev == next:
        return
    if prev == 0 and next > 0 and not Global.audio.fan_whoosh.playing:
        Global.audio.fan_whoosh.play_random()
    
