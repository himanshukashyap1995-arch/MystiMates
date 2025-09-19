extends Area2D

signal swiped(tile: Area2D, dir: Vector2i)

var grid_pos: Vector2i
var tile_type: int = 0
var _press_pos: Vector2 = Vector2.ZERO
var _dragging: bool = false

const MIN_SWIPE_DIST := 16.0

func set_color(c: Color) -> void:
	var rect := get_node_or_null("ColorRect") as ColorRect
	if rect == null:
		rect = ColorRect.new()
		rect.name = "ColorRect"
		rect.custom_minimum_size = Vector2(64, 64)
		add_child(rect)
	rect.color = c

func set_grid_position(gp: Vector2i, tile_size: int) -> void:
	grid_pos = gp
	position = Vector2(gp.x * tile_size, gp.y * tile_size)


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press_pos = (event as InputEventMouseButton).position
			_dragging = true
		else:
			if _dragging:
				var delta: Vector2 = (event as InputEventMouseButton).position - _press_pos
				_dragging = false
				if delta.length() >= MIN_SWIPE_DIST:
					var dir := Vector2i(0, 0)
					if absf(delta.x) > absf(delta.y):
						dir = Vector2i(1 if delta.x > 0.0 else -1, 0)
					else:
						dir = Vector2i(0, 1 if delta.y > 0.0 else -1)
					emit_signal("swiped", self, dir)
