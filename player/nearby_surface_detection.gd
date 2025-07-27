extends Node3D
class_name NearbySurfaceDetection

@export var surface_align_speed := 2.0

@onready var _surface_detection_timer: Timer = %SurfaceDetectionTimer
@onready var _surface_detector: ShapeCast3D = %SurfaceDetector
@onready var _below_surface_detector: RayCast3D = %BelowSurfaceDetector
@onready var _visual: MeshInstance3D = %SurfaceVisual

var _nearby_surface_vector: Vector3

func _ready() -> void:
    _surface_detection_timer.timeout.connect(_on_surface_detection_timer_timeout)

func update(player: Player, delta: float) -> void:
    var up := player.global_transform.basis.y.normalized()
    var surface_vector := _nearby_surface_vector
    if player.input_state.go_upright || Global.always_go_upright:
        surface_vector = Vector3.UP
    
    # Find the nearest surface and slowly rotate towards it
    if surface_vector != Vector3.ZERO:
        var cosa := up.dot(surface_vector)
        var alpha := acos(cosa)
        var axis := up.cross(surface_vector)
        if axis != Vector3.ZERO:
            axis = axis.normalized()
            var target_basis := player.global_transform.basis.rotated(axis, alpha)
            surface_align_speed = surface_align_speed
            player.global_transform.basis = player.global_transform.basis.slerp(target_basis, surface_align_speed * delta)
        # Update visual
        if _below_surface_detector.is_colliding():
            _visual.global_position = _below_surface_detector.get_collision_point()
            _visual.global_transform.basis.y = surface_vector
            _visual.global_transform.basis.x = -_visual.global_transform.basis.z.cross(surface_vector)
            _visual.global_transform.basis = _visual.global_transform.basis.orthonormalized()
            _visual.scale.y = 0.01 # Retain scaling
            if not _visual.is_visible():
                _visual.show()
                _visual.reset_physics_interpolation()
        else:
            _visual.hide()
    else:
        _visual.hide()

func is_aligned() -> bool:
    return _nearby_surface_vector != Vector3.ZERO

func _on_surface_detection_timer_timeout() -> void:
    _nearby_surface_vector = Vector3.ZERO

    if Global.disable_surface_alignment:
        return
    
    var colliding_object: Node3D = null
    if _below_surface_detector.is_colliding():
        colliding_object = _below_surface_detector.get_collider()
        if colliding_object.is_in_group("Surface"):
            _nearby_surface_vector = _below_surface_detector.get_collision_normal()
    if colliding_object == null && _surface_detector.is_colliding():
        colliding_object = _surface_detector.get_collider(0)
        if colliding_object.is_in_group("Surface"):
            _nearby_surface_vector = _surface_detector.get_collision_normal(0)
