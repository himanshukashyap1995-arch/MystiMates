extends Control

@onready var moves_label: Label = $TopBar/MovesLabel
@onready var score_label: Label = $TopBar/ScoreLabel
@onready var board: Node = $Board
@onready var win_dialog: AcceptDialog = $WinDialog
@onready var lose_dialog: AcceptDialog = $LoseDialog
@onready var tutorial_root: Control = $Tutorial
@onready var play_button: Button = $Tutorial/PlayButton

func _ready() -> void:
	board.moves_changed.connect(_on_moves_changed)
	board.score_changed.connect(_on_score_changed)
	board.win.connect(_on_win)
	board.lose.connect(_on_lose)
	# Ensure dialogs return to map on confirm
	win_dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://map.tscn"))
	lose_dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://map.tscn"))

	# FTUE tutorial: show once
	if not LevelManager.seen_level1_tutorial:
		_show_tutorial()
	else:
		_hide_tutorial()

func _on_moves_changed(m: int) -> void:
	moves_label.text = "Moves Left: %d" % m

func _on_score_changed(s: int) -> void:
	score_label.text = "Score: %d" % s

func _on_win() -> void:
	win_dialog.popup_centered()

func _on_lose() -> void:
	lose_dialog.popup_centered()

func _show_tutorial() -> void:
	if tutorial_root:
		tutorial_root.visible = true
		# Optional: disable board input while tutorial is visible
		if board.has_method("set_process_input"):
			board.set_process_input(false)
	if play_button:
		play_button.pressed.connect(_on_play_pressed, CONNECT_ONE_SHOT)

func _hide_tutorial() -> void:
	if tutorial_root:
		tutorial_root.visible = false
		if board.has_method("set_process_input"):
			board.set_process_input(true)

func _on_play_pressed() -> void:
	LevelManager.seen_level1_tutorial = true
	_hide_tutorial()
