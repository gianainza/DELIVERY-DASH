extends Node2D
## Spawns the 2 cars driving around the roads and the NPCs standing / walking on the sidewalks.
## All positions below are in MAP pixels (the 918x570 map art); they are converted to world positions.
const TrafficCar = preload("res://scripts/traffic_car.gd")
const Npc = preload("res://scripts/npc.gd")
const CAR_SHEET := "res://art/traffic/CarMove.png"
const NPC_SHEETS := ["res://art/npc/NPC1.png", "res://art/npc/NPC2.png"]

var bg   # the map Sprite2D, used to convert map pixels -> world

func _ready():
	bg = get_parent().get_node_or_null("Sprite2D")
	if bg == null:
		return
	_spawn_cars()
	_spawn_npcs()

# Loads a texture even if Godot has not imported the PNG yet (so cars/NPCs are never invisible)
func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var t = load(path)
		if t is Texture2D:
			return t
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if img == null or img.is_empty():
		push_warning("WorldLife: could not load " + path)
		return null
	return ImageTexture.create_from_image(img)

func _w(p: Vector2) -> Vector2:
	return bg.position + p * bg.scale

# ---------------- cars ----------------
func _spawn_cars():
	# Big outer loop (the main road). Several cars so there is always one near the player.
	var outer := _round([Vector2(96, 190), Vector2(340, 190), Vector2(340, 75), Vector2(825, 75), Vector2(825, 503), Vector2(96, 503)], 48.0)
	# Small loop around the shop block
	var inner := _round([Vector2(355, 212), Vector2(355, 384), Vector2(560, 384), Vector2(560, 212)], 34.0)
	var n := outer.size()
	_add_car(outer, 100.0, 0, Color(1.0, 0.62, 0.35))
	_add_car(outer, 100.0, int(n * 0.33), Color(1, 1, 1))
	_add_car(outer, 100.0, int(n * 0.66), Color(0.55, 0.8, 1.0))
	_add_car(inner, 80.0, 0, Color(1.0, 0.45, 0.45))
	_add_car(inner, 80.0, int(inner.size() * 0.5), Color(0.7, 1.0, 0.6))

func _add_car(map_points: Array, spd: float, start: int, tint: Color = Color(1, 1, 1)):
	var wp: Array = []
	for p in map_points:
		wp.append(_w(p))
	var car := TrafficCar.new()
	car.points = wp
	car.speed = spd
	car.start_index = start
	car.sheet = _tex(CAR_SHEET)
	car.tint = tint
	car.position = wp[start % wp.size()]   # place it BEFORE it enters the tree so it never sits at (0,0)
	add_child(car)

# Round off the corners of a loop so the cars turn smoothly
func _round(corners: Array, r: float) -> Array:
	var out: Array = []
	var n := corners.size()
	for i in n:
		var prev: Vector2 = corners[(i - 1 + n) % n]
		var cur: Vector2 = corners[i]
		var nxt: Vector2 = corners[(i + 1) % n]
		var a: Vector2 = cur + (prev - cur).normalized() * r
		var b: Vector2 = cur + (nxt - cur).normalized() * r
		for s in 5:
			var k := s / 4.0
			out.append(a * pow(1.0 - k, 2.0) + cur * (2.0 * k * (1.0 - k)) + b * (k * k))
	return out

# ---------------- NPCs ----------------
func _spawn_npcs():
	# Walking NPCs (ping-pong along a sidewalk)
	_walker(0, [Vector2(500, 113), Vector2(780, 113)], 42.0)    # top-right island, top sidewalk
	_walker(1, [Vector2(130, 250), Vector2(130, 440)], 38.0)    # left island, left sidewalk
	_walker(0, [Vector2(610, 348), Vector2(785, 348)], 45.0)    # right island, top sidewalk
	_walker(1, [Vector2(392, 240), Vector2(526, 240)], 36.0)    # sidewalk around the shop block
	# Standing pairs (talking to each other)
	_pair(0, 1, Vector2(692, 238), Vector2(718, 240))   # next to the parked blue car
	_pair(1, 0, Vector2(285, 426), Vector2(309, 428))   # by the door of the blue house

func _walker(sheet_i: int, map_points: Array, spd: float):
	var wp: Array = []
	for p in map_points:
		wp.append(_w(p))
	var n := Npc.new()
	n.sheet = _tex(NPC_SHEETS[sheet_i])
	n.walk_points = wp
	n.speed = spd
	n.position = wp[0]
	add_child(n)

func _pair(sheet_a: int, sheet_b: int, map_a: Vector2, map_b: Vector2):
	var a := Npc.new()
	a.sheet = _tex(NPC_SHEETS[sheet_a])
	a.position = _w(map_a)
	a.face_target = _w(map_b)
	add_child(a)
	var b := Npc.new()
	b.sheet = _tex(NPC_SHEETS[sheet_b])
	b.position = _w(map_b)
	b.face_target = _w(map_a)
	add_child(b)
