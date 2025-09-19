extends Control

@onready var moves_label: Label = $TopBar/MovesLabel
@onready var score_label: Label = $TopBar/ScoreLabel
@onready var board: Node = $Board
@onready var win_dialog: AcceptDialog = $WinDialog
@onready var lose_dialog: AcceptDialog = $LoseDialog

func _ready() -> void:
	board.moves_changed.connect(_on_moves_changed)
	board.score_changed.connect(_on_score_changed)
	board.win.connect(_on_win)
	board.lose.connect(_on_lose)
	# Ensure dialogs return to map on confirm
	win_dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://map.tscn"))
	lose_dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://map.tscn"))

func _on_moves_changed(m: int) -> void:
	moves_label.text = "Moves Left: %d" % m

func _on_score_changed(s: int) -> void:
	score_label.text = "Score: %d" % s

func _on_win() -> void:
	win_dialog.popup_centered()

func _on_lose() -> void:
	lose_dialog.popup_centered()
