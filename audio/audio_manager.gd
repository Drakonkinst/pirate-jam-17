extends Node3D

class_name AudioManager

@onready var mission_typing: AudioStreamPlayer = %MissionTyping

func _ready() -> void:
    mission_typing.playing = Global.game.hud.mission_tracker_hud.is_typing()
        
