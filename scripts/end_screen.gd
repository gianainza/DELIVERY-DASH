extends Control
## End screen. Uses your art: res://art/end_win.png and res://art/end_lose.png
## Invisible buttons sit on top of the "Play Again" and "Main Menu" text in the art.

const GameResult = preload("res://scripts/game_result.gd")

# Button areas as fractions of the screen (matched to the art): [left, top, right, bottom]
const PLAY_AGAIN_AREA := [0.30, 0.82, 0.50, 0.90]
const MAIN_MENU_AREA := [0.54, 0.82, 0.74, 0.90]

func _ready():
	var won: bool = GameResult.won
	_make_background(won)
	_make_message(won)
	_make_button(PLAY_AGAIN_AREA, func(): get_tree().change_scene_to_file("res://scenes/game.tscn"))
	_make_button(MAIN_MENU_AREA, func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))

func _make_background(won: bool):
	var path := "res://art/3.png" if won else "res://art/4.png"
	if ResourceLoader.exists(path):
		var tr = TextureRect.new()
		tr.texture = load(path)
		tr.set_anchors_preset(Control.PRESET_FULL_RECT)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(tr)
	else:
		var cr = ColorRect.new()
		cr.color = Color("103642") if won else Color("401E11")
		cr.set_anchors_preset(Control.PRESET_FULL_RECT)
		cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(cr)

func _make_message(won: bool):
	var msg: String
	if won:
		msg = "You delivered all 3 orders with %d star(s) left. Great shift!" % GameResult.stars
	else:
		msg = "You lost all 3 stars and the agency let you go. Delivered %d/3 orders." % GameResult.delivered
	var l = Label.new()
	l.text = msg
	l.anchor_left = 0.2
	l.anchor_right = 0.8
	l.anchor_top = 0.50
	l.anchor_bottom = 0.74
	l.offset_left = 0
	l.offset_right = 0
	l.offset_top = 0
	l.offset_bottom = 0
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 52)
	l.add_theme_color_override("font_color", Color("EFEFEB"))
	l.add_theme_color_override("font_outline_color", Color("103642"))
	l.add_theme_constant_override("outline_size", 16)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)

func _make_button(area: Array, callback: Callable):
	var b = Button.new()
	b.anchor_left = area[0]
	b.anchor_top = area[1]
	b.anchor_right = area[2]
	b.anchor_bottom = area[3]
	b.offset_left = 0
	b.offset_top = 0
	b.offset_right = 0
	b.offset_bottom = 0
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.flat = true
	# invisible normally, soft highlight on hover/press so players can see it's clickable
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(1, 1, 1, 0.22)
	hover.set_corner_radius_all(16)
	var empty = StyleBoxEmpty.new()
	b.add_theme_stylebox_override("normal", empty)
	b.add_theme_stylebox_override("focus", empty)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.pressed.connect(callback)
	add_child(b)
