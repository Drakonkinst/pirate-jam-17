extends Control

class_name HUD

@export var mission_tracker_hud: MissionTrackerHud
@onready var crosshair_prompt_primary: RichTextLabel = %CrosshairPromptPrimary
@onready var crosshair_prompt_secondary: RichTextLabel = %CrosshairPromptSecondary
@onready var fade_in_out: FadeInOut = %FadeInOut

func _ready() -> void:
    fade_in_out.show()
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
    
    if player.head.global_transform.basis.y.dot(Vector3.UP) < -0.6 and !player.nearby_surface_detection.is_aligned():
        secondary_text = "[img]" + Global.KEYBOARD_Q.resource_path + "[/img] / [img]" + Global.KEYBOARD_E.resource_path + "[/img] Tilt"
    
    if player.affected_fans.size() > 0 and not using_locked_tether:
        secondary_text = "[img]" + Global.MOUSE_RIGHT.resource_path + "[/img] Lock Tether Length"
    if hook_target is SmallButton and not grapple_hook_controller.is_launched():
        var small_button := hook_target as SmallButton
        var button_state := small_button.get_state()
        if button_state == SmallButton.State.DISABLED:
            primary_text = "DAMAGED - CANNOT REPAIR"
        elif button_state == SmallButton.State.ENABLED:
            primary_text = "[img]" + Global.MOUSE_LEFT.resource_path + "[/img] Press"
    if hook_target != null && hook_target.is_in_group("GoalBatteryHolder") and Global.game.mission_tracker.current_mission.mission_id == "power_comms":
        primary_text = "NEEDS POWER CELL"
    if hook_target != null && hook_target.is_in_group("Battery"):
        primary_text = "POWER CELL"

    crosshair_prompt_primary.text = "[b]" + primary_text + "[/b]"
    crosshair_prompt_secondary.text = "[b]" + secondary_text + "[/b]"
