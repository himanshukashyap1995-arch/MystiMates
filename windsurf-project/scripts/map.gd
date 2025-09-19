extends Control

func _ready() -> void:
	# Level 1
	if has_node("VBox/Button"):
		$VBox/Button.pressed.connect(func():
			LevelManager.current_level = 1
			get_tree().change_scene_to_file("res://scenes/level.tscn")
		)
	# Level 2
	var btn2 := $VBox/ButtonLevel2 if has_node("VBox/ButtonLevel2") else null
	if btn2:
		btn2.pressed.connect(func():
			LevelManager.current_level = 2
			get_tree().change_scene_to_file("res://scenes/level.tscn")
		)
	# Level 3
	var btn3 := $VBox/ButtonLevel3 if has_node("VBox/ButtonLevel3") else null
	if btn3:
		btn3.pressed.connect(func():
			LevelManager.current_level = 3
			get_tree().change_scene_to_file("res://scenes/level.tscn")
		)
	# Level 4
	var btn4 := $VBox/ButtonLevel4 if has_node("VBox/ButtonLevel4") else null
	if btn4:
		btn4.pressed.connect(func():
			LevelManager.current_level = 4
			get_tree().change_scene_to_file("res://scenes/level.tscn")
		)
