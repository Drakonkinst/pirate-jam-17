extends RichTextLabel

class_name ScrollingText

@export var characters_per_second := 25

var _num_chars_in_line := 0
var _character_progress := 0.0
var _typing := false

func _ready() -> void:
    clear_text()
    
func _process(delta: float) -> void:
    if _typing:
        _character_progress += characters_per_second * delta
        visible_ratio = min(1.0, _character_progress / _num_chars_in_line)
        Global.audio.play_typing()
        if _character_progress >= _num_chars_in_line:
            _typing = false 

func display_text(value: String) -> void:
    visible_ratio = 0.0
    text = value
    _character_progress = 0.0
    _num_chars_in_line = value.length()
    _typing = true

func clear_text() -> void:
    visible_ratio = 0.0
    text = ""
    _typing = false
    

func is_typing() -> bool:
    return _typing
