extends CharacterBody2D

@export var speed := 300.0
@export var acceleration := 4000.0
@export var decceleration := 5000.0
@export var aim_deadzone := 0.2

@onready var sprite = $Sprite2D
@onready var pathfinder : NavigationAgent2D = %NavigationAgent2D

var home_position : Vector2
var target = null

func _ready():
	home_position = self.position

# Used by NavigationAgent2D for Avoidance. Not sure if it's needed.
func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()

func _on_repath_timer_timeout():
	recalc_path()

func _physics_process(_delta):
	if pathfinder.is_navigation_finished():
		return

	var axis = to_local(pathfinder.get_next_path_position()).normalized()
	sprite.flip_h = (axis.x < 0)
	var intended_velocity = axis * speed
	#--- This doesn't move, it triggers the velocity_computed event.
	#--- Used with NavigationAgent2D Avoidance functionality.
	pathfinder.set_velocity(intended_velocity)

func recalc_path():
	if target:
		pathfinder.target_position = target.global_position
	else:
		pathfinder.target_position = home_position

func _on_aggro_boundary_body_entered(body):
	print("We found someone to chase!")
	target = body

func _on_abandon_chase_boundary_body_exited(_body):
	print("We lost someone to chase :(")
	target = null
