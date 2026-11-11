extends AnimatableBody2D
## Walking or standing NPC. Sheets: art/npc/NPC1.png, NPC2.png (8 frames of 32x32, face DOWN).
## - walk_points (2+ world points): walks back and forth between them
## - otherwise stands still and (optionally) turns to face face_target
var sheet: Texture2D
var walk_points: Array = []
var speed := 45.0
var face_target := Vector2.INF
const FRAMES := 8
const NPC_SCALE := 1.0

var sprite: Sprite2D
var idx := 0
var dir := 1
var t := 0.0

func _ready():
	z_index = 4
	sync_to_physics = false
	sprite = Sprite2D.new()
	sprite.texture = sheet
	sprite.hframes = FRAMES
	sprite.scale = Vector2(NPC_SCALE, NPC_SCALE)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	var cs := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 7.0
	cs.shape = shape
	add_child(cs)
	if walk_points.size() >= 2:
		position = walk_points[0]
		idx = 0
		t = randf() * 8.0
	elif face_target != Vector2.INF:
		rotation = (face_target - position).angle() - PI / 2.0

func _physics_process(delta: float):
	if walk_points.size() < 2:
		sprite.frame = 0
		return
	var target: Vector2 = walk_points[idx + dir]
	var to_target: Vector2 = target - position
	var step: float = speed * delta
	if to_target.length() <= step:
		position = target
		idx += dir
		if idx + dir < 0 or idx + dir >= walk_points.size():
			dir = -dir   # turn around at the end of the path
	else:
		position += to_target.normalized() * step
	rotation = lerp_angle(rotation, to_target.angle() - PI / 2.0, 1.0 - exp(-8.0 * delta))
	t += delta * 8.0
	sprite.frame = int(t) % FRAMES
