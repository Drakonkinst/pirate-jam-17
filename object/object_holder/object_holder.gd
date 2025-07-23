extends Node3D

class_name ObjectHolder

@export var attract_area: Area3D
@export var anchor_point: Node3D
@export var angular_speed := 5
@export var linear_speed := 5

var _target_rot: Quaternion
var _target_pos: Vector3

func _ready() -> void:
    _target_rot = Quaternion(anchor_point.transform.basis) 
    _target_pos = anchor_point.global_position
    
func _physics_process(delta: float) -> void:
    for body in attract_area.get_overlapping_bodies():
        if body is not Collidable:
            continue
        var collidable := body as Collidable
        if collidable.lock_state != Collidable.LockState.UNLOCKED:
            collidable.set_lock_state(Collidable.LockState.LOCKED)
            _lerp_to_position(collidable, delta)

func _lerp_to_position(collidable: Collidable, delta: float) -> void:
    var current_rot := Quaternion(collidable.transform.basis)
    var smooth_rot := current_rot.slerp(_target_rot, angular_speed * delta)
    collidable.transform.basis = Basis(smooth_rot)
    collidable.global_position = lerp(collidable.global_position, _target_pos, delta * linear_speed)
    
