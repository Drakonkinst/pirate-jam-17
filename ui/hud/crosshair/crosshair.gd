extends TextureRect

class_name Crosshair

var frame_delay := 0.2 / 16.0
var interpolate := true

var _animated_texture: AnimatedTexture
var _current_frame := 0
var _desired_frame := 0
var _frame_delay_buildup := 0.0

func _ready() -> void:
    Global.game.grappling_hook_controller.hook_state_changed.connect(_on_grappling_hook_controller_hook_state_changed)
    assert(texture is AnimatedTexture)
    _animated_texture = texture as AnimatedTexture
    _animated_texture.set_current_frame(_current_frame)
    _animated_texture.set_pause(true)
    
func _on_grappling_hook_controller_hook_state_changed(hook_state: GrapplingHookController.HookState) -> void:
    _desired_frame = 0 if hook_state != GrapplingHookController.HookState.LAUNCHED else (_animated_texture.frames - 1)
    if !interpolate:
        _animated_texture.set_current_frame(_desired_frame)
    
func _process(delta: float) -> void:
    if _current_frame == _desired_frame:
        _frame_delay_buildup = 0
        return
    if !interpolate:
        return
    _frame_delay_buildup += delta
    while _frame_delay_buildup >= frame_delay:
        _frame_delay_buildup -= frame_delay
        _progress_frame()
        
func _progress_frame() -> void:
    if _current_frame < _desired_frame:
        _current_frame += 1
    elif _current_frame > _desired_frame:
        _current_frame -= 1
    _animated_texture.set_current_frame(_current_frame)
