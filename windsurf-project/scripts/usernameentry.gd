extends Control

func _ready() -> void:
	$VBox/Button.pressed.connect(_on_continue_pressed)

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://starterselect.tscn")
