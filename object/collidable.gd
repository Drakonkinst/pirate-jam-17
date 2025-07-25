extends RigidBody3D

class_name Collidable

enum Type { LIGHT, HEAVY }

enum LockState { LOCKED, UNLOCKED, ANY }

@export var type: Type
@export var initial_velocity := true
@export var can_lock_in := false
@export var unlock_timer: Timer

var _last_linear_velocity_sq := 0.0
var lock_state: LockState = LockState.ANY

const MIN_GLASS_BREAK_THRESHOLD := 5.0
const DAMPING_THRESHOLD := 50.0

func _ready() -> void:
    if initial_velocity:
        linear_velocity = Vector3(_rand_value(), _rand_value(), _rand_value())
        angular_velocity = Vector3(_rand_value(), _rand_value(), _rand_value())
    if type == Type.HEAVY:
        contact_monitor = true
        max_contacts_reported = 1
    if unlock_timer != null:
        unlock_timer.timeout.connect(_on_unlock_timer_timeout)
    linear_damp_mode = RigidBody3D.DampMode.DAMP_MODE_REPLACE
    linear_damp = 0.0
    set_collision_layer_value(3, true)
    
func _rand_value() -> float:
    return randf_range(-0.25, 0.25)
    
func _physics_process(delta: float) -> void:
    if type == Type.LIGHT:
        return
    var collisions := get_colliding_bodies()
    if collisions.size() > 0:
        var collider: Node3D = collisions[0]
        if collider is BreakableGlass:
            var glass := collider as BreakableGlass
            if _last_linear_velocity_sq >= MIN_GLASS_BREAK_THRESHOLD * MIN_GLASS_BREAK_THRESHOLD:
                glass.progress_stage() 
    # Apply linear damp to objects that are far away from the player so they eventually come to a stop and sleep
    var dist_sq_from_player := Global.game.player.global_position.distance_squared_to(global_position)
    if dist_sq_from_player >= DAMPING_THRESHOLD * DAMPING_THRESHOLD:
        linear_damp = 1.0
    else:
        linear_damp = 0.0
    
    _last_linear_velocity_sq = linear_velocity.length_squared()
    
func set_lock_state(state: LockState) -> void:
    lock_state = state
    freeze = state == LockState.LOCKED

func on_attach() -> void:
    if can_lock_in:
        if lock_state == LockState.LOCKED:
            set_lock_state(LockState.UNLOCKED)
    
func on_detach() -> void:
    if can_lock_in:
        if unlock_timer != null:
            unlock_timer.start(3) # Fuck it we hardcode
        
func _on_unlock_timer_timeout() -> void:
    set_lock_state(LockState.ANY)
