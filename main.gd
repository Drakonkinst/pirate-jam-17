extends Node

class_name Main

@export var game_scene: PackedScene
@export var main_menu_scene: PackedScene
@export var audio: AudioManager

var game: Game
var menu: MainMenu

func _ready() -> void:
    Global.audio = audio
    Engine.max_fps = 60
    init_main_menu()

func init_main_menu() -> void:
    menu = main_menu_scene.instantiate()
    menu.start_game.connect(start_new_game)
    add_child(menu)
    
func start_new_game() -> void:
    if menu != null:
        remove_child(menu)
        menu = null
    game = game_scene.instantiate()
    game.exit_game.connect(exit_to_menu)
    game.restart_game.connect(restart)
    Global.game = game
    add_child(game)

func exit_to_menu() -> void:
    if game != null:
        remove_child(game)
        game = null
    init_main_menu()

func restart() -> void:
    exit_to_menu()
    start_new_game()
