extends Node

const CONFIG_PATH := "user://settings.cfg"

var game: Game = null
var main: Main = null

var config := ConfigFile.new()
var music := AudioServer.get_bus_index("Music")
var ui := AudioServer.get_bus_index("UI")
var environment := AudioServer.get_bus_index("Environment")
var audio: AudioManager

var always_go_upright := false
var disable_surface_alignment := true
var show_speedrun_timer := false

var look_sensitivity := 75.0
var roll_speed := 250.0

const KEYBOARD_Q = preload("res://ui//keyboard_q.png")
const KEYBOARD_R = preload("res://ui//keyboard_r.png")
const KEYBOARD_E = preload("res://ui//keyboard_e.png")
const MOUSE_MOVE = preload("res://ui//mouse_move.png")
const MOUSE_LEFT = preload("res://ui//mouse_left_outline.png")
const MOUSE_RIGHT = preload("res://ui//mouse_right_outline.png")

func _ready() -> void:
    _load_config()
    print("music=", music, ", ui=", ui, ", environment=", environment)
    
func _load_config() -> void:
    var err := config.load(CONFIG_PATH)
    if err != OK:
        return
    if config.has_section_key("audio", "music"):
        set_music_volume(config.get_value("audio", "music"), false)
    if config.has_section_key("audio", "ui"):
        set_ui_volume(config.get_value("audio", "ui"), false)
    if config.has_section_key("audio", "environment"):
        set_environment_volume(config.get_value("audio", "environment"), false)
    if config.has_section_key("gameplay", "always_go_upright"):
        set_always_go_upright(config.get_value("gameplay", "always_go_upright"), false)
    if config.has_section_key("gameplay", "disable_surface_alignment"):
        set_disable_surface_alignment(config.get_value("gameplay", "disable_surface_alignment"), false)
    else:
        set_disable_surface_alignment(true, false)
    if config.has_section_key("gameplay", "show_speedrun_timer"):
        set_show_speedrun_timer(config.get_value("gameplay", "show_speedrun_timer"), false)
    if config.has_section_key("controls", "look_sensitivity"):
        set_look_sensitivity(config.get_value("controls", "look_sensitivity"), false)
    if config.has_section_key("controls", "roll_speed"):
        set_roll_speed(config.get_value("controls", "roll_speed"), false)
    config.save(CONFIG_PATH)

func set_music_volume(value: float, save: bool = true) -> void:
    AudioServer.set_bus_volume_db(music, linear_to_db(value))
    if save:
        config.set_value("audio", "music", value)
        config.save(CONFIG_PATH)

func set_ui_volume(value: float, save: bool = true) -> void:
    AudioServer.set_bus_volume_db(ui, linear_to_db(value))
    if save:
        config.set_value("audio", "ui", value)
        config.save(CONFIG_PATH)

func set_environment_volume(value: float, save: bool = true) -> void:
    AudioServer.set_bus_volume_db(environment, linear_to_db(value))
    if save:
        config.set_value("audio", "environment", value)
        config.save(CONFIG_PATH)

func get_music_volume() -> float:
    return db_to_linear(AudioServer.get_bus_volume_db(music))

func get_environment_volume() -> float:
    return db_to_linear(AudioServer.get_bus_volume_db(environment))

func get_ui_volume() -> float:
    return db_to_linear(AudioServer.get_bus_volume_db(ui))

func set_look_sensitivity(value: float, save: bool = true) -> void:
    look_sensitivity = value
    if save:
        config.set_value("controls", "look_sensitivity", value)
        config.save(CONFIG_PATH)

func set_roll_speed(value: float, save: bool = true) -> void:
    roll_speed = value
    if save:
        config.set_value("controls", "roll_speed", value)
        config.save(CONFIG_PATH)

func set_always_go_upright(value: bool, save: bool = true) -> void:
    always_go_upright = value
    if save:
        config.set_value("gameplay", "always_go_upright", value)
        config.save(CONFIG_PATH)

func set_disable_surface_alignment(value: bool, save: bool = true) -> void:
    disable_surface_alignment = value
    if save:
        config.set_value("gameplay", "disable_surface_alignment", value)
        config.save(CONFIG_PATH)

func set_show_speedrun_timer(value: bool, save: bool = true) -> void:
    show_speedrun_timer = value
    if save:
        config.set_value("gameplay", "show_speedrun_timer", value)
        config.save(CONFIG_PATH)