extends Control

# The dialogue array: [Speaker Name, Text]
var dialogue = [
	["Boss", "Hey rookie! Welcome to Delivery Dash. I'm your boss, and today is your first shift."],
	["Boss", "Your job is simple: pick up packages at the shop and deliver them to the right houses. Sounds easy?"],
	["Boss", "Use W, A, S and D to move. W is up, S is down, A is left and D is right. Your bike is parked right next to you. Walk up to it and press F to hop on."],
	["Boss", "Once you're riding, hold LEFT SHIFT to boost. It's fast, but it drains your speed meter.When the speed meter is empty, you can't boost. Let it recover a bit before you try again."],
	["Boss", "Orders come through your phone. When it starts buzzing, press R to open it. Read the order, then press F to accept it. Press R again to close the phone."],
	["Boss", "The moment you accept, the timer starts. Every order has its own countdown at the top of the screen. An arrow will point you to the shop. Ride there and press E to pick up the package."],
	["Boss", "After that, the arrow points to the customer's house. Get close and press E to toss the package. A box will land by the door and a coin will pop up. That means the delivery counts!"],
	["Boss", "Watch your three stars. Every time a timer runs out, you lose one star. Lose all 3 stars and you're fired. No second chances!!!"],
	["Boss", "Be careful on the road. Cars and people will get in your way, so don't crash into them."],
	["Boss", "You'll have 3 deliveries to make. Finish them all with at least 1 star left and you win."],
	["Boss", "You can press ESC any time to pause the game, restart, or go back to the menu."],
	["Boss", "Go get your bike. Good luck, rookie!"]
]

var current_line = 0

# Node References
@onready var name_label = $NameLabel
@onready var text_label = $TextLabel
@onready var skip_button = $SkipButton
@onready var press_space_label = $PressSpaceLabel

func _ready():
	skip_button.pressed.connect(_on_skip_pressed)
	update_dialogue()

func _input(event):
	# ESC skips the whole intro
	if event.is_action_pressed("ui_cancel"):
		start_game()
		return

	# Space OR a left mouse click advances the dialogue
	if event.is_action_pressed("ui_accept"):
		advance()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# don't count clicks on the Skip button
		if not skip_button.get_global_rect().has_point(event.position):
			advance()

func advance():
	current_line += 1
	if current_line < dialogue.size():
		update_dialogue()
	else:
		start_game()

func update_dialogue():
	name_label.text = dialogue[current_line][0]
	text_label.text = dialogue[current_line][1]

	if current_line == dialogue.size() - 1:
		press_space_label.text = "PRESS SPACE / CLICK ▼"
	else:
		press_space_label.text = "PRESS SPACE / CLICK ▼"

func _on_skip_pressed():
	start_game()

func start_game():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
