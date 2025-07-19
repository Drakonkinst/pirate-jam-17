extends Node3D
class_name GrapplingHookController

signal hook_state_changed(state: HookState)
enum HookState { LAUNCHED, ON_COOLDOWN, READY }
enum AttachmentType { NONE, GO_TO_ANCHOR, PULL_OBJECT }
@export var max_pull_speed := 1000.0
@export var grappling_hook_range: float = 20.0
@export var player: Player
@export var hook_rope_scene: PackedScene
@export var hook_anchor_scene: PackedScene

var grappling_hook_slowing_distance := 0.0 # Disabling this for now since it doesn't seem to do anything

@onready var _hook_launch_cooldown: Timer = %HookLaunchCooldown
@onready var _hook_failed_cooldown: Timer = %HookFailedCooldown
@onready var _hook_rope_model: HookRopeModel = %HookRopeModel
@onready var _hook_joint: PinJoint3D = %HookJoint

var _hook_state: HookState = HookState.READY
var _hook_target: Node3D = null # The actual object that the hook is attached to
var _hook_target_node: HookAnchorPoint = null # The attachment point of the end of the hook
var _hook_target_normal: Vector3 = Vector3.ZERO
var _rope_length: float = 0
var _attachment_type: AttachmentType = AttachmentType.NONE


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
        if _attachment_type == AttachmentType.GO_TO_ANCHOR:
            var to_target := _hook_target_node.global_position - source_pos
            var pull_vector := to_target.normalized()
            var dist_sq := to_target.length_squared()
            var dist := sqrt(dist_sq)
            print("DIST ", dist)
            
            
            if not player.input_state.is_pressing_secondary:
                print("PULL_TOWARDS_TARGET")
                # Pull towards target
                var pull_speed := max_pull_speed
                if dist <= grappling_hook_slowing_distance:
                    pull_speed = dist / grappling_hook_slowing_distance * max_pull_speed
                print("FORCE ", pull_vector, " ", delta, " ", pull_speed)
                player.apply_central_force(pull_vector * delta * pull_speed)
                _rope_length = dist
            else:
                print("KEEP_DISTANCE")
                _hook_joint.node_a = player.get_path()
                _hook_joint.node_b = _hook_target_node.get_path()
                
                # Try to make the distance constant
                # If distance is further than the length of the rope, correct it
#                if dist > _rope_length:
#                    player.apply_central_force(pull_vector * delta * max_pull_speed)
                
        if _attachment_type == AttachmentType.PULL_OBJECT:
            var pull_vector := (_hook_target_node.global_position - source_pos).normalized()

        assert(_hook_rope_model != null)
        _hook_rope_model.extend_from_to(source_pos, _hook_target_node.global_position, _hook_target_normal)
        _hook_rope_model.show()


func _on_hook_launch_cooldown_timeout() -> void:
    _set_hook_state(HookState.READY)


func _on_hook_failed_cooldown_timeout() -> void:
    _retract_hook()


func _launch_hook() -> void:
    print("Launch hook")
    if player.hook_raycast.is_colliding():
        # Hook to object
        _hook_target = player.hook_raycast.get_collider()

        # Initialize target node
        _hook_target_node = hook_anchor_scene.instantiate() as HookAnchorPoint
        _hook_target.add_child(_hook_target_node) # TODO: Save the target object as well?
        _hook_target_node.global_position = player.hook_raycast.get_collision_point()
        _hook_target_normal = player.hook_raycast.get_collision_normal()
        _set_attachment_type(AttachmentType.GO_TO_ANCHOR) # TODO: Change this up probably
        _rope_length = _hook_target_node.global_position.distance_to(player.hook_origin.global_position)
    else:
        # No target found: still throw out the hook, but it immediately retracts
        _hook_target_node = hook_anchor_scene.instantiate() as HookAnchorPoint
        Global.game.add_child(_hook_target_node)
        _hook_target_node.global_position = player.global_position - (player.global_transform.basis.z * grappling_hook_range)
        _hook_target_normal = player.hook_raycast.get_target_position().normalized() # Maybe we need to invert this?
        _hook_failed_cooldown.start(1)
        _set_attachment_type(AttachmentType.NONE)
    _set_hook_state(HookState.LAUNCHED)


func _retract_hook() -> void:
    print("Retract hook")
    _set_hook_state(HookState.ON_COOLDOWN)
    if _hook_target_node != null:
        _hook_target_node.queue_free()
        _hook_target_node = null
    if _hook_target != null:
        _hook_target = null
    _hook_rope_model.hide()
    _rope_length = 0
    _set_attachment_type(AttachmentType.NONE)
    _hook_launch_cooldown.start(1)


func _set_attachment_type(type: AttachmentType) -> void:
    if type != _attachment_type:
        _attachment_type = type


func _set_hook_state(state: HookState) -> void:
    if state != _hook_state:
        _hook_state = state
        hook_state_changed.emit(_hook_state)
    
