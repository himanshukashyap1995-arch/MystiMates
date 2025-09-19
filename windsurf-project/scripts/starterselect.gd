extends Control

func _ready() -> void:
	$VBox/Button.pressed.connect(func(): get_tree().change_scene_to_file("res://map.tscn"))
