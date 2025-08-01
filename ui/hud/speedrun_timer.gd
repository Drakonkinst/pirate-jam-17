extends Control

class_name SpeedrunTimer

@onready var speedrun_min_sec: RichTextLabel = %SpeedrunMinSec
@onready var speedrun_millis: RichTextLabel = %SpeedrunMillis

var time := 0.0

func _process(delta: float) -> void:
    set_visible(Global.show_speedrun_timer)
    time += delta
    var ms := int((time * 100)) % 100
    var total_secs := int(time)
    var mins := int(total_secs / 60.0)
    var secs := int(total_secs % 60)
    speedrun_min_sec.text = str(mins) + (":%02d" % secs) 
    speedrun_millis.text = ":%02d" % ms
    
func get_time_str() -> String:
    var ms := int((time * 100)) % 100
    var total_secs := int(time)
    var mins := int(total_secs / 60.0)
    var secs := int(total_secs % 60)
    return str(mins) + (":%02d" % secs) + (":%02d" % ms)
    
    