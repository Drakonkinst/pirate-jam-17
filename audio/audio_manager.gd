extends Node3D

class_name AudioManager

@onready var mission_typing: AudioStreamPlayer = %MissionTyping
@onready var fire_hook: AudioRandomizer = %FireHook
@onready var click_play: AudioStreamPlayer = %ClickPlay
@onready var finish_task: AudioRandomizer = %FinishTask
@onready var click: AudioRandomizer = %Click
@onready var fan_whoosh: AudioRandomizer = %FanWhoosh

func _ready() -> void:
    pass
        
func play_typing() -> void:
    if not mission_typing.is_playing():
        mission_typing.play()