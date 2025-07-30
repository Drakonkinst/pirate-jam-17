extends Node3D

class_name AudioManager

@onready var mission_typing: AudioStreamPlayer = %MissionTyping
@onready var fire_hook: AudioRandomizer = %FireHook
@onready var click_play: AudioStreamPlayer = %ClickPlay
@onready var finish_task: AudioRandomizer = %FinishTask
@onready var click: AudioRandomizer = %Click
@onready var fan_whoosh: AudioRandomizer = %FanWhoosh
@onready var win_button: AudioStreamPlayer = %WinButton
@onready var normal_thud: AudioRandomizer = %NormalThud
@onready var glass_thud: AudioRandomizer = %GlassThud

const MIN_DB_OFFSET := -8.0
const MAX_DB_OFFSET := 8.0
const MIN_VELOCITY := 1.0
const MAX_VELOCITY := 15.0

func _ready() -> void:
    pass
        
func play_typing() -> void:
    if not mission_typing.is_playing():
        mission_typing.play()

func _velocity_to_volume(velocity: float) -> float:
    var scale_factor := (velocity - MIN_VELOCITY) / (MAX_VELOCITY - MIN_VELOCITY)
    var volume := MIN_DB_OFFSET + (MAX_DB_OFFSET - MIN_DB_OFFSET) * scale_factor
    return volume
    
func fast_enough(velocity_sq: float) -> bool:
    return velocity_sq >= MIN_VELOCITY * MIN_VELOCITY
    
func play_normal_thud(velocity: float) -> bool:
    var volume := _velocity_to_volume(velocity)
    if not normal_thud.is_playing():
        normal_thud.volume_db = volume
        normal_thud.play_random()
        return true
    return false

func play_glass_thud(velocity: float) -> bool:
    var volume := _velocity_to_volume(velocity)
    if not normal_thud.is_playing():
        normal_thud.volume_db = volume
        normal_thud.play_random()
        return true
    return false