extends Node2D

signal score_changed(score: int)
signal moves_changed(moves: int)
signal win()
signal lose()

const GRID_SIZE := Vector2i(6, 6)
const TILE_SIZE := 64
const TILE_TYPES := 4
var COLORS: Array

# Per-level configuration
@export var starting_moves: int = 10
@export var target_score: int = 100

var grid: Array = [] # 2D array of Tile nodes
var types: Array = [] # 2D array of ints

var moves_left: int = 10
var score: int = 0

@export var tile_scene: PackedScene
var busy: bool = false

func _ready() -> void:
	COLORS = [Color8(231, 76, 60), Color8(52, 152, 219), Color8(46, 204, 113), Color8(241, 196, 15)]
	# Fallback: if tile_scene not assigned in Inspector/board.tscn, load it here
	if tile_scene == null:
		tile_scene = load("res://tile.tscn") as PackedScene
	# Initialize counters from exported configuration
	moves_left = starting_moves
	_initialize_arrays()
	_spawn_initial_grid()
	_emit_updates()
	# Resolve any initial matches without consuming moves
	_resolve_all_matches()
	_emit_updates()

func _initialize_arrays() -> void:
	grid.resize(GRID_SIZE.x)
	types.resize(GRID_SIZE.x)
	for x in range(GRID_SIZE.x):
		grid[x] = []
		types[x] = []
		grid[x].resize(GRID_SIZE.y)
		types[x].resize(GRID_SIZE.y)

func _spawn_initial_grid() -> void:
	for x in range(GRID_SIZE.x):
		for y in range(GRID_SIZE.y):
			var t := _create_random_tile(Vector2i(x, y))
			grid[x][y] = t
			types[x][y] = t.tile_type

func _create_random_tile(gp: Vector2i) -> Area2D:
	# Try to instantiate from PackedScene; if unavailable, build the tile procedurally.
	var t: Area2D
	if tile_scene == null:
		tile_scene = load("res://tile.tscn") as PackedScene
	if tile_scene != null:
		t = tile_scene.instantiate()
	else:
		t = _make_tile_fallback()
	add_child(t)
	t.tile_type = _random_type_avoiding(gp)
	t.set_color(COLORS[t.tile_type])
	t.set_grid_position(gp, TILE_SIZE)
	t.swiped.connect(_on_tile_swiped)
	return t

# Fallback: create a tile procedurally if res://tile.tscn cannot be loaded
func _make_tile_fallback() -> Area2D:
	var tile := Area2D.new()
	# Attach tile.gd script if available for consistent behavior
	var tile_script := load("res://scripts/tile.gd")
	if tile_script:
		tile.set_script(tile_script)
	# Visual
	var rect := ColorRect.new()
	rect.custom_minimum_size = Vector2(TILE_SIZE, TILE_SIZE)
	rect.color = Color8(255, 255, 255)
	tile.add_child(rect)
	# Collision
	var shape := CollisionShape2D.new()
	shape.position = Vector2(TILE_SIZE/2, TILE_SIZE/2)
	var rshape := RectangleShape2D.new()
	rshape.size = Vector2(TILE_SIZE, TILE_SIZE)
	shape.shape = rshape
	tile.add_child(shape)
	return tile

func _random_type_avoiding(gp: Vector2i) -> int:
	# Prevent immediate 3-in-a-row at creation time if possible.
	# Ensure all code paths return a value.
	var attempts := 0
	while attempts < 12:
		var tt := randi() % TILE_TYPES
		if not _would_form_match(gp, tt):
			return tt
		attempts += 1
	# Fallback if suitable type not found in attempts
	return randi() % TILE_TYPES

func _would_form_match(gp: Vector2i, tt: int) -> bool:
	var x := gp.x
	var y := gp.y
	# Guard against uninitialized or out-of-bounds access
	if x < 0 or y < 0 or x >= GRID_SIZE.x or y >= GRID_SIZE.y:
		return false
	# Check horizontal (explicit branches)
	if x >= 2:
		if types[x-1][y] == tt and types[x-2][y] == tt:
			return true
		else:
			pass
	else:
		pass
	# Check vertical (explicit branches)
	if y >= 2:
		if types[x][y-1] == tt and types[x][y-2] == tt:
			return true
		else:
			pass
	else:
		pass
	return false

func _on_tile_swiped(tile: Area2D, dir: Vector2i) -> void:
	if busy:
		return
	var gp := Vector2i(roundi(tile.position.x / TILE_SIZE), roundi(tile.position.y / TILE_SIZE))
	var np := gp + dir
	if not _in_bounds(np):
		return
	busy = true
	# Perform swap visually and in arrays
	_swap(gp, np)
	var matches := _find_matches()
	if matches.size() > 0:
		moves_left -= 1
		emit_signal("moves_changed", moves_left)
		_clear_and_cascade(matches)
		_resolve_all_matches()
		_check_end_conditions()
	else:
		# swap back if invalid
		_swap(gp, np)
	busy = false

