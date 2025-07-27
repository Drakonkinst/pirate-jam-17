extends Node3D

class_name BreakableGlass

@export var stages: Array[BrokenGlassStage]
@export var stage := 0
@export var finish_mission: String
@onready var mesh: MeshInstance3D = %MeshInstance3D
@onready var collider: CollisionShape3D = %CollisionShape3D
@onready var break_timer: Timer = %BreakTimer

var _can_take_damage := true

func _ready() -> void:
    _set_stage(stage)
    break_timer.timeout.connect(_on_break_timer_timeout)
    
func progress_stage() -> void:
    if stage < stages.size() - 1 and _can_take_damage:
        _set_stage(stage + 1)
        _can_take_damage = false
        break_timer.start()

func _set_stage(value: int) -> void:
    stage = value
    var info := stages[stage]
    var material := mesh.get_surface_override_material(0)
    material.set("shader_parameter/shatter", info.show_cracks)
    material.set("shader_parameter/fracture_scale", info.fracture_scale)
    material.set("shader_parameter/edge_thickness", info.edge_thickness)
    if info.show_broken:
        # Make an impact in the center
        material.set("shader_parameter/impact_points", PackedVector3Array([global_position]))
    else:
        material.set("shader_parameter/impact_points", PackedVector3Array())
    collider.disabled = info.show_broken
    if stage >= stages.size() - 1:
        Global.game.mission_tracker.finish_mission(finish_mission)

func _on_break_timer_timeout() -> void:
    _can_take_damage = true
    
