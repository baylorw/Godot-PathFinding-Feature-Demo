extends CharacterBody2D

#@export var pathfinder : NavigationAgent2D
@onready var pathfinder : NavigationAgent2D = %NavigationAgent2D

@export var speed := 300.0
@export var acceleration := 4000.0
@export var decceleration := 5000.0
@export var aim_deadzone := 0.2

#@onready var sprite = $AnimatedSprite2D
@onready var sprite = $Sprite2D

var desired_position : Vector2
var is_seeking := false

#var _direction := Vector2.DOWN


func go_to(requested_position : Vector2):
	desired_position = requested_position
	#print("were just requested to move to " + str(requested_position))
	pathfinder.target_position = desired_position
	#print("pathfinder.target_position=" + str(pathfinder.target_position))
	is_seeking = true

func _on_repath_timer_timeout():
	pass
	#recalc_path()

func _physics_process(_delta):
	if pathfinder.is_navigation_finished():
		is_seeking = false
	
	if !is_seeking:
		return

	#--- Original
	var axis = to_local(pathfinder.get_next_path_position()).normalized()
	velocity = axis * speed
	sprite.flip_h = (axis.x < 0)

	#--- Merged
	#--- This does not work and i have no idea why
	#var next_path_node = pathfinder.get_next_path_position()
	#next_path_node = to_local(next_path_node)
	#var direction = next_path_node.normalized()
	#var direction = to_local(pathfinder.get_next_path_position()).normalized()
	#velocity += direction * acceleration * delta
	#velocity = velocity.limit_length(speed * direction.length())
	#sprite.flip_h = (direction.x < 0)

	move_and_slide()

# Only need this if the target keeps moving, no one tells us it moved but we know where it moved anyway.
#func recalc_path():
	#if !is_seeking:
		#return
	#pathfinder.target_position = desired_position


