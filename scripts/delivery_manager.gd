extends Node

const GameResult = preload("res://scripts/game_result.gd")

const TOTAL_ORDERS := 3
const FIRST_ORDER_DELAY := 3.0   # seconds after hopping on the bike
const NEXT_ORDER_DELAY := 4.0    # seconds between orders
const INTERACT_MARGIN := 60.0    # how close (px) you must be to a building to pick up / toss
const TOSS_DISTANCE := 30.0   # how far in front of you the package lands. Smaller = closer to you
# One order per house. "time" is the countdown that starts when you accept.
const ORDERS := [
	{"pickup": "Speedy Shop", "dropoff": "House 1", "house": "house1", "name": "Jiro", "package": "Hot Meal", "reward": "$50", "time": 30.0},
	{"pickup": "Speedy Shop", "dropoff": "House 2", "house": "house2", "name": "Mika", "package": "Groceries", "reward": "$70", "time": 20.0},
	{"pickup": "Speedy Shop", "dropoff": "House 3", "house": "house3", "name": "Ren", "package": "Parcel", "reward": "$90", "time": 15.0},
]

enum State { IDLE, NOTIFIED, GO_TO_SHOP, GO_TO_DROPOFF, FINISHED }
var state: State = State.IDLE

var stars := 3
var delivered := 0
var failed := 0
var riding := false
var phone_open := false

# Still set by location_area.gd on the shop (kept so your Area scripts keep working)
var can_pickup := false
var can_dropoff := false

@onready var order_timer: Timer = $OrderTimer
@onready var game = get_parent()
@onready var hud = game.get_node_or_null("HUD")
@onready var arrow = game.get_node_or_null("DestinationArrow")
@onready var player = game.get_node_or_null("Player")
@onready var shop_node = game.get_node_or_null("EnvironmentProps/shop")

var next_timer: Timer
var end_timer: Timer
var guide = null          # arrow that circles the player and points at the target
var guide_target = null   # the building (Sprite2D) we are guiding to

func _ready():
	order_timer.one_shot = true
	next_timer = Timer.new()
	next_timer.one_shot = true
	next_timer.timeout.connect(_ring)
	add_child(next_timer)
	end_timer = Timer.new()
	end_timer.one_shot = true
	end_timer.timeout.connect(_go_to_end_screen)
	add_child(end_timer)
	if arrow:
		arrow.visible = false
	guide = preload("res://scripts/guide_arrow.gd").new()
	guide.visible = false
	add_child(guide)
	if hud:
		hud.update_timer_display(0.0)
		hud.update_box_count(0)

# ------------------------------------------------------------------
# Called by the player when they hop on the parked bike
# ------------------------------------------------------------------
func trigger_bike_ride():
	if riding:
		return
	riding = true
	if hud:
		hud.set_hint("")
		hud.show_message("You're on the bike! An order is coming...")
	next_timer.start(FIRST_ORDER_DELAY)

func _ring():
	if state == State.FINISHED or delivered + failed >= TOTAL_ORDERS:
		return
	state = State.NOTIFIED
	if hud:
		hud.set_order_details(_order())
		hud.set_phone_instruction("Press F to Accept")
		hud.show_phone_notification()
		hud.show_message("New order! Press R to open your phone")
	print("RING RING! Order ", delivered + failed + 1)

func _process(_delta):
	if state == State.FINISHED:
		return

	# R: open / close the phone (once an order has come in)
	if Input.is_action_just_pressed("phone_toggle") and state != State.IDLE:
		_set_phone_open(not phone_open)

	# F: accept the order while the phone is open
	if phone_open and state == State.NOTIFIED and Input.is_action_just_pressed("order_accept"):
		_accept_order()

	# live countdown
	if (state == State.GO_TO_SHOP or state == State.GO_TO_DROPOFF) and hud:
		hud.update_timer_display(order_timer.time_left)

	_update_hint()
	_update_guide()

func _set_phone_open(open: bool):
	phone_open = open
	if hud:
		hud.toggle_phone_ui(open)
		# keep buzzing if the order hasn't been accepted yet
		if not open and state == State.NOTIFIED:
			hud.set_phone_vibrating(true)

func _update_hint():
	if not hud or not riding:
		return
	var h := ""
	if state == State.GO_TO_SHOP and _near_shop():
		h = "Press E to pick up the package"
	elif state == State.GO_TO_DROPOFF and can_deliver_now():
		h = "Press E to toss the package"
	elif state == State.NOTIFIED and not phone_open:
		h = "Press R to open your phone"
	hud.set_hint(h)

