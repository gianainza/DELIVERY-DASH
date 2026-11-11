extends Control

# -- UI Node References --
@onready var settings_panel = $SettingsPanel
@onready var credits_panel = $CreditsPanel

# -- Back Buttons --
@onready var settings_back_btn = $SettingsPanel/SettingsBackButton
@onready var credits_back_btn = $CreditsPanel/CreditsBackButton

# -- Main Menu Buttons --
# (Make sure these names match exactly what you named them in Step 2)
@onready var play_btn = $PlayButton
@onready var settings_btn = $SettingsButton
@onready var credits_btn = $CreditsButton
@onready var exit_btn = $ExitButton

# -- Sliders --
@onready var master_slider = $SettingsPanel/MasterSlider
@onready var music_slider = $SettingsPanel/MusicSlider
@onready var sfx_slider = $SettingsPanel/SfxSlider

# -- Audio Bus Indices --
var master_bus = AudioServer.get_bus_index("Master")
var music_bus = AudioServer.get_bus_index("Music")
var sfx_bus = AudioServer.get_bus_index("SFX")

func _ready():
	# 1. Connect Main Menu Buttons
	play_btn.pressed.connect(_on_play_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	credits_btn.pressed.connect(_on_credits_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	
	# 2. Connect Back Buttons
	settings_back_btn.pressed.connect(_on_settings_back_pressed)
	credits_back_btn.pressed.connect(_on_credits_back_pressed)
	
	# 3. Connect Sliders
	master_slider.value_changed.connect(_on_master_value_changed)
	music_slider.value_changed.connect(_on_music_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_value_changed)
	
	# 4. Set sliders to match current system volume
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))


# --- BUTTON FUNCTIONS ---

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/loading_screen.tscn")

func _on_settings_pressed():
	settings_panel.visible = true

func _on_credits_pressed():
	credits_panel.visible = true

func _on_exit_pressed():
	get_tree().quit()

func _on_settings_back_pressed():
	settings_panel.visible = false

func _on_credits_back_pressed():
	credits_panel.visible = false

# --- SLIDER FUNCTIONS ---
# linear_to_db converts the 0.0-1.0 slider value into decibels for Godot's audio engine

func _on_master_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))

func _on_music_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func _on_sfx_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
