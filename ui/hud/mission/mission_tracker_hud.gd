extends Control

class_name MissionTrackerHud

# This is so spaghetti, I love it

enum Stage { SHOW_SPLASH, HIDE_SPLASH, PRINT_TITLE, PRINT_SUBTITLE, FINISHED }
@export var title_text: ScrollingText
@export var mission_text: ScrollingText
@export var splash: Control
@export var next_stage_timer: Timer

# https://byteatatime.dev/posts/easings/
const GENTLE_EASE := -2
const EASE_IN := 1 / 5.0
const EASE_OUT := 4

const TIME_SHOW := 0.75
const TIME_HIDE := 0.75

var _current_mission: Mission
var _stage := Stage.FINISHED
var _splash_width: float
var _progress := 0.0

func _ready() -> void:
    _splash_width = splash.size.x
    next_stage_timer.timeout.connect(_on_next_stage_timer_timeout)

func _process(delta: float) -> void:
    splash.size.x = 0
    if _stage == Stage.SHOW_SPLASH:
        _progress += delta
        splash.size.x = _splash_width * clamp(ease(_progress / TIME_SHOW, EASE_IN), 0.0, 1.0)
        if _progress >= TIME_SHOW and next_stage_timer.time_left <= 0:
            splash.size.x = _splash_width
            next_stage_timer.start(0.5)
    elif _stage == Stage.HIDE_SPLASH:
        _progress += delta
        splash.size.x = _splash_width * clamp(ease(1 - _progress / TIME_HIDE, EASE_OUT), 0.0, 1.0)
        if _progress >= TIME_HIDE and next_stage_timer.time_left <= 0:
            splash.size.x = 0
            next_stage_timer.start(0.1)
    elif _stage == Stage.PRINT_TITLE:
        if not title_text.is_typing() and next_stage_timer.time_left <= 0:
            next_stage_timer.start(0.1)
    elif _stage == Stage.PRINT_SUBTITLE:
        if not mission_text.is_typing() and next_stage_timer.time_left <= 0:
            next_stage_timer.start(0.1)

func start_mission(mission: Mission) -> void:
    Global.audio.finish_task.play()
    _current_mission = mission
    _stage = Stage.SHOW_SPLASH
    _progress = 0.0
    title_text.clear_text()
    mission_text.clear_text()
    next_stage_timer.stop()
    
func is_typing() -> bool:
    return title_text.is_typing() || mission_text.is_typing()
    
func _on_next_stage_timer_timeout() -> void:
    _progress = 0.0
    if _stage >= Stage.size() - 1:
        return
    _stage = (_stage + 1) as Stage
    if _stage == Stage.PRINT_TITLE:
        title_text.display_text("OBJECTIVE")
    elif _stage == Stage.PRINT_SUBTITLE:
        mission_text.display_text(_current_mission.text)
    
    
