extends Control

class_name OptionsScreen

signal on_return_pressed

@onready var music_slider: HSlider = %MusicSlider
@onready var environment_slider: HSlider = %EnvironmentSlider
@onready var interface_slider: HSlider = %InterfaceSlider
@onready var go_upright: CheckBox = %GoUpright
@onready var disable_alignment: CheckBox = %DisableAlignment
@onready var speedrun_timer: CheckBox = %SpeedrunTimer
@onready var mouse_sensitivity: HSlider = %MouseSensitivity
@onready var roll_speed: HSlider = %RollSpeed

func _ready() -> void:
    music_slider.value_changed.connect(_on_music_slider_value_changed)
    environment_slider.value_changed.connect(_on_environment_slider_value_changed)
    interface_slider.value_changed.connect(_on_interface_slider_value_changed)
    mouse_sensitivity.value_changed.connect(_on_mouse_sensitivity_slider_value_changed)
    roll_speed.value_changed.connect(_on_roll_speed_slider_value_changed)
    
    go_upright.pressed.connect(_on_go_upright_pressed)
    disable_alignment.pressed.connect(_on_disable_alignment_pressed)
    speedrun_timer.pressed.connect(_on_speedrun_timer_pressed)
    
    music_slider.mouse_exited.connect(release_focus)
    environment_slider.mouse_exited.connect(release_focus)
    interface_slider.mouse_exited.connect(release_focus)
    mouse_sensitivity.mouse_exited.connect(release_focus)
    roll_speed.mouse_exited.connect(release_focus)
    
    music_slider.value = Global.get_music_volume()
    interface_slider.value = Global.get_ui_volume()
    environment_slider.value = Global.get_environment_volume()
    mouse_sensitivity.value = Global.look_sensitivity
    roll_speed.value = Global.roll_speed
    go_upright.button_pressed = Global.always_go_upright
    disable_alignment.button_pressed = Global.disable_surface_alignment
    speedrun_timer.button_pressed = Global.show_speedrun_timer
    
func _on_return_button_pressed() -> void:
    on_return_pressed.emit()

func _on_music_slider_value_changed(value: float) -> void:
    Global.set_music_volume(value)

func _on_environment_slider_value_changed(value: float) -> void:
    Global.set_environment_volume(value)

func _on_interface_slider_value_changed(value: float) -> void:
    Global.set_ui_volume(value)

func _on_mouse_sensitivity_slider_value_changed(value: float) -> void:
    Global.set_look_sensitivity(value)

func _on_roll_speed_slider_value_changed(value: float) -> void:
    Global.set_roll_speed(value)

func _on_go_upright_pressed() -> void:
    Global.set_always_go_upright(go_upright.button_pressed)

func _on_disable_alignment_pressed() -> void:
    Global.set_disable_surface_alignment(disable_alignment.button_pressed)

func _on_speedrun_timer_pressed() -> void:
    Global.set_show_speedrun_timer(speedrun_timer.button_pressed)