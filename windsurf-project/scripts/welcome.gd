extends Control

func _ready() -> void:
	var btn := $VBox/Button
	btn.pressed.connect(_on_continue_pressed)

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://mainmenu.tscn")
