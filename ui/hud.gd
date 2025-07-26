extends Control

class_name HUD

@onready var crosshair_prompt_primary: RichTextLabel = %CrosshairPromptPrimary
@onready var crosshair_prompt_secondary: RichTextLabel = %CrosshairPromptSecondary
@onready var fade_in_out: FadeInOut = %FadeInOut

func _ready() -> void:
    fade_in_out.fade_in()
    
func _process(_delta: float) -> void:
    var player := Global.game.player
    var grapple_hook_controller := Global.game.grappling_hook_controller
    var primary_text := ""
    var secondary_text := ""

    var using_locked_tether := grapple_hook_controller.is_launched() and player.input_state.is_pressing_secondary
    var hook_target: Node3D = null
    if player.hook_raycast.is_colliding():
        hook_target = player.hook_raycast.get_collider()
    hook_target = player.hook_raycast.get_collider()
    
    if player.global_transform.basis.y.dot(Vector3.UP) < -0.6 and !player.nearby_surface_detection.is_aligned():
        secondary_text = "[img]res://ui//keyboard_q.png[/img] / [img]res://ui//keyboard_e.png[/img] Roll"
    
    if player.affected_fans.size() > 0 and not using_locked_tether:
        secondary_text = "Hold [img]res://ui//mouse_right_outline.png[/img] - Lock Tether"
    if hook_target is SmallButton and not grapple_hook_controller.is_launched():
        var small_button := hook_target as SmallButton
        var button_state := small_button.get_state()
        if button_state == SmallButton.State.DISABLED:
            primary_text = "DAMAGED - CANNOT REPAIR"
        elif button_state == SmallButton.State.ENABLED:
            primary_text = "[img]res://ui//mouse_left_outline.png[/img] Press"

    crosshair_prompt_primary.text = "[b]" + primary_text + "[/b]"
    crosshair_prompt_secondary.text = "[b]" + secondary_text + "[/b]"
