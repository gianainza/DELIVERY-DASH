extends CharacterBody2D

enum State { WALKING, BIKING }
var current_state = State.WALKING
var is_throwing = false

# --- MOVEMENT VARIABLES ---
@export var walk_speed = 120.0
@export var bike_base_speed = 250.0
@export var bike_boost_speed = 450.0
var current_speed = walk_speed
@export var walk_scale = Vector2(0.5,0.5)      # change this to resize walking only
@export var bike_scale = Vector2(1.0,1.0) # current size, used for bike + toss
# --- BOOST VARIABLES ---
var max_boost = 100.0
var current_boost = 100.0
var boost_drain_rate = 35.0
var boost_recover_rate = 15.0
var boost_locked = false          # true after the bar is drained
var boost_unlock_level = 25.0     # bar must recover to this before boosting again

# --- FOLLOW CAMERA ---
@export var camera_zoom = 1.6          # higher = closer to the player
@export var camera_smoothing = 6.0
@export var map_size = Vector2(1925, 1069)   # camera never shows outside the map

var hud = null
@onready var anim = $AnimatedSprite2D

func _ready():
	hud = get_tree().root.get_node_or_null("Game/HUD")
	anim.scale = walk_scale
	anim.play("walk")
	_setup_camera()

func _setup_camera():
	var cam = Camera2D.new()
	cam.zoom = Vector2(camera_zoom, camera_zoom)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = camera_smoothing
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(map_size.x)
	cam.limit_bottom = int(map_size.y)
	add_child(cam)
	cam.make_current()

func _physics_process(delta):
	# Lock movement and rotation while the throwing animation plays
	if is_throwing:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed)
		move_and_slide()
		return

	handle_movement(delta)
	handle_rotation()
	handle_animations()
	handle_actions()
	move_and_slide()

func handle_movement(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if current_state == State.WALKING:
		current_speed = walk_speed
	elif current_state == State.BIKING:
		var wants_boost = Input.is_action_pressed("boost") and direction != Vector2.ZERO
		if wants_boost and current_boost > 0.0 and not boost_locked:
			current_speed = bike_boost_speed
			current_boost -= boost_drain_rate * delta
			if current_boost <= 0.0:
				current_boost = 0.0
				boost_locked = true   # drained: can't boost until it recovers a bit
		else:
			current_speed = bike_base_speed
			if current_boost < max_boost:
				current_boost += boost_recover_rate * delta

		current_boost = clamp(current_boost, 0.0, max_boost)
		if boost_locked and current_boost >= boost_unlock_level:
			boost_locked = false
		if hud:
			hud.update_speed(current_boost)

	if direction != Vector2.ZERO:
		velocity = direction * current_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed)

func handle_rotation():
	if velocity.length() > 0:
		if current_state == State.WALKING:
			anim.rotation = velocity.angle() - (PI / 2)
		elif current_state == State.BIKING:
			anim.rotation = velocity.angle() + (PI / 2)

func handle_animations():
	if velocity.length() > 0:
		if current_state == State.WALKING:
			anim.scale = walk_scale
			anim.play("walk")
		elif current_state == State.BIKING:
			anim.scale = bike_scale
			anim.play("bike")
	else:
		# Freeze on frame 0 when standing still
		anim.stop()

# E = pick up the package at the shop, or toss it at the right house
func handle_actions():
	if not Input.is_action_just_pressed("interact") or current_state != State.BIKING or is_throwing:
		return
	var dm = get_parent().get_node_or_null("DeliveryManager")
	if dm == null:
		return

	# 1) At the shop: play the toss animation, then pick the package up
	if dm.can_pickup_now():
		is_throwing = true
		anim.play("toss")
		await get_tree().create_timer(0.15).timeout
		dm.try_pickup()
		await anim.animation_finished
		is_throwing = false
		anim.play("bike")
		return

	# 2) At the right house: play the toss, then register the delivery
	if dm.can_deliver_now():
		is_throwing = true
		anim.play("toss")
		await get_tree().create_timer(0.15).timeout   # about the toss animation length
		is_throwing = false
		anim.play("bike")
		dm.complete_delivery()

# This function is called by the Parked Bike object when you touch it
func get_on_bike():
	current_state = State.BIKING
	# Trigger the phone sequence
	var delivery_manager = get_parent().get_node_or_null("DeliveryManager")
	if delivery_manager:
		delivery_manager.trigger_bike_ride()
