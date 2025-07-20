extends Node3D
class_name GrapplingHookController

signal hook_state_changed(state: HookState)
enum HookState { LAUNCHED, ON_COOLDOWN, READY }
enum AttachmentType { NONE, GO_TO_ANCHOR, PULL_OBJECT }
@export var max_pull_speed := 1000.0
@export var grappling_hook_range: float = 35.0
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
            
            if player.input_state.is_pressing_secondary:
                # Lock hook and player together
                _hook_joint.node_a = player.get_path()
                _hook_joint.node_b = _hook_target_node.get_path()
            else:
                # Pull towards target
                var pull_speed := max_pull_speed
                if dist <= grappling_hook_slowing_distance:
                    pull_speed = dist / grappling_hook_slowing_distance * max_pull_speed
                player.apply_central_force(pull_vector * delta * pull_speed)
                player.nearby_surface_detection.pause_surface_alignment(1.0)
                
                
        if _attachment_type == AttachmentType.PULL_OBJECT:
            assert(_hook_target is Collidable)
            var collidable := _hook_target as Collidable
            var pull_vector := (source_pos - _hook_target_node.global_position).normalized()
            
            if player.input_state.is_pressing_secondary:
                # Lock hook and player together
                _hook_joint.node_a = _hook_target_node.get_path()
                _hook_joint.node_b = player.get_path()
            else:
                # Pull towards target
                var pull_speed := max_pull_speed
                collidable.apply_central_force(pull_vector * delta * pull_speed)

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
        
        _set_attachment_type(_get_attachment_type(_hook_target)) # TODO: Change this up probably
    else:
        # No target found: still throw out the hook, but it immediately retracts
        _hook_target_node = hook_anchor_scene.instantiate() as HookAnchorPoint
        Global.game.add_child(_hook_target_node)
        _hook_target_node.global_position = player.head.global_position + (-player.head.global_transform.basis.z * grappling_hook_range)
        _hook_target_normal = player.hook_raycast.get_target_position().normalized() # Maybe we need to invert this?
        _hook_failed_cooldown.start(1)
        _set_attachment_type(AttachmentType.NONE)
    _set_hook_state(HookState.LAUNCHED)

func _get_attachment_type(target: Node3D) -> AttachmentType:
    if target is Collidable:
        var collidable := target as Collidable
        if collidable.type == Collidable.Type.LIGHT:
            return AttachmentType.PULL_OBJECT
        return AttachmentType.GO_TO_ANCHOR 
    return AttachmentType.GO_TO_ANCHOR

func _retract_hook() -> void:
    print("Retract hook")
    _set_hook_state(HookState.ON_COOLDOWN)
    if _hook_target_node != null:
        _hook_target_node.queue_free()
        _hook_target_node = null
    if _hook_target != null:
        _hook_target = null
    _hook_rope_model.hide()
    # TODO: Add a quick retract condition so you can use it again quickly
    if _attachment_type == AttachmentType.GO_TO_ANCHOR:
        _hook_launch_cooldown.start(0.25)
    else:
        _hook_launch_cooldown.start(1)
    _set_attachment_type(AttachmentType.NONE)


func _set_attachment_type(type: AttachmentType) -> void:
    if type != _attachment_type:
        _attachment_type = type


func _set_hook_state(state: HookState) -> void:
    if state != _hook_state:
        _hook_state = state
        hook_state_changed.emit(_hook_state)
    
