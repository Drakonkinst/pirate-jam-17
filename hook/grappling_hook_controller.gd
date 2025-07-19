extends Node3D

class_name GrapplingHookController

signal hook_state_changed(state: HookState)

enum HookState { LAUNCHED, ON_COOLDOWN, READY }

@export var pull_speed                       := 1000.0
@export var grappling_hook_range: float      =  20.0
@export var player: Player
@export var hook_rope_scene: PackedScene
@export var hook_target_scene: PackedScene
@onready var _hook_launch_cooldown: Timer = %HookLaunchCooldown
@onready var _hook_failed_cooldown: Timer = %HookFailedCooldown
@onready var _hook_rope_model: HookRopeModel  =  %HookRopeModel
var _hook_state: HookState           =  HookState.READY
var _hook_target_node: Node3D        =  null
var _hook_target_normal: Vector3     =  Vector3.ZERO


func _ready() -> void:
    _hook_launch_cooldown.timeout.connect(_on_hook_launch_cooldown_timeout)
    _hook_failed_cooldown.timeout.connect(_on_hook_failed_cooldown_timeout)
    player.hook_raycast.target_position = Vector3(0, 0, -grappling_hook_range)
    _hook_rope_model.hide()

func _physics_process(delta: float) -> void:
    if player.input_state.is_pressing_primary:
        if _hook_state == HookState.READY:
            _launch_hook()
    else:
        if _hook_state == HookState.LAUNCHED:
            _retract_hook()
            
    if _hook_state == HookState.LAUNCHED && _hook_target_node != null:
        var source_pos := player.hook_origin.global_position
        var pull_vector := (_hook_target_node.global_position - source_pos).normalized()
        player.apply_central_force(pull_vector * delta * pull_speed)
        
        assert(_hook_rope_model != null)
        _hook_rope_model.extend_from_to(source_pos, _hook_target_node.global_position, _hook_target_normal)
        _hook_rope_model.show()

func _on_hook_launch_cooldown_timeout() -> void:
    _set_hook_state(HookState.READY)
    
func _on_hook_failed_cooldown_timeout() -> void:
    _retract_hook()
    
func _launch_hook() -> void:
    if player.hook_raycast.is_colliding():
        print("Hook target found")
        # Hook to object
        var target: Node3D = player.hook_raycast.get_collider()
        
        # Initialize target node
        _hook_target_node = Marker3D.new()
        target.add_child(_hook_target_node)
        _hook_target_node.global_position = player.hook_raycast.get_collision_point()
        _hook_target_normal = player.hook_raycast.get_collision_normal()
    else:
        print("No hook target")
        # No target found: still throw out the hook, but it immediately retracts
        _hook_failed_cooldown.start(0.5)
    _set_hook_state(HookState.LAUNCHED)
    
func _retract_hook() -> void:
    _set_hook_state(HookState.ON_COOLDOWN)
    if _hook_target_node != null:
        _hook_target_node.queue_free()
        _hook_target_node = null
    _hook_rope_model.hide()
    _hook_launch_cooldown.start(1)

func _set_hook_state(state: HookState) -> void:
    _hook_state = state
    hook_state_changed.emit(_hook_state)
    
