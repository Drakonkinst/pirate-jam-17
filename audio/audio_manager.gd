extends Node3D

class_name AudioManager

@onready var mission_typing: AudioStreamPlayer = %MissionTyping
@onready var fire_hook: AudioRandomizer = %FireHook

func _ready() -> void:
    pass
        
func play_typing() -> void:
    if not mission_typing.is_playing():
        mission_typing.play()