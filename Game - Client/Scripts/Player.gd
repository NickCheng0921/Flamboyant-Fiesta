extends KinematicBody2D

export(float) var runSpeed = 250

var velocity = Vector2()
var puppet_pos = Vector2()
export(float) var jumpHeight = 40
export(float) var jumpTime = 0.2
var gravity = 2*jumpHeight/(jumpTime*jumpTime)

func _ready():
	puppet_pos = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#print(position)
	if is_network_master():
		puppet_pos = get_node(".").get_position()
		var move = 0.0
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
	else:
		position = puppet_pos
		
#https://godotengine.org/article/multiplayer-changes-godot-4-0-report-1
puppet func update_state(p_pos, p_vel):
	puppet_pos = p_pos
	velocity = p_vel