# ------------------------------------------------------------------
# Order flow
# ------------------------------------------------------------------
func _order() -> Dictionary:
	return ORDERS[mini(delivered + failed, TOTAL_ORDERS - 1)]

func _accept_order():
	state = State.GO_TO_SHOP
	order_timer.start(_order()["time"])   # timer is per order, starts on accept
	_set_phone_open(false)
	if hud:
		hud.set_phone_vibrating(false)
		hud.set_phone_instruction("Order in progress")
		hud.show_message("Order accepted! Head to the shop")
	_point_arrow_at(shop_node)

func try_pickup() -> bool:
	if state == State.GO_TO_SHOP and _near_shop():
		state = State.GO_TO_DROPOFF
		_pickup_package()    # <-- add this line
		if hud:
			hud.show_message("Package picked up! Deliver it to " + _order()["dropoff"])
		_point_arrow_at(_house_node())
		return true
	return false

func can_deliver_now() -> bool:
	return state == State.GO_TO_DROPOFF and _near(_house_node())

# Called by the player after the toss animation finishes
func complete_delivery():
	if state != State.GO_TO_DROPOFF:
		return  # timer ran out while tossing
	order_timer.stop()
	delivered += 1
	var house = _house_node()
	if house:
		_drop_package(house)
	if hud:
		hud.update_box_count(delivered)
		hud.show_message("Delivered! +" + str(_order_before_count()["reward"]))
	_hide_arrow()
	_after_order()

func _order_before_count() -> Dictionary:
	# the order we just delivered (delivered was already incremented)
	return ORDERS[mini(delivered + failed - 1, TOTAL_ORDERS - 1)]

func _on_order_timer_timeout():
	if state != State.GO_TO_SHOP and state != State.GO_TO_DROPOFF:
		return
	stars -= 1
	failed += 1
	_hide_arrow()
	if hud:
		hud.update_timer_display(0.0)
		hud.remove_star(stars)
		hud.show_message("Time's up! You lost a star")
	print("TIME'S UP! Stars left: ", stars)
	_after_order()

func _after_order():
	_set_phone_open(false)
	if hud:
		hud.set_phone_vibrating(false)
		hud.set_hint("")
	if stars <= 0:
		_finish(false)
	elif delivered + failed >= TOTAL_ORDERS:
		_finish(true)
	else:
		state = State.IDLE
		next_timer.start(NEXT_ORDER_DELAY)

func _finish(win: bool):
	state = State.FINISHED
	GameResult.won = win
	GameResult.delivered = delivered
	GameResult.stars = stars
	if hud:
		hud.show_message("All done!" if win else "You're fired!", 3.0)
	end_timer.start(1.8)

func _go_to_end_screen():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")

# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------
func _house_node():
	return game.get_node_or_null("EnvironmentProps/" + String(_order()["house"]))

func _near_shop() -> bool:
	return can_pickup or _near(shop_node)

# Is the player within INTERACT_MARGIN pixels of this building's sprite?
func _near(spr) -> bool:
	if spr == null or player == null or spr.texture == null:
		return false
	var local: Vector2 = spr.to_local(player.global_position)
	var half: Vector2 = spr.texture.get_size() / 2.0
	var closest := Vector2(clampf(local.x, -half.x, half.x), clampf(local.y, -half.y, half.y))
	return ((local - closest) * spr.global_scale.abs()).length() <= INTERACT_MARGIN

# Top-centre of a (possibly rotated) sprite, so the arrow bounces above the building
func _top_of(spr) -> Vector2:
	var half: Vector2 = spr.texture.get_size() / 2.0
	var xf: Transform2D = spr.global_transform
	var min_y := INF
	for c in [Vector2(-half.x, -half.y), Vector2(half.x, -half.y), Vector2(half.x, half.y), Vector2(-half.x, half.y)]:
		min_y = minf(min_y, (xf * c).y)
	return Vector2(spr.global_position.x, min_y)

func _point_arrow_at(spr):
	guide_target = spr
	if guide:
		# orange while going to the shop, light blue while going to the house
		guide.color = Color("CE8046") if state == State.GO_TO_SHOP else Color("7BB0E0")
	if arrow == null or spr == null:
		return
	arrow.global_position = _top_of(spr) + Vector2(0, -40)
	arrow.visible = true
	arrow.play("bounce")

func _hide_arrow():
	guide_target = null
	if guide:
		guide.visible = false
	if arrow:
		arrow.visible = false

