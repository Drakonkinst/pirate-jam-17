extends RigidBody3D

class_name Collidable

enum Type { LIGHT, HEAVY }

@export var type: Type
@export var initial_velocity := true

var _last_linear_velocity_sq := 0.0

const MIN_GLASS_BREAK_THRESHOLD := 5.0

func _ready() -> void:
    if initial_velocity:
        linear_velocity = Vector3(_rand_value(), _rand_value(), _rand_value())
        angular_velocity = Vector3(_rand_value(), _rand_value(), _rand_value())
    if type == Type.HEAVY:
        contact_monitor = true
        max_contacts_reported = 1
    
func _rand_value() -> float:
    return randf_range(-2.0, 2.0)
    
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
    _last_linear_velocity_sq = linear_velocity.length_squared()
