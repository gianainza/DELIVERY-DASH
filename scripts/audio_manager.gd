extends Node

const BGM_PATH     = "res://audio/soundtrack 1.mp3"
const CLICK_PATH   = "res://audio/matthewvakaliuk73627-mouse-click-290204.mp3"
const VIBRATE_PATH = "res://audio/freesound_community-phone-vibration-96623.mp3"

var bgm := AudioStreamPlayer.new()
var click := AudioStreamPlayer.new()
var vibrate := AudioStreamPlayer.new()

func _ready() -> void:
	# keep playing while the game is paused (pause menu)
	process_mode = Node.PROCESS_MODE_ALWAYS

	# --- Background music (loops forever) ---
	var bgm_stream: AudioStreamMP3 = load(BGM_PATH)
	bgm_stream.loop = true
	bgm.stream = bgm_stream
	bgm.bus = "Music"
	add_child(bgm)
	bgm.play()

	# --- Click sfx ---
	click.stream = load(CLICK_PATH)
	click.bus = "SFX"
	add_child(click)

	# --- Phone vibration sfx (loops until stopped) ---
	var vibe_stream: AudioStreamMP3 = load(VIBRATE_PATH)
	vibe_stream.loop = true
	vibrate.stream = vibe_stream
	vibrate.bus = "SFX"
	add_child(vibrate)

	# Auto-hook EVERY button in EVERY scene (including ones made in code)
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		node.pressed.connect(play_click)

func play_click() -> void:
	click.play()

func start_vibration() -> void:
	if not vibrate.playing:   # don't restart it if it's already buzzing
		vibrate.play()

func stop_vibration() -> void:
	vibrate.stop()
	
# Keys that should NOT click. Remove a line to make that key click.
const SKIP_ACTIONS := ["move_up", "move_down", "move_left", "move_right", "boost"]

# Click when a key from the Input Map is pressed (includes F for hopping on the bike)
func _input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	for action in InputMap.get_actions():
		if action.begins_with("ui_") or action in SKIP_ACTIONS:
			continue
		if event.is_action_pressed(action):
			play_click()
			return
