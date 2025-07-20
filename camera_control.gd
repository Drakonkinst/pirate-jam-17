extends Camera3D

class_name CameraControl

@export var player: Player

func _process(_delta: float) -> void:
    global_transform = player.head.global_transform
