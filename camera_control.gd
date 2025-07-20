extends Camera3D

class_name CameraControl

@export var player: Player
@export var offset: Vector3

func _process(delta: float) -> void:
    global_transform.origin = player.head.global_transform.origin + offset
    global_transform.basis = player.head.global_transform.basis
