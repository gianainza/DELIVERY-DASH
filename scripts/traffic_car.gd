extends AnimatableBody2D
## A car that drives around a closed loop of points (world positions). Uses art/traffic/CarMove.png
## (8 frames of 44x80, car faces UP). The player can't drive through it.
var points: Array = []
var speed := 90.0
var start_index := 0
var sheet: Texture2D
var tint := Color(1, 1, 1)
const FRAMES := 8
const CAR_SCALE := 1.1

var idx := 0
var sprite: Sprite2D
var t := 0.0

func _ready():
	z_index = 5   # above the map and props, below the player (z 10)
	sync_to_physics = false   # move directly; avoids the body being stuck at (0,0)
	if points.size() < 2:
		return
	idx = start_index % points.size()
	position = points[idx]
	var next: Vector2 = points[(idx + 1) % points.size()]
	rotation = (next - position).angle() + PI / 2.0

	sprite = Sprite2D.new()
	sprite.texture = sheet
	sprite.hframes = FRAMES
	sprite.modulate = tint
	sprite.scale = Vector2(CAR_SCALE, CAR_SCALE)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)

	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 50) * CAR_SCALE
	cs.shape = shape
	add_child(cs)

func _physics_process(delta: float):
	if points.size() < 2:
		return
	var target: Vector2 = points[(idx + 1) % points.size()]
	var to_target: Vector2 = target - position
	var step: float = speed * delta
	if to_target.length() <= step:
		position = target
		idx = (idx + 1) % points.size()
	else:
		position += to_target.normalized() * step
	# turn smoothly toward where we are heading (the art faces up, hence + PI/2)
	rotation = lerp_angle(rotation, to_target.angle() + PI / 2.0, 1.0 - exp(-8.0 * delta))
	t += delta * 8.0
	sprite.frame = int(t) % FRAMES