func _swap(a: Vector2i, b: Vector2i) -> void:
	var ta = grid[a.x][a.y]
	var tb = grid[b.x][b.y]
	grid[a.x][a.y] = tb
	grid[b.x][b.y] = ta
	var tta = types[a.x][a.y]
	types[a.x][a.y] = types[b.x][b.y]
	types[b.x][b.y] = tta
	# Update positions
	ta.set_grid_position(b, TILE_SIZE)
	tb.set_grid_position(a, TILE_SIZE)

func _find_matches() -> Array:
	var to_clear := {}
	# Horizontal
	for y in range(GRID_SIZE.y):
		var count := 1
		for x in range(1, GRID_SIZE.x):
			if types[x][y] == types[x-1][y] and types[x][y] != -1:
				count += 1
			else:
				if count >= 3:
					for k in range(count):
						to_clear[Vector2i(x-1-k+1, y)] = true
				count = 1
			if x == GRID_SIZE.x - 1 and count >= 3:
				for k in range(count):
					to_clear[Vector2i(x-k+1, y)] = true
	# Vertical
	for x in range(GRID_SIZE.x):
		var countv := 1
		for y in range(1, GRID_SIZE.y):
			if types[x][y] == types[x][y-1] and types[x][y] != -1:
				countv += 1
			else:
				if countv >= 3:
					for k in range(countv):
						to_clear[Vector2i(x, y-1-k+1)] = true
				countv = 1
			if y == GRID_SIZE.y - 1 and countv >= 3:
				for k in range(countv):
					to_clear[Vector2i(x, y-k+1)] = true
	return to_clear.keys()

func _clear_and_cascade(positions: Array) -> void:
	# Clear tiles
	# Pre-count cleared tiles by type before mutating arrays
	var type_counts: Dictionary = {}
	for p in positions:
		var ttype := -1
		if _in_bounds(p):
			ttype = types[p.x][p.y]
			if ttype != -1:
				type_counts[ttype] = int(type_counts.get(ttype, 0)) + 1

	for p in positions:
		if grid[p.x][p.y]:
			grid[p.x][p.y].queue_free()
			grid[p.x][p.y] = null
			types[p.x][p.y] = -1
	# Report cleared tiles per type to nearest ancestor with handler
	var level_ref := self as Node
	while level_ref and not level_ref.has_method("add_tiles_cleared") and not level_ref.has_method("add_score"):
		level_ref = level_ref.get_parent()
	# Inform level per-type clears (e.g., for color objectives)
	if level_ref and level_ref.has_method("add_tiles_cleared"):
		for k in type_counts.keys():
			level_ref.add_tiles_cleared(int(type_counts[k]), int(k))
	# Score
	var gained := positions.size() * 10
	if gained > 0:
		if level_ref and level_ref.has_method("add_score"):
			# Delegate scoring to level script to avoid double counting
			level_ref.add_score(gained)
		else:
			# Default internal scoring (Level 1)
			score += gained
			emit_signal("score_changed", score)
	# Collapse and refill
	for x in range(GRID_SIZE.x):
		var write_y := GRID_SIZE.y - 1
		for y in range(GRID_SIZE.y - 1, -1, -1):
			if grid[x][y] != null:
				if y != write_y:
					grid[x][write_y] = grid[x][y]
					types[x][write_y] = types[x][y]
					grid[x][y] = null
					types[x][y] = -1
					grid[x][write_y].set_grid_position(Vector2i(x, write_y), TILE_SIZE)
				write_y -= 1
		# Refill
		for y in range(write_y, -1, -1):
			var t: Area2D = tile_scene.instantiate()
			add_child(t)
			var tt := randi() % TILE_TYPES
			t.tile_type = tt
			t.set_color(COLORS[tt])
			grid[x][y] = t
			types[x][y] = tt
			t.set_grid_position(Vector2i(x, y), TILE_SIZE)
			t.swiped.connect(_on_tile_swiped)

func _resolve_all_matches() -> void:
	while true:
		var matches := _find_matches()
		if matches.size() == 0:
			break
		_clear_and_cascade(matches)

func _emit_updates() -> void:
	emit_signal("moves_changed", moves_left)
	emit_signal("score_changed", score)

func _check_end_conditions() -> void:
	if score >= target_score:
		emit_signal("win")
		busy = false
		return
	if moves_left <= 0 and score < target_score:
		emit_signal("lose")
		busy = false
		return
	busy = false

func _in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.x < GRID_SIZE.x and p.y >= 0 and p.y < GRID_SIZE.y
