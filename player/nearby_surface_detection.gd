extends Node3D
class_name NearbySurfaceDetection

@export var surface_align_speed_when_still := 1.0
@export var surface_align_speed_when_moving := 0.1

@onready var _surface_detection_timer: Timer = %SurfaceDetectionTimer
@onready var _surface_detector: ShapeCast3D = %SurfaceDetector
@onready var _surface_alignment_timer: Timer = %SurfaceAlignmentTimer

var _need_to_recalculate := true
var _should_surface_align_quickly := true
var _nearby_surface_vector: Vector3

func _ready() -> void:
    _surface_detection_timer.timeout.connect(_on_surface_detection_timer_timeout)
    _surface_alignment_timer.timeout.connect(_on_surface_alignment_timer_timeout)


func update(player: Player, delta: float) -> void:
    var is_still := player.input_state.movement_input.is_zero_approx() && player.input_state.roll_input == 0
    var up := player.global_transform.basis.y.normalized()
    if !is_still:
        pause_surface_alignment(1.0)

    # Find the nearest surface and slowly rotate towards it
    if _nearby_surface_vector != Vector3.ZERO:
        var cosa := up.dot(_nearby_surface_vector)
        var alpha := acos(cosa)
        var axis := up.cross(_nearby_surface_vector)
        if axis != Vector3.ZERO:
            axis = axis.normalized()
            var target_basis := player.global_transform.basis.rotated(axis, alpha)
            var surface_align_speed := surface_align_speed_when_still if _should_surface_align_quickly else surface_align_speed_when_moving
            player.global_transform.basis = player.global_transform.basis.slerp(target_basis, surface_align_speed * delta)

func _on_surface_detection_timer_timeout() -> void:
    if not _need_to_recalculate:
        return
    _nearby_surface_vector = Vector3.ZERO
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
            _nearby_surface_vector = collision_normal
    if nearest_surface != null:
        _need_to_recalculate = false

func _on_surface_alignment_timer_timeout():
    _should_surface_align_quickly = true

func pause_surface_alignment(time: float):
    _should_surface_align_quickly = false
    _need_to_recalculate = true
    _surface_alignment_timer.start(max(_surface_alignment_timer.time_left, time))
