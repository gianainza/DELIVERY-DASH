extends Node2D
## Guide arrow next to the player, pointing at the pickup / drop-off.
## Uses res://art/HUD/guide_arrow.png (3 frames of 64x64). The sprite's arrow points UP,
## so it is turned 90 degrees here; the delivery manager rotates this node toward the target.
var color := Color("CE8046")   # only used by the fallback arrow if the PNG is missing
var t := 0.0
var tex: Texture2D
const FRAME_SIZE := 64
const FRAME_COUNT := 3
const ARROW_SCALE := 0.5

func _ready():
	z_index = 60
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var path := "res://art/HUD/guide_arrow.png"
	if ResourceLoader.exists(path):
		tex = load(path)

func _process(delta: float):
	t += delta
	queue_redraw()

func _draw():
	if tex == null:
		_fallback()
		return
	var frame := int(t * 6.0) % FRAME_COUNT
	draw_set_transform(Vector2.ZERO, PI / 2.0, Vector2(ARROW_SCALE, ARROW_SCALE))
	draw_texture_rect_region(tex, Rect2(-FRAME_SIZE / 2.0, -FRAME_SIZE / 2.0, FRAME_SIZE, FRAME_SIZE), Rect2(frame * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE))

func _fallback():
	var s := 24.0
	for c in [[s + 6.0, Color("1C1C17")], [s, color]]:
		var k: float = c[0]
		draw_colored_polygon(PackedVector2Array([Vector2(k, 0), Vector2(-k * 0.1, -k * 0.8), Vector2(-k * 0.1, k * 0.8)]), c[1])
		draw_rect(Rect2(-k * 0.9, -k * 0.28, k * 0.85, k * 0.56), c[1])
