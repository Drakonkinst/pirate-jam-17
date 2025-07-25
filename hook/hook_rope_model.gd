extends Node3D

class_name HookRopeModel

@onready var rope: Node3D = %Rope
@onready var rope_mesh: MeshInstance3D = %RopeMesh
@onready var hook_end: Node3D = %HookEnd

func extend_from_to(source_position: Vector3, target_position: Vector3, target_normal: Vector3) -> void:
    global_position = source_position
    hook_end.global_position = target_position
    _align_hook_end_with_surface(target_normal)
    
    var distance_to_target := global_position.distance_to(target_position)

    (rope_mesh.mesh as CylinderMesh).height = distance_to_target
    rope_mesh.position.z = -distance_to_target / 2 
    rope.look_at(target_position)

# This function compensates for the possible error of "look_at()" function
# when model has to look straight up/down.
func _align_hook_end_with_surface(target_normal: Vector3) -> void:
    if target_normal.dot(Vector3.UP) > 0.001 or target_normal.y < -1e-5:
        if target_normal.y > 0:
            hook_end.rotation_degrees.x = -90
        elif target_normal.y < 0:
            hook_end.rotation_degrees.x = 90
    else:
        hook_end.look_at(hook_end.global_position - target_normal)