# The guide arrow floats next to the player and points toward the pickup / drop-off
func _update_guide():
	if guide == null:
		return
	if guide_target == null or player == null or state == State.FINISHED:
		guide.visible = false
		return
	var to_target: Vector2 = guide_target.global_position - player.global_position
	if to_target.length() < 160.0:
		guide.visible = false   # close enough: the bouncing arrow over the building takes over
		return
	guide.visible = true
	guide.global_position = player.global_position + to_target.normalized() * 80.0
	guide.rotation = to_target.angle()

const DROP_GAP := 10.0   # px in front of the wall. Bigger = lands further from the house
var _house_images := {}

func _drop_point(house, from: Vector2) -> Vector2:
	var tex: Texture2D = house.texture
	var img = _house_images.get(house)
	if img == null:
		img = tex.get_image()
		if img.is_compressed():
			img.decompress()
		_house_images[house] = img
	var half: Vector2 = tex.get_size() / 2.0
	var player_px: Vector2 = house.to_local(from) + half
	var sc: Vector2 = house.global_scale.abs()
	var used: Rect2i = img.get_used_rect()
	var best: Vector2 = player_px
	var best_d := INF
	var y: int = used.position.y
	while y < used.end.y:
		var x: int = used.position.x
		while x < used.end.x:
			if img.get_pixel(x, y).a > 0.5:
				var d: float = ((Vector2(x, y) - player_px) * sc).length_squared()
				if d < best_d:
					best_d = d
					best = Vector2(x, y)
			x += 3
		y += 3
	var edge: Vector2 = house.to_global(best - half)
	var out: Vector2 = from - edge
	if out.length() < 1.0:
		out = Vector2(0, 1)
	return edge + out.normalized() * DROP_GAP
# The package flies in an arc to the door and stays on the floor
func _drop_package(house):
	var from: Vector2 = player.global_position if player else house.global_position
	var to: Vector2 = from + (house.global_position - from).normalized() * TOSS_DISTANCE
	var path := "res://art/package_floor.png"
	if not ResourceLoader.exists(path):
		_coin_pop(to)
		return
	var pkg := Sprite2D.new()
	pkg.texture = load(path)
	pkg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pkg.scale = Vector2(0.8, 0.8)   # half the current size
	pkg.z_index = 5
	game.add_child(pkg)
	pkg.global_position = from
	var tw := pkg.create_tween()
	tw.tween_method(_fly_package.bind(pkg, from, to), 0.0, 1.0, 0.45)
	tw.tween_callback(func(): _coin_pop(to))


# The package flies in an arc from the shop to the player, then disappears
func _pickup_package():
	if shop_node == null or player == null:
		return
	var path := "res://art/package_floor.png"
	if not ResourceLoader.exists(path):
		return
	var from: Vector2 = _drop_point(shop_node, player.global_position)
	var pkg := Sprite2D.new()
	pkg.texture = load(path)
	pkg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pkg.scale = Vector2(0.8, 0.8)   # keep the same scale you used in _drop_package
	pkg.z_index = 5
	game.add_child(pkg)
	pkg.global_position = from
	var tw := pkg.create_tween()
	tw.tween_method(_fly_pickup.bind(pkg, from), 0.0, 1.0, 0.45)
	tw.tween_callback(pkg.queue_free)

# Same arc and spin as _fly_package, but it follows the player so it lands on them even if they move
func _fly_pickup(t: float, pkg: Sprite2D, from: Vector2):
	if not is_instance_valid(pkg) or player == null:
		return
	pkg.global_position = from.lerp(player.global_position, t) + Vector2(0, -sin(PI * t) * 70.0)
	pkg.rotation = t * 6.0
	
# Same arc and spin as _fly_package, but it follows the player so it still lands on them if they move
func _fly_package(t: float, pkg: Sprite2D, from: Vector2, to: Vector2):
	if not is_instance_valid(pkg):
		return
	pkg.global_position = from.lerp(to, t) + Vector2(0, -sin(PI * t) * 70.0)
	pkg.rotation = t * 6.0

func _coin_pop(pos: Vector2):
	var path := "res://art/HUD/coin only.png"
	if not ResourceLoader.exists(path):
		return
	var coin := Sprite2D.new()
	coin.texture = load(path)
	coin.scale = Vector2(3, 3)
	coin.z_index = 50
	game.add_child(coin)
	coin.global_position = pos
	var tw := coin.create_tween()
	tw.set_parallel(true)
	tw.tween_property(coin, "global_position:y", pos.y - 120.0, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(coin, "modulate:a", 0.0, 0.7).set_delay(0.3)
	tw.chain().tween_callback(coin.queue_free)

func can_pickup_now() -> bool:
	return state == State.GO_TO_SHOP and _near_shop()
