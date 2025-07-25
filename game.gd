extends Node3D
class_name Game

@export var player: Player
@export var grappling_hook_controller: GrapplingHookController
@export var hud: HUD

func _ready() -> void:
	grappling_hook_controller.hook_state_changed.connect(_on_grappling_hook_controller_hook_state_changed)

func get_hook_target() -> Node3D:
	return grappling_hook_controller.hook_target


func _on_grappling_hook_controller_hook_state_changed(state: GrapplingHookController.HookState) -> void:
	pass
