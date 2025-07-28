extends Node3D
class_name GrapplingHookController

signal hook_state_changed(state: HookState)
enum HookState { LAUNCHED, ON_COOLDOWN, READY }
enum AttachmentType { NONE, ATTACHED }
@export var max_pull_speed := 250.0
@export var grappling_hook_range: float = 35.0
@export var player: Player
@export var hook_rope_scene: PackedScene
@export var hook_anchor_scene: PackedScene

@onready var _hook_launch_cooldown: Timer = %HookLaunchCooldown
@onready var _hook_failed_cooldown: Timer = %HookFailedCooldown
@onready var _hook_rope_model: HookRopeModel = %HookRopeModel
@onready var _hook_joint: Generic6DOFJoint3D = %HookJoint

var _hook_state: HookState = HookState.READY
var hook_target: Node3D = null # The actual object that the hook is attached to
var _hook_target_node: HookAnchorPoint = null # The attachment point of the end of the hook
var _hook_target_normal: Vector3 = Vector3.ZERO
var _attachment_type: AttachmentType = AttachmentType.NONE
var _rope_length: float = 0

const ROPE_THRESHOLD := 2.0
const ROPE_MULTIPLIER := 0.05

func _ready() -> void:
    _hook_launch_cooldown.timeout.connect(_on_hook_launch_cooldown_timeout)
    _hook_failed_cooldown.timeout.connect(_on_hook_failed_cooldown_timeout)
    player.hook_raycast.target_position = Vector3(0, 0, -grappling_hook_range)
    _hook_rope_model.hide()

func _physics_process(delta: float) -> void:
    _hook_joint.node_a = ""
    _hook_joint.node_b = ""
    
    if player.input_state.is_pressing_primary or player.input_state.is_pressing_secondary:
        if _hook_state == HookState.READY:
            _launch_hook()
    else:
        if _hook_state == HookState.LAUNCHED && _hook_target_node != null:
            # Can only manually retract hook if you actually hit something
            _retract_hook() 

    if _hook_state == HookState.LAUNCHED && _hook_target_node != null:
        var source_pos := player.hook_origin.global_position
        if  _attachment_type == AttachmentType.ATTACHED:
            _handle_hook_physics(source_pos, delta)
        assert(_hook_rope_model != null)
        _hook_rope_model.extend_from_to(source_pos, _hook_target_node.global_position, _hook_target_normal, player.input_state.is_pressing_secondary)
        if not _hook_rope_model.is_visible():
            _hook_rope_model.reset_physics_interpolation()
            _hook_rope_model.show()

func _handle_hook_physics(source_pos: Vector3, delta: float):
    var to_vector := _hook_target_node.global_position - source_pos
    var to_direction := to_vector.normalized()
    if player.input_state.is_pressing_secondary:
        var dist := to_vector.length()
        # The rope can get shorter, but not longer
        _rope_length = min(dist, _rope_length)
        
        # Lock hook and player together
        _hook_joint.node_a = player.get_path()
        _hook_joint.node_b = _hook_target_node.get_path()
        var half_length := _rope_length / 2
        _hook_joint.global_position = player.global_position + to_direction * half_length
        
        if hook_target is Collidable:
            var collidable := hook_target as Collidable
            var dist_sq := collidable.global_position.distance_squared_to(player.global_position)
            if dist_sq > (_rope_length + ROPE_THRESHOLD) * (_rope_length + ROPE_THRESHOLD):
                collidable.apply_central_force(-to_vector * delta * max_pull_speed * ROPE_MULTIPLIER)
            elif dist_sq < (_rope_length - ROPE_THRESHOLD) * (_rope_length - ROPE_THRESHOLD):
                collidable.apply_central_force(to_vector * delta * max_pull_speed * ROPE_MULTIPLIER)
        
        # Make rigid because setting it to anything else doesn't work lol
        _hook_joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
        _hook_joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
        _hook_joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
        _hook_joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, -0.0)
        _hook_joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, -0.0)
        _hook_joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, -0.0)
    else:
         # Pull towards target
        player.apply_central_force(to_direction * delta * max_pull_speed)
        if hook_target is Collidable:
            var collidable := hook_target as Collidable
            collidable.apply_central_force(-to_direction * delta * max_pull_speed)

func _on_hook_launch_cooldown_timeout() -> void:
    _set_hook_state(HookState.READY)


func _on_hook_failed_cooldown_timeout() -> void:
    _retract_hook()

func is_launched() -> bool:
    return _hook_state == HookState.LAUNCHED

func _launch_hook() -> void:
    if player.hook_raycast.is_colliding():
        # Hook to object
        hook_target = player.hook_raycast.get_collider()

        # Initialize target node
        _hook_target_node = hook_anchor_scene.instantiate() as HookAnchorPoint
        hook_target.add_child(_hook_target_node) # TODO: Save the target object as well?
        _hook_target_node.global_position = player.hook_raycast.get_collision_point()
        _hook_target_normal = player.hook_raycast.get_collision_normal()
        _rope_length = (_hook_target_node.global_position - player.head.global_position).length()
        
        if hook_target is SmallButton:
            (hook_target as SmallButton).press()
        if hook_target is Collidable:
            (hook_target as Collidable).on_attach()
        
        _set_attachment_type(AttachmentType.ATTACHED)
    else:
        # No target found: still throw out the hook, but it immediately retracts
        _hook_target_node = hook_anchor_scene.instantiate() as HookAnchorPoint
        Global.game.add_child(_hook_target_node)
        _hook_target_node.global_position = player.head.global_position + (-player.head.global_transform.basis.z * grappling_hook_range)
        _hook_target_normal = player.hook_raycast.get_target_position().normalized() # Maybe we need to invert this?
        _hook_failed_cooldown.start(0.25)
        _rope_length = grappling_hook_range
        _set_attachment_type(AttachmentType.NONE)
    _set_hook_state(HookState.LAUNCHED)
    Global.audio.fire_hook.play_random()

func _retract_hook() -> void:
    _set_hook_state(HookState.ON_COOLDOWN)
    if _hook_target_node != null:
        _hook_target_node.queue_free()
        _hook_target_node = null
    if hook_target != null:
        if hook_target is Collidable:
            (hook_target as Collidable).on_detach()
        hook_target = null
    _hook_rope_model.hide()
    _rope_length = 0
    _hook_launch_cooldown.start(0.25)
    _set_attachment_type(AttachmentType.NONE)


func _set_attachment_type(type: AttachmentType) -> void:
    if type != _attachment_type:
        _attachment_type = type


func _set_hook_state(state: HookState) -> void:
    if state != _hook_state:
        _hook_state = state
        # Apply linear damping when using hook
        if _hook_state == HookState.LAUNCHED:
            player.linear_damp = 0.5
        else:
            player.linear_damp = 0.0
        hook_state_changed.emit(_hook_state)
        
    
