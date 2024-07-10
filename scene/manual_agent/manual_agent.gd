extends CharacterBody2D

@export var speed := 400.0
@export var acceleration := 4000.0
@export var decceleration := 3000.0
@export var aim_deadzone := 0.2

#@onready var sprite = $AnimatedSprite2D
@onready var sprite = $Sprite2D

#var _direction := Vector2.DOWN
var _input_direction := Vector2.ZERO

func _physics_process(delta):
	#--- get_axis returns strength of the second option - first option.
	#--- Useful if your idiot player is pushing left and right at the same time?
	_input_direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).limit_length(1.0)
	#--- This code steers him like a car. It makes the character move silly.
	if _input_direction:
		velocity += _input_direction * acceleration * delta
		velocity = velocity.limit_length(speed * _input_direction.length())
		#if _input_direction.length() > aim_deadzone:
			#_direction = _input_direction.normalized()
		#sprite.play("run")
		sprite.flip_h = (_input_direction.x < 0)
	else:
		#--- This makes him NOT stop on a dime. No instant stops or pivots. Moves like a car.
		velocity = velocity.move_toward(Vector2.ZERO, decceleration * delta)
		#velocity = Vector2.ZERO
		#$AnimatedSprite2D.play("idle")
	move_and_slide()
