extends Control

@onready var label_moves: Label = $TopBar/LabelMoves
@onready var label_score: Label = $TopBar/LabelScore
@onready var label_objective: Label = $TopBar/LabelObjective
@onready var board: Node = $Board
@onready var win_dialog: AcceptDialog = $WinDialog
@onready var lose_dialog: AcceptDialog = $LoseDialog

var moves: int = 20
var score: int = 0
var red_tiles_cleared: int = 0
var red_target: int = 10

func _ready() -> void:
	# Connect board signals
	board.moves_changed.connect(_on_moves_changed)
	board.score_changed.connect(_on_score_changed)
	board.win.connect(_on_win)
	board.lose.connect(_on_lose)
	# Initialize UI
	label_moves.text = "Moves Left: %d" % moves
	label_score.text = "Score: %d" % score
	_update_objective()
	# Dialogs return to map
	win_dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://scenes/map.tscn"))
	lose_dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://scenes/map.tscn"))

func _on_moves_changed(m: int) -> void:
	moves = m
	label_moves.text = "Moves Left: %d" % m
	_check_end_conditions()

func _on_score_changed(s: int) -> void:
	score = s
	label_score.text = "Score: %d" % s

func _update_objective() -> void:
	label_objective.text = "Red tiles cleared: %d / %d" % [red_tiles_cleared, red_target]

func deduct_move() -> void:
	moves -= 1
	label_moves.text = "Moves Left: %d" % moves
	_check_end_conditions()

func add_tiles_cleared(count: int, tile_type: int) -> void:
	if tile_type == 0:
		red_tiles_cleared += count
		_update_objective()
		_check_end_conditions()

func add_score(amount: int) -> void:
	score += amount
	label_score.text = "Score: %d" % score
	# Score does not determine win/lose here, but we still update UI.

func _check_end_conditions() -> void:
	if red_tiles_cleared >= red_target:
		win_dialog.popup_centered()
		return
	if moves <= 0 and red_tiles_cleared < red_target:
		lose_dialog.popup_centered()
		return

func _on_win() -> void:
	win_dialog.popup_centered()

func _on_lose() -> void:
	lose_dialog.popup_centered()
