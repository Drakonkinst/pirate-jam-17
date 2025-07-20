extends Node3D
class_name NearbySurfaceDetection

@export var surface_align_speed := 2.0

@onready var _surface_detection_timer: Timer = %SurfaceDetectionTimer
@onready var _surface_detector: ShapeCast3D = %SurfaceDetector
@onready var _below_surface_detector: RayCast3D = %BelowSurfaceDetector

var _nearby_surface_vector: Vector3

func _ready() -> void:
    _surface_detection_timer.timeout.connect(_on_surface_detection_timer_timeout)

func update(player: Player, delta: float) -> void:
    var is_still := player.input_state.movement_input.is_zero_approx() && player.input_state.roll_input == 0
    var up := player.global_transform.basis.y.normalized()
    if !is_still:
        reset_surface_alignment()

    # Find the nearest surface and slowly rotate towards it
    if _nearby_surface_vector != Vector3.ZERO:
        var cosa := up.dot(_nearby_surface_vector)
        var alpha := acos(cosa)
        var axis := up.cross(_nearby_surface_vector)
        if axis != Vector3.ZERO:
            axis = axis.normalized()
            var target_basis := player.global_transform.basis.rotated(axis, alpha)
            surface_align_speed = surface_align_speed
            player.global_transform.basis = player.global_transform.basis.slerp(target_basis, surface_align_speed * delta)

func _on_surface_detection_timer_timeout() -> void:
    _nearby_surface_vector = Vector3.ZERO
    
    var colliding_object: Node3D = null
    if _below_surface_detector.is_colliding():
        colliding_object = _below_surface_detector.get_collider()
        if colliding_object.is_in_group("Surface"):
            _nearby_surface_vector = _below_surface_detector.get_collision_normal()
    if colliding_object == null && _surface_detector.is_colliding():
        colliding_object = _surface_detector.get_collider(0)
        if colliding_object.is_in_group("Surface"):
            _nearby_surface_vector = _surface_detector.get_collision_normal(0)

func reset_surface_alignment():
    pass
