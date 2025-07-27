extends Node3D

class_name MissionTracker

@export var missions: Array[Mission]
@export var markers: Array[Node3D]
@export var start_timer: Timer

var current_mission: Mission
var current_mission_index := -1

func _ready() -> void:
    _set_current_mission(-1)
    start_timer.timeout.connect(_on_start_timer_timeout)
    start_timer.start()
    
func _on_start_timer_timeout() -> void:
    _set_current_mission(0)
    
func _set_current_mission(index: int) -> void:
    current_mission_index = index
    if current_mission_index >= 0 and current_mission_index < missions.size():
        current_mission = missions[current_mission_index]
        Global.game.hud.mission_tracker_hud.start_mission(current_mission)
    for i in range(markers.size()):
        var marker := markers[i]
        if marker != null:
            marker.set_visible(i == current_mission_index)
    
func finish_mission(mission_id: String) -> void:
    if mission_id == null or mission_id.length() <= 0:
        return
    var finish_index := get_mission_index(mission_id)
    if finish_index < current_mission_index:
        return
    if finish_index < missions.size() - 1:
        _set_current_mission(finish_index + 1)


func get_mission_index(mission_id: String) -> int:
    for i in range(missions.size()):
        if missions[i].mission_id == mission_id:
            return i
    print("Unknown mission ID: ", mission_id)
    return -1
