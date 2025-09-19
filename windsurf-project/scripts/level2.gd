extends Control

@onready var label_moves: Label = $TopBar/LabelMoves
@onready var label_score: Label = $TopBar/LabelScore
@onready var board: Node = $Board
@onready var win_dialog: AcceptDialog = $WinDialog
@onready var lose_dialog: AcceptDialog = $LoseDialog

var moves: int = 15
var score: int = 0
var target_score: int = 200

func _ready() -> void:
	# Connect board signals
	board.moves_changed.connect(_on_moves_changed)
	board.score_changed.connect(_on_score_changed)
	board.win.connect(_on_win)
	board.lose.connect(_on_lose)
	# Initialize UI
	label_moves.text = "Moves Left: %d" % moves
	label_score.text = "Score: %d" % score
	# Dialogs return to map
	win_dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://scenes/map.tscn"))
	lose_dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://scenes/map.tscn"))

func _on_moves_changed(m: int) -> void:
	moves = m
	label_moves.text = "Moves Left: %d" % m

func _on_score_changed(s: int) -> void:
	score = s
	label_score.text = "Score: %d" % s

func deduct_move() -> void:
	moves -= 1
	label_moves.text = "Moves Left: %d" % moves
	_check_end_conditions()

func add_score(amount: int) -> void:
	score += amount
	label_score.text = "Score: %d" % score
	_check_end_conditions()

func _check_end_conditions() -> void:
	if score >= target_score:
		win_dialog.popup_centered()
		return
	if moves <= 0 and score < target_score:
		lose_dialog.popup_centered()
		return

func _on_win() -> void:
	win_dialog.popup_centered()

func _on_lose() -> void:
	lose_dialog.popup_centered()
