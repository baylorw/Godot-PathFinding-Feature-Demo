extends Node2D

@onready var seeker = $Seeker

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://main_menu.tscn")
	elif event.is_action_pressed("left_click"):
		var desired_position = get_global_mouse_position()
		#print("telling agent to move to " + str(desired_position))
		seeker.go_to(desired_position)
		for agent in $Seekers.get_children():
			agent.go_to(desired_position)


