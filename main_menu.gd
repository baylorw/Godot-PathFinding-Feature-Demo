extends Control

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_basic_grid_movement_pressed():
	get_tree().change_scene_to_file("res://level/NavigationAgent2DExample/NavigationAgent2D_example.tscn")
