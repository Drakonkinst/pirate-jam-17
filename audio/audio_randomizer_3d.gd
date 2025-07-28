extends AudioStreamPlayer3D

class_name AudioRandomizer3D

@export var audio_tracks: Array[AudioStream]
@export var min_pitch: float = 0.9
@export var max_pitch: float = 1.1

func play_random():
    if audio_tracks.size() <= 0:
        print("WARNING: No audio found")
        return
    stream = audio_tracks[randi() % audio_tracks.size()]
    pitch_scale = randf_range(min_pitch, max_pitch)
    play()