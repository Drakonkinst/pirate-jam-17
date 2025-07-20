extends RigidBody3D

class_name Collidable

enum Type { LIGHT, HEAVY }

@export var type: Type
@export var initial_velocity := true

func _ready() -> void:
    if initial_velocity:
        linear_velocity = Vector3(_rand_value(), _rand_value(), _rand_value())
        angular_velocity = Vector3(_rand_value(), _rand_value(), _rand_value())
    
func _rand_value() -> float:
    return randf_range(-2.0, 2.0)