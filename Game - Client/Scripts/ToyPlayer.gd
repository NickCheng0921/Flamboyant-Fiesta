extends KinematicBody2D

export(float) var runSpeed = 250

var velocity = Vector2()
export(float) var jumpHeight = 40
export(float) var jumpTime = 0.2
export(bool) var canIdle = true
#canFall is the ability to play the falling animation
export(bool) var canFall = true
var gravity = 2*jumpHeight/(jumpTime*jumpTime)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var move = 0.0
	var up = 0
	#movement
	if(Input.is_action_pressed("ui_right")):
		move += 1
		
	if(Input.is_action_pressed("ui_left")):
		move -= 1
		
	if(Input.is_action_just_pressed("jump") && is_on_floor()):
		velocity.y = -2*jumpHeight/jumpTime
		
	#walljump
	#if(Input.is_action_just_pressed("jump") && is_on_floor() == false && is_on_wall()):
	#	velocity.y = -2*jumpHeight/jumpTime
		
	#movement calculations
	# -y is up, +y is down
	velocity.y += gravity*delta
	velocity.x = move * runSpeed
	velocity = move_and_slide(velocity, Vector2(0, -1))
	velocity.y += up

func _on_ReadyArea_body_entered(body):
	print("Physics body")
	$"../".player_ready(true)

func _on_ReadyArea_body_exited(body):
	print("Physics left")
	$"../".player_ready(false)
