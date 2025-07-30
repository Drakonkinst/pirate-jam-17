extends Control

class_name EndScreen

@export var title_text: ScrollingText
@export var subtitle_text: ScrollingText
@export var controls: Control

var _awaiting_finish: bool = false
var _subtitle: String

func _ready() -> void:
    title_text.clear_text()
    subtitle_text.clear_text()
    controls.hide()
    hide()

func display(title: String, subtitle: String) -> void:
    show()
    title_text.display_text(title.to_upper())
    _subtitle = subtitle
    _awaiting_finish = true
    
func _process(_delta: float) -> void:
    if _awaiting_finish and not title_text.is_typing():
        _awaiting_finish = false
        subtitle_text.display_text(_subtitle)
        controls.show()
        
func _on_restart_button_pressed() -> void:
    Global.audio.click.play_random("ES1")
    Global.game.do_restart_game()

func _on_exit_button_pressed() -> void:
    Global.audio.click.play_random("ES2")
    Global.game.do_exit_game()
