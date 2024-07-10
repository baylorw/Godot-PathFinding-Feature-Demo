extends Control

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_nav_2d_basic_example_pressed():
	get_tree().change_scene_to_file("res://level/NavigationAgent2DExample/NavigationAgent2D_example.tscn")

func _on_nav_2d_aggro_example_pressed():
	get_tree().change_scene_to_file("res://level/ChaseWithNavigationAgent2DExample/chase_with_NavigationAgent2D_example.tscn")

func _on_a_star_grid_example_pressed():
	get_tree().change_scene_to_file("res://level/AStarGrid2DExample/a_star_grid_2d_example.tscn")
