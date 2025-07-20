extends Node3D

class_name BreakableGlass

@export var stages: Array[BrokenGlassStage]
@export var stage := 0
@onready var mesh: MeshInstance3D = %MeshInstance3D
@onready var collider: CollisionShape3D = %CollisionShape3D

func _ready() -> void:
    _set_stage(stage)
    
func progress_stage() -> void:
    if stage < stages.size() - 1:
        _set_stage(stage + 1)

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
    
