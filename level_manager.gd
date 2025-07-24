extends Node3D

@export var section_points: Array[Node3D]
@export var lights: Array[Node3D]
@export var player: Player

func _process(_delta: float) -> void:
    var player_pos := player.global_position
    var furthest_dist_sq := -9999.0
    var furthest_index := -1
    
    for i in range(section_points.size()):
        var point := section_points[i]
        var dist_sq := point.global_position.distance_squared_to(player_pos)
        if dist_sq > furthest_dist_sq:
            furthest_dist_sq = dist_sq
            furthest_index = i
        
    assert(furthest_index > -1)
    for i in range(lights.size()):
        if i == furthest_index:
            lights[i].hide()
        else:
            lights[i].show()
