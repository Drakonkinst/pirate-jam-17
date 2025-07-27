extends Control

@export var main_pause_menu: Control
@export var options_menu: Control

func _ready() -> void:
    hide()
    Global.game.pause_control.unpaused.connect(_on_pause_control_unpaused)
    Global.game.pause_control.paused.connect(_on_pause_control_paused)

func _on_pause_control_unpaused() -> void:
    hide()

func _on_pause_control_paused() -> void:
    if Global.game.triggered_end_screen:
        return
    show()
    options_menu.hide()
    main_pause_menu.show()

func _on_resume_button_pressed() -> void:
    Global.game.pause_control.unpause()

func _on_options_screen_on_return_pressed() -> void:
    options_menu.hide()
    main_pause_menu.show()

func _on_options_button_pressed() -> void:
    options_menu.show()
    main_pause_menu.hide()

func _on_exit_to_menu_button_pressed() -> void:
    Global.game.do_exit_game()
