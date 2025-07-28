extends Sprite3D

@export var text_angle := 3.0
@onready var label: Label3D = %Label3D

const ALPHA_THRESHOLD := 40.0
func _process(_delta: float) -> void:
    if not is_visible():
        return
    var player_pos = Global.game.player.global_position
    var dist_to_player := player_pos.distance_to(global_position)
    var text_distance := dist_to_player * sin(deg_to_rad(text_angle))
    label.position.y = -text_distance
    var color := get_modulate()
    color.a = 1.0 if dist_to_player > ALPHA_THRESHOLD else (dist_to_player / ALPHA_THRESHOLD)
    set_modulate(color)
    label.text = str(int(dist_to_player)) + "m"
    
    
