extends Area3D

class_name NearbySurfaceDetection

@onready var _timer: Timer = %SurfaceDetectionTimer

var nearby_surface_vector: Vector3

func _process(_delta: float) -> void:
    _timer.timeout.connect(_on_surface_detection_timer_timeout)

func _on_surface_detection_timer_timeout() -> void:
    nearby_surface_vector = Vector3.ZERO
    var nearest_surface: Node3D = null
    var min_distance_sq := 9999
    for body in get_overlapping_bodies():
        if body.is_in_group("Surface"):
            var dist_sq := body.global_position.distance_squared_to(global_position)
            if dist_sq < min_distance_sq:
                min_distance_sq = dist_sq
                nearest_surface = body
                
    if nearest_surface != null:
        # Might need a better way of getting the normal, but ah well
        var normal := nearest_surface.global_transform.basis.y
        print(normal)
        nearby_surface_vector = normal
        
