extends CanvasLayer

# --- NODE REFERENCES ---
@onready var speed_meter = $SpeedMeter
@onready var box_count_text = $BoxCountFrame/BoxCountText
@onready var timer_text = $TimerFrame/TimerText

@onready var phone_ui = $PhoneUI
@onready var phone_icon = $PhoneIcon
@onready var star_container = $StarContainer

# Pause Menu
@onready var pause_menu = $PauseMenu
@onready var pause_btn = $PauseButton
@onready var continue_btn = $PauseMenu/VBoxContainer/ContinueButton
@onready var restart_btn = $PauseMenu/VBoxContainer/RestartButton
@onready var exit_btn = $PauseMenu/VBoxContainer/ExitButton

# Order detail labels inside your PhoneUI
@onready var pickup_label = $PhoneUI/PhoneBackground/PickupLabel
@onready var dropoff_label = $PhoneUI/PhoneBackground/DropoffLabel
@onready var name_label = $PhoneUI/PhoneBackground/NameLabel
@onready var package_label = $PhoneUI/PhoneBackground/PackageLabel
@onready var reward_label = $PhoneUI/PhoneBackground/RewardLabel
@onready var instruction_label = $PhoneUI/PhoneBackground/InstructionLabel
@onready var close_label = $PhoneUI/PhoneBackground/CloseLabel

# Message (top) and hint (bottom) labels, created in code
var msg_label: Label
var hint_label: Label
var msg_tween: Tween

func _ready():
	# FIX: keep the HUD alive while the game is paused, so ESC / buttons still work
	process_mode = Node.PROCESS_MODE_ALWAYS

	pause_btn.pressed.connect(_on_pause_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

	pause_menu.visible = false
	speed_meter.value = 100
	box_count_text.text = "0/3"
	timer_text.text = "00:00"
	phone_icon.play("idle")

	msg_label = _make_label(48, 175.0)
	hint_label = _make_label(38, 790.0)
	msg_label.modulate.a = 0.0
	move_child(pause_menu, -1)   # keep the pause menu above the new labels

func _make_label(font_size: int, y: float) -> Label:
	var l := Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(360, y)
	l.size = Vector2(1200, 70)
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", Color("FFFFFF"))
	l.add_theme_color_override("font_outline_color", Color("1C1C17"))
	l.add_theme_constant_override("outline_size", 10)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

# -----------------------------
# PAUSE MENU LOGIC
# -----------------------------
func _input(event):
	if event.is_action_pressed("pause_game"):
		if get_tree().paused:
			_on_continue_pressed()
		else:
			_on_pause_pressed()

func _on_pause_pressed():
	get_tree().paused = true
	pause_menu.visible = true

func _on_continue_pressed():
	pause_menu.visible = false
	get_tree().paused = false

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# -----------------------------
# HUD UPDATE FUNCTIONS
# -----------------------------
func update_speed(amount):
	speed_meter.value = amount

func update_box_count(delivered_amount):
	box_count_text.text = str(delivered_amount) + "/3"

func update_timer_display(time_left: float):
	var total := int(ceil(maxf(time_left, 0.0)))
	if timer_text:
		timer_text.text = "%02d:%02d" % [total / 60, total % 60]

# Hides a star when the player fails a delivery timer
func remove_star(stars_left):
	var stars = star_container.get_children()
	for i in range(stars.size()):
		if i >= stars_left:
			stars[i].visible = false

func set_phone_vibrating(is_vibrating):
	if is_vibrating:
		phone_icon.play("vibrating")
		AudioManager.start_vibration()
	else:
		phone_icon.play("idle")
		AudioManager.stop_vibration()

func show_phone_notification():
	if phone_icon:
		phone_icon.play("vibrating")
		AudioManager.start_vibration()

func set_order_details(data: Dictionary):
	pickup_label.text = "Pickup: " + data["pickup"]
	dropoff_label.text = "Dropoff: " + data["dropoff"]
	name_label.text = "Client: " + data["name"]
	package_label.text = "Package: " + data["package"]
	reward_label.text = "Reward: " + data["reward"]

func toggle_phone_ui(is_open: bool):
	if phone_ui:
		phone_ui.visible = is_open
		if is_open and phone_icon:
			phone_icon.play("idle")   # stop ringing once opened
			AudioManager.stop_vibration()

func _exit_tree():
	AudioManager.stop_vibration()
				
# Only changes the top instruction line ("Press F to Accept"); the "Press R to close" line stays
func set_phone_instruction(text: String):
	if instruction_label:
		instruction_label.text = text

# Big message at the top ("Order accepted!", "Delivered!", ...)
func show_message(text: String, duration: float = 2.6):
	msg_label.text = text
	msg_label.modulate.a = 1.0
	if msg_tween:
		msg_tween.kill()
	msg_tween = create_tween()
	msg_tween.tween_interval(duration)
	msg_tween.tween_property(msg_label, "modulate:a", 0.0, 0.5)

# Small hint at the bottom ("Press E to ..."). Empty string hides it.
func set_hint(text: String):
	if hint_label and hint_label.text != text:
		hint_label.text = text
