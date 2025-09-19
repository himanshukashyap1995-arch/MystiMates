extends Node2D

@onready var label_level: Label = $TopUI/LabelLevel
@onready var label_moves: Label = $TopUI/LabelMoves
@onready var label_objective: Label = $TopUI/LabelObjective
@onready var win_dialog: AcceptDialog = $WinDialog
@onready var lose_dialog: AcceptDialog = $LoseDialog

var board: Node

var config: Dictionary
var level_index: int = 1
var moves: int = 0
var score: int = 0
var color_targets: Dictionary = {}
var cleared_counts: Dictionary = {}

func _enter_tree() -> void:
	# Configure board before it runs its _ready()
	board = $"BoardContainer/Board"
	level_index = LevelManager.current_level
	config = LevelManager.get_level_data(level_index)
	var m: int = int(config.get("moves", 10))
	moves = m
	if board:
		# Set exported properties on the board before its _ready executes
		board.starting_moves = m
		match String(config.get("type", "score")):
			"score":
				board.target_score = int(config.get("target_score", 99999))
			_:
				# For color-based objectives, set a very high target so board doesn't win prematurely
				board.target_score = 999999

func _ready() -> void:
	# Read final config and set up UI and connections
	if board == null:
		board = $"BoardContainer/Board"
	label_level.text = "Level %d" % level_index
	label_moves.text = "Moves Left: %d" % moves
	label_objective.visible = true
	var t: String = String(config.get("type", "score"))
	if t == "score":
		_score_update_objective()
	elif t == "color" or t == "color_multi":
		color_targets = Dictionary(config.get("color_targets", {}))
		for k in color_targets.keys():
			cleared_counts[int(k)] = 0
		_update_color_objective()
	# Connect board signals
	board.moves_changed.connect(_on_moves_changed)
	board.score_changed.connect(_on_score_changed)
	# We do not rely on board win/lose; we compute our own and just show popups
	# Dialogs: return to map
	win_dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://scenes/map.tscn"))
	lose_dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://scenes/map.tscn"))

func _on_moves_changed(m: int) -> void:
	moves = m
	label_moves.text = "Moves Left: %d" % m
	_check_lose_condition_if_needed()

func _on_score_changed(s: int) -> void:
	score = s
	if String(config.get("type", "score")) == "score":
		_score_update_objective()
		if score >= int(config.get("target_score", 99999)):
			_show_win()

func add_tiles_cleared(count: int, tile_type: int) -> void:
	if not (String(config.get("type", "score")) in ["color", "color_multi"]):
		return
	cleared_counts[tile_type] = int(cleared_counts.get(tile_type, 0)) + count
	_update_color_objective()
	if _all_color_targets_met():
		_show_win()

func add_score(amount: int) -> void:
	# Keep score label up-to-date even for color levels
	score += amount
	if String(config.get("type", "score")) == "score":
		_score_update_objective()

func _check_lose_condition_if_needed() -> void:
	var t: String = String(config.get("type", "score"))
	if moves <= 0:
		if t == "score":
			if score < int(config.get("target_score", 99999)):
				_show_lose()
		else:
			if not _all_color_targets_met():
				_show_lose()

func _all_color_targets_met() -> bool:
	for k in color_targets.keys():
		var target := int(color_targets[k])
		var have := int(cleared_counts.get(int(k), 0))
		if have < target:
			return false
	return true

func _score_update_objective() -> void:
	label_objective.text = "Score: %d / %d" % [score, int(config.get("target_score", 0))]

func _update_color_objective() -> void:
	# Build a friendly objective string
	var name_map: Dictionary = {0: "Red", 1: "Blue", 2: "Green", 3: "Yellow"}
	var parts: Array = []
	for k in color_targets.keys():
		var target: int = int(color_targets[k])
		var have: int = int(cleared_counts.get(int(k), 0))
		var label: String = String(name_map.get(int(k), str(k)))
		parts.append("%s: %d/%d" % [label, have, target])
	var obj_text: String = ""
	for i in range(parts.size()):
		obj_text += String(parts[i])
		if i < parts.size() - 1:
			obj_text += " | "
	label_objective.text = obj_text

func _show_win() -> void:
	if not win_dialog.visible:
		win_dialog.popup_centered()

func _show_lose() -> void:
	if not lose_dialog.visible:
		lose_dialog.popup_centered()
