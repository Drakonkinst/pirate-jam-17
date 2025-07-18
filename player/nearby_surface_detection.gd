extends Node3D

class_name NearbySurfaceDetection

@onready var _timer: Timer = %SurfaceDetectionTimer
@onready var _surface_detector: ShapeCast3D = %SurfaceDetector

var nearby_surface_vector: Vector3

func _ready() -> void:
    _timer.timeout.connect(_on_surface_detection_timer_timeout)

func _on_surface_detection_timer_timeout() -> void:
    nearby_surface_vector = Vector3.ZERO
    var nearest_surface: Node3D = null
    var highest_dot: float = -9999 # Comparing dot products
    for i in range(_surface_detector.get_collision_count()):
        var colliding_object: Node3D = _surface_detector.get_collider(i)
        if !colliding_object.is_in_group("Surface"):
            continue
        var collision_normal := _surface_detector.get_collision_normal(i)
        var dot: float = collision_normal.dot(global_transform.basis.y)
        if dot > highest_dot:
            highest_dot = dot
            nearest_surface = colliding_object
            nearby_surface_vector = collision_normal
#    if nearest_surface != null:
#        print(highest_dot, " ", nearby_surface_vector, " ", nearest_surface)
