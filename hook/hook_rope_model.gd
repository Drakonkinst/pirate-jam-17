extends Node3D

class_name HookRopeModel

@onready var rope: Node3D = %Rope
@onready var rope_mesh: MeshInstance3D = %RopeMesh
@onready var rope_visual_target: Node3D = %RopeVisualTarget
@onready var hook_end: Node3D = %HookEnd

func extend_from_to(source_position: Vector3, target_position: Vector3, target_normal: Vector3) -> void:
    global_position = source_position
    hook_end.global_position = target_position
    print("END ", target_position)
    _align_hook_end_with_surface(target_normal)
    
    var visual_target_position := _get_visual_target(target_position)
    var distance_to_target := global_position.distance_to(visual_target_position)

    (rope_mesh.mesh as CylinderMesh).height = distance_to_target
    rope_mesh.position.z = -distance_to_target / 2 
    rope.look_at(visual_target_position)

# This function compensates for the possible error of "look_at()" function
# when model has to look straight up/down.
func _align_hook_end_with_surface(target_normal: Vector3) -> void:
    if target_normal.dot(Vector3.UP) > 0.001 or target_normal.y < 0:
        if target_normal.y > 0:
            hook_end.rotation_degrees.x = -90
        elif target_normal.y < 0:
            hook_end.rotation_degrees.x = 90
    else:
        hook_end.look_at(hook_end.global_position - target_normal)

# This function is here because it takes some time to load a hook end model, so
# this functions uses the physical pull target while the visual marker is loading.
func _get_visual_target(default_value: Vector3) -> Vector3:
    if rope_visual_target:
        return rope_visual_target.global_position 
    return default_value
