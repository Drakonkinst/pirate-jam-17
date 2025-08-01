extends Node3D

class_name ObjectHolder

@export var attract_area: Area3D
@export var anchor_point: Node3D
@export var angular_speed := 0.1
@export var linear_speed := 0.1
@export var opens_door: Door
@export var stay_locked: bool = false
@export var finish_mission: String

@export_group("Lights")
@export var lights: Array[MeshInstance3D]
@export var enabled_material: Material
@export var disabled_materal: Material

@onready var power_on: AudioRandomizer3D = %PowerOn
@onready var power_off: AudioRandomizer3D = %PowerOff

var _enabled := true
var _is_first_run := true
var _target_rot: Quaternion
var _target_pos: Vector3

func _ready() -> void:
    _target_rot = Quaternion(anchor_point.transform.basis) 
    _target_pos = anchor_point.global_position
    
func _physics_process(delta: float) -> void:
    var any_bodies := false
    for body in attract_area.get_overlapping_bodies():
        if body is not Collidable:
            continue
        var collidable := body as Collidable
        if collidable.lock_state != Collidable.LockState.UNLOCKED:
            collidable.set_lock_state(Collidable.LockState.LOCKED)
            _lerp_to_position(collidable, delta)
            if collidable.global_position.distance_squared_to(_target_pos) < 0.1:
                if stay_locked:
                    collidable.stay_locked = true
                any_bodies = true

    if any_bodies and !_enabled:
        _enable()
        Global.game.mission_tracker.finish_mission(finish_mission)
    elif !any_bodies and _enabled:
        _disable()

    _is_first_run = false
                

func _lerp_to_position(collidable: Collidable, delta: float) -> void:
    var current_rot := Quaternion(collidable.transform.basis)
    var smooth_rot := current_rot.slerp(_target_rot, angular_speed)
    collidable.transform.basis = Basis(smooth_rot)
    collidable.global_position = lerp(collidable.global_position, _target_pos, linear_speed)
    
func _enable() -> void:
    for mesh in lights:
        mesh.set_surface_override_material(0, enabled_material)
    if !_enabled:
        if not _is_first_run:
            power_on.play_random()
        _enabled = true
    if opens_door != null:
        opens_door.open()

func _disable() -> void:
    for mesh in lights:
        mesh.set_surface_override_material(0, disabled_materal)
    if _enabled:
        if not _is_first_run:
            power_off.play_random()
        _enabled = false
    if opens_door != null:
        opens_door.close()
