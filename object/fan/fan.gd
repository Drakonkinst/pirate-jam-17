extends Node3D

@export var max_distance := 15.0
@export var push_force := 500.0
@export var enabled := true
@export var stays_enabled := false
@export var auto_restarts := false
@export var affected_by_distance := false
@export var toggle_button: SmallButton
@export var shut_off_timer: Timer
@export var shut_off_after: float = 5.0
@export var turn_on_timer: Timer
@export var turn_on_after: float = 5.0

@export_group("Internal")
@export var wind_visual: Node3D
@export var affects_area: Area3D
@export var collider: CollisionShape3D

func _ready() -> void:
    if max_distance > 0:
        (collider.shape as BoxShape3D).size.y = max_distance
    if toggle_button != null:
        toggle_button.pressed.connect(_on_button_pressed)
    shut_off_timer.timeout.connect(_on_shut_off_timer_timeout)
    if turn_on_timer != null:
        turn_on_timer.timeout.connect(_on_turn_on_timer_timeout)
    if enabled:
        enable()
    else:
        disable()
        
func _physics_process(delta: float) -> void:
    if not enabled:
        return
    var overlapping := affects_area.get_overlapping_bodies()
    var hitting_player := false
    for node in overlapping:
        if node is RigidBody3D:
            var rb := node as RigidBody3D
            var force := push_force
            if affected_by_distance:
                var dist_sq := node.global_position.distance_squared_to(global_position)
                force /= dist_sq
            rb.apply_central_force(global_transform.basis.y * force * delta)
            if node is Player:
                hitting_player = true
    if hitting_player:
        Global.game.player.affected_fans[get_instance_id()] = true
    else:
        Global.game.player.affected_fans.erase(get_instance_id())
        
            
func enable() -> void:
    enabled = true
    if not stays_enabled:
        shut_off_timer.start(shut_off_after)
    wind_visual.show()
        
func disable() -> void:
    enabled = false
    if auto_restarts:
        turn_on_timer.start(turn_on_after)
    wind_visual.hide()
    
func _on_button_pressed() -> void:
    if enabled:
        disable()
    else:
        enable()
    
func _on_shut_off_timer_timeout() -> void:
    disable()

func _on_turn_on_timer_timeout() -> void:
    enable()